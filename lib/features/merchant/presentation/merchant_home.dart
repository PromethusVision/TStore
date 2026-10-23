import 'package:flutter/material.dart';
import 'dart:async';
import 'package:t_store/features/merchant/presentation/merchant_messages.dart';
import 'package:t_store/features/notifications/domain/entities/notification_entity.dart';
import 'package:flutter/foundation.dart';
import 'package:t_store/features/notifications/domain/push_coordinator.dart';
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
  const MerchantHome({
    super.key,
    required this.services,
    required this.access,
    this.push,
    this.inboxRequests,
    this.notificationRequests,
  });
  final MerchantServices services;
  final MerchantAccess access;
  final PushCoordinator? push;
  final ValueListenable<int>? inboxRequests;
  final ValueListenable<NotificationEntity?>? notificationRequests;
  @override
  State<MerchantHome> createState() => _MerchantHomeState();
}

class _MerchantHomeState extends State<MerchantHome>
    with WidgetsBindingObserver {
  int _index = 0, _overviewRevision = 0, _productsRevision = 0;
  bool _opening = false;
  Future<Object?>? _openRoute;
  int _notificationGeneration = 0;
  late final int _scopeRevision;
  late final String? _sessionKey;
  bool get _currentWorkspace {
    if (!mounted) return false;
    final session = context.read<MerchantSessionCubit>();
    return mounted &&
        !session.isClosed &&
        session.state.status == MerchantSessionStatus.ready &&
        session.state.scopeRevision == _scopeRevision &&
        widget.services.currentUserId() == widget.access.user.id &&
        widget.services.currentSessionKey?.call() == _sessionKey;
  }

  late final NotificationsCubit _notifications;
  @override
  void initState() {
    super.initState();
    _scopeRevision = context.read<MerchantSessionCubit>().state.scopeRevision;
    _sessionKey = widget.services.currentSessionKey?.call();
    WidgetsBinding.instance.addObserver(this);
    widget.inboxRequests?.addListener(_openInbox);
    widget.notificationRequests?.addListener(_notificationRequested);
    _notifications =
        NotificationsCubit(repository: widget.services.notifications)
          ..startListening()
          ..getNotifications();
  }

  @override
  void didUpdateWidget(covariant MerchantHome oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.inboxRequests != widget.inboxRequests) {
      oldWidget.inboxRequests?.removeListener(_openInbox);
      widget.inboxRequests?.addListener(_openInbox);
    }
    if (oldWidget.notificationRequests != widget.notificationRequests) {
      oldWidget.notificationRequests?.removeListener(_notificationRequested);
      widget.notificationRequests?.addListener(_notificationRequested);
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    widget.inboxRequests?.removeListener(_openInbox);
    widget.notificationRequests?.removeListener(_notificationRequested);
    _notifications.close();
    super.dispose();
  }

  void _openInbox() {
    if (!mounted || widget.services.currentUserId() != widget.access.user.id) {
      return;
    }
    Navigator.of(context).popUntil((route) => route.isFirst);
    _navigate(3);
  }

  bool _chatNotification(NotificationEntity item) =>
      item.type == NotificationType.chat &&
      item.userId == widget.access.user.id &&
      (item.data?['app_role'] == null || item.data?['app_role'] == 'merchant');

  void _messages([NotificationEntity? item]) {
    if (!_currentWorkspace || widget.services.chatRepositoryFactory == null) {
      return;
    }
    if (item != null && !_chatNotification(item)) return;
    _open(
      MerchantMessages(
        services: widget.services,
        access: widget.access,
        peerId: item?.actionType == 'chat_detail' ? item?.actionId : null,
      ),
    );
  }

  void _notificationRequested() {
    unawaited(_openRequestedNotification());
  }

  Future<void> _openRequestedNotification() async {
    final item = widget.notificationRequests?.value;
    if (!_currentWorkspace ||
        item == null ||
        item.userId != widget.access.user.id ||
        (item.data?['app_role'] != null &&
            item.data?['app_role'] != 'merchant')) {
      return;
    }
    final generation = ++_notificationGeneration;
    final closing = _openRoute;
    Navigator.of(context).popUntil((route) => route.isFirst);
    _navigate(3);
    if (closing != null) await closing;
    await Future<void>.value();
    if (!mounted ||
        !_currentWorkspace ||
        generation != _notificationGeneration) {
      return;
    }
    if (_chatNotification(item)) _messages(item);
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
      final route = Navigator.of(
        context,
      ).push<Object?>(MaterialPageRoute(builder: (_) => page));
      _openRoute = route;
      await route;
    } finally {
      _openRoute = null;
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
      final route = Navigator.of(context).push<bool>(
        MaterialPageRoute(
          builder: (pageContext) => MerchantShopForm(
            repository: widget.services.merchants,
            access: widget.access,
            onSaved: () => Navigator.pop(pageContext, true),
          ),
        ),
      );
      _openRoute = route;
      await route;
    } finally {
      _openRoute = null;
      _opening = false;
      if (mounted) {
        // Returning after an uncertain save also needs the authoritative shop.
        // An unchanged shop retains the current navigation/drafts.
        context.read<MerchantSessionCubit>().reload(quiet: true);
      }
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
                  messagesEntry: s.chatRepositoryFactory == null
                      ? null
                      : MerchantMessagesEntry(
                          services: s,
                          access: access,
                          onOpen: _messages,
                          notifications: _notifications,
                        ),
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
                  onChat: s.chatRepositoryFactory == null ? null : _messages,
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
                    if (s.chatRepositoryFactory != null)
                      OutlinedButton.icon(
                        onPressed: _messages,
                        icon: const Icon(Icons.chat_bubble_outline),
                        label: const Text('Müşteri mesajları'),
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
                                push: widget.push,
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
