import 'package:dartz/dartz.dart' hide State;
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
import 'package:t_store/features/notifications/domain/push_contract.dart';
import 'package:t_store/features/notifications/presentation/views/notification_preferences_view.dart';

class MerchantHome extends StatefulWidget {
  const MerchantHome({super.key, required this.services, required this.access});
  final MerchantServices services;
  final MerchantAccess access;
  @override
  State<MerchantHome> createState() => _MerchantHomeState();
}

class _MerchantHomeState extends State<MerchantHome> {
  int _index = 0, _overviewRevision = 0;
  void _navigate(int index) => setState(() => _index = index);
  Future<void> _profile() async {
    final saved = await Navigator.of(context).push<bool>(
      MaterialPageRoute(
        builder: (pageContext) => MerchantShopForm(
          repository: widget.services.merchants,
          access: widget.access,
          onSaved: () => Navigator.pop(pageContext, true),
        ),
      ),
    );
    if (mounted && saved == true) context.read<MerchantSessionCubit>().reload();
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
                _MerchantDashboard(
                  key: ValueKey(_overviewRevision),
                  services: s,
                  access: access,
                  onProducts: () => _navigate(1),
                  onQr: () => _navigate(2),
                  onProfile: _profile,
                ),
                MerchantProducts(
                  repository: s.merchants,
                  access: access,
                  onChanged: () => setState(() => ++_overviewRevision),
                ),
                MerchantQrView(
                  preview: s.preview,
                  repository: MerchantQrRepository(
                    delegate: s.qr,
                    merchants: s.merchants,
                    access: access,
                  ),
                ),
                MerchantNotifications(
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

class _MerchantDashboard extends StatefulWidget {
  const _MerchantDashboard({
    super.key,
    required this.services,
    required this.access,
    required this.onProducts,
    required this.onQr,
    required this.onProfile,
  });
  final MerchantServices services;
  final MerchantAccess access;
  final VoidCallback onProducts, onQr, onProfile;
  @override
  State<_MerchantDashboard> createState() => _MerchantDashboardState();
}

class _MerchantDashboardState extends State<_MerchantDashboard> {
  late Future<Either<String, MerchantOverview>> _summary;
  @override
  void initState() {
    super.initState();
    _summary = _load();
  }

  Future<Either<String, MerchantOverview>> _load() =>
      widget.services.merchants.overview(widget.access);
  Future<void> _refresh() async {
    setState(() => _summary = _load());
    await _summary;
  }

  @override
  Widget build(BuildContext context) => MerchantPage(
    title: 'Mağaza özeti',
    onRefresh: _refresh,
    children: [
      Text(
        widget.access.shop!.name,
        style: Theme.of(context).textTheme.headlineMedium,
      ),
      const Text('Mağazanın güncel durumunu kontrol et.'),
      FutureBuilder<Either<String, MerchantOverview>>(
        future: _summary,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return MerchantNotice(
              'Özet yüklenemedi.',
              error: true,
              onRetry: _refresh,
            );
          }
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          return snapshot.data!.fold(
            (e) => MerchantNotice(e, error: true, onRetry: _refresh),
            (summary) => LayoutBuilder(
              builder: (context, constraints) => Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  for (final entry in {
                    'Toplam ürün': summary.total,
                    'Stokta var': summary.available,
                    'Stokta yok': summary.unavailable,
                    'Pasif': summary.inactive,
                  }.entries)
                    SizedBox(
                      width: (constraints.maxWidth - 12) / 2,
                      child: Card(
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                '${entry.value}',
                                style: Theme.of(
                                  context,
                                ).textTheme.headlineMedium,
                              ),
                              Text(entry.key),
                            ],
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
      FilledButton.icon(
        onPressed: widget.onProducts,
        icon: const Icon(Icons.inventory_2_outlined),
        label: const Text('Ürünleri ve fiyatları yönet'),
      ),
      OutlinedButton.icon(
        onPressed: widget.onQr,
        icon: const Icon(Icons.qr_code_scanner),
        label: const Text('Müşteri QR kodunu doğrula'),
      ),
      TextButton(
        onPressed: widget.onProfile,
        child: const Text('Mağaza bilgilerini düzenle'),
      ),
    ],
  );
}
