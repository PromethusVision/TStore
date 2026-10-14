import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/merchant/data/merchant_qr_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/merchant_services.dart';
import 'package:t_store/features/merchant/presentation/merchant_notifications.dart';
import 'package:t_store/features/merchant/presentation/merchant_products.dart';
import 'package:t_store/features/merchant/presentation/merchant_qr_view.dart';
import 'package:t_store/features/merchant/presentation/merchant_session_cubit.dart';
import 'package:t_store/features/merchant/presentation/merchant_shop_form.dart';
import 'package:t_store/features/merchant/presentation/merchant_widgets.dart';
import 'package:t_store/features/merchant/presentation/merchant_dashboard.dart';
import 'package:t_store/features/merchant/presentation/merchant_product_submission.dart';
import 'package:t_store/features/merchant/presentation/merchant_listing_media.dart';
import 'package:t_store/features/merchant/presentation/merchant_pending_uploads.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:t_store/features/notifications/domain/push_contract.dart';
import 'package:t_store/features/notifications/presentation/views/notification_preferences_view.dart';

class MerchantHome extends StatefulWidget {
  const MerchantHome({super.key, required this.services, required this.access});
  final MerchantServices services;
  final MerchantAccess access;
  @override
  State<MerchantHome> createState() => _MerchantHomeState();
}

class _MerchantHomeState extends State<MerchantHome>
    with WidgetsBindingObserver {
  int _index = 0, _overviewRevision = 0, _productsRevision = 0;
  bool _opening = false;
  late final NotificationsCubit _notifications;
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _notifications =
        NotificationsCubit(repository: widget.services.notifications)
          ..startListening()
          ..getNotifications();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _notifications.close();
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        widget.services.currentUserId() == widget.access.user.id) {
      setState(() {
        ++_overviewRevision;
        ++_productsRevision;
      });
      _notifications.getNotifications(refresh: true);
    }
  }

  void _navigate(int index) {
    setState(() {
      if (index == 0) ++_overviewRevision;
      if (index == 1) ++_productsRevision;
      _index = index;
    });
    if (index == 0 || index == 3) {
      _notifications.getNotifications(refresh: true);
    }
  }

  Future<void> _open(Widget page) async {
    if (_opening) return;
    _opening = true;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    try {
      await Navigator.of(
        context,
      ).push<Object?>(MaterialPageRoute(builder: (_) => page));
    } finally {
      _opening = false;
      if (mounted) {
        setState(() {
          ++_overviewRevision;
          ++_productsRevision;
        });
      }
    }
  }

  Future<void> _profile() async {
    if (_opening) return;
    _opening = true;
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    try {
      final saved = await Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (pageContext) => MerchantShopForm(
            repository: widget.services.merchants,
            access: widget.access,
            onSaved: () => Navigator.pop(pageContext, true),
          ),
        ),
      );
      if (mounted && saved == true) {
        context.read<MerchantSessionCubit>().reload();
      }
    } finally {
      _opening = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = widget.services;
    final access = widget.access;
    final identity = PushIdentity(access.user.id, NotificationAppRole.merchant);
    return Scaffold(
      body: Column(
        children: [
          if (s.preview)
            const SafeArea(
              bottom: false,
              child: Padding(
                padding: EdgeInsets.all(8),
                child: Text(
                  'YEREL ÖNİZLEME • SENTETİK VERİ',
                  style: TextStyle(fontWeight: FontWeight.w600),
                ),
              ),
            ),
          Expanded(
            child: IndexedStack(
              index: _index,
              children: [
                MerchantDashboard(
                  key: ValueKey(_overviewRevision),
                  services: s,
                  access: access,
                  notifications: _notifications,
                  onProducts: () => _navigate(1),
                  onAddProduct: () => _open(
                    MerchantCatalogPicker(
                      repository: s.merchants,
                      catalogMedia: s.catalogMedia,
                      access: access,
                    ),
                  ),
                  onQr: () => _navigate(2),
                  onProfile: _profile,
                  onSubmissions: () {
                    if (s.catalogMedia != null) {
                      _open(
                        MerchantSubmissions(
                          catalog: s.catalogMedia!,
                          repository: s.merchants,
                          access: access,
                        ),
                      );
                    }
                  },
                  onPendingUploads: () {
                    if (s.operations != null && s.catalogMedia != null) {
                      _open(
                        MerchantPendingUploads(
                          operations: s.operations!,
                          media: s.catalogMedia!,
                          access: access,
                        ),
                      );
                    }
                  },
                  onMedia: (id) {
                    if (s.catalogMedia != null) {
                      _open(
                        MerchantListingMedia(
                          repository: s.catalogMedia!,
                          access: access,
                          listingId: id,
                        ),
                      );
                    }
                  },
                  onNotifications: () => _navigate(3),
                ),
                MerchantProducts(
                  repository: s.merchants,
                  catalogMedia: s.catalogMedia,
                  access: access,
                  revision: _productsRevision,
                  onChanged: () => setState(() => ++_overviewRevision),
                ),
                MerchantQrView(
                  preview: s.preview,
                  shopId: access.shop!.id,
                  userId: access.user.id,
                  purchaseEvidence: s.purchaseEvidence,
                  repository: MerchantQrRepository(
                    delegate: s.qr,
                    merchants: s.merchants,
                    access: access,
                  ),
                ),
                MerchantNotifications(
                  cubit: _notifications,
                  repository: s.notifications,
                  identity: identity,
                  currentUserId: s.currentUserId,
                ),
                MerchantPage(
                  title: 'Hesabım',
                  children: [
                    MerchantSection(
                      title: access.user.fullName ?? 'Esnaf hesabı',
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(access.user.email),
                          const SizedBox(height: 8),
                          Text(access.shop!.name),
                        ],
                      ),
                    ),
                    OutlinedButton.icon(
                      onPressed: _profile,
                      icon: const Icon(Icons.storefront_outlined),
                      label: const Text('Mağaza profilini düzenle'),
                    ),
                    OutlinedButton.icon(
                      icon: const Icon(Icons.notifications_outlined),
                      label: const Text('Bildirim tercihleri'),
                      onPressed: () => Navigator.of(context).push<void>(
                        MaterialPageRoute(
                          builder: (_) => Scaffold(
                            appBar: AppBar(
                              title: const Text('Bildirim tercihleri'),
                            ),
                            body: SafeArea(
                              child: NotificationPreferenceControls(
                                key: ValueKey(identity.userId),
                                identity: identity,
                                repository: s.preferences,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    if (!s.pushProvider.configured)
                      const Text(
                        'Telefon bildirimi hizmeti henüz etkin değil. Bildirimlerini uygulama içinden takip edebilirsin.',
                      ),
                    OutlinedButton.icon(
                      onPressed: context.read<MerchantSessionCubit>().signOut,
                      icon: const Icon(Icons.logout),
                      label: const Text('Çıkış yap'),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: _navigate,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            label: 'Özet',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            label: 'Ürünler',
          ),
          NavigationDestination(icon: Icon(Icons.qr_code_scanner), label: 'QR'),
          NavigationDestination(
            icon: Icon(Icons.notifications_outlined),
            label: 'Bildirim',
          ),
          NavigationDestination(
            icon: Icon(Icons.person_outline),
            label: 'Hesap',
          ),
        ],
      ),
    );
  }
}
