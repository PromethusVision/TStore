import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:t_store/features/merchant/presentation/merchant_reviews.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/merchant/domain/merchant_operations_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/merchant_services.dart';
import 'package:t_store/features/merchant/presentation/merchant_widgets.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_cubit.dart';
import 'package:t_store/features/notifications/presentation/cubit/notifications_state.dart';

class MerchantDashboard extends StatefulWidget {
  const MerchantDashboard({
    super.key,
    required this.services,
    required this.access,
    required this.notifications,
    required this.onProducts,
    required this.onAddProduct,
    required this.onQr,
    required this.onProfile,
    required this.onSubmissions,
    required this.onPendingUploads,
    required this.onMedia,
    required this.onNotifications,
  });
  final MerchantServices services;
  final MerchantAccess access;
  final NotificationsCubit notifications;
  final VoidCallback onProducts,
      onAddProduct,
      onQr,
      onProfile,
      onSubmissions,
      onPendingUploads,
      onNotifications;
  final void Function(String listingId) onMedia;
  @override
  State<MerchantDashboard> createState() => _MerchantDashboardState();
}

class _MerchantDashboardState extends State<MerchantDashboard> {
  late Future<Either<String, MerchantOverview>> _overview;
  Future<Either<String, MerchantOperations>>? _operations;
  int _reviewsRevision = 0;
  bool get _current => widget.services.currentUserId() == widget.access.user.id;
  @override
  void initState() {
    super.initState();
    _read();
  }

  void _read() {
    _reviewsRevision++;
    _overview = widget.services.merchants.overview(widget.access);
    _operations = widget.services.operations?.read(widget.access);
  }

  Future<void> _refresh() async {
    if (!_current) return;
    setState(_read);
    // Each section renders its own failure; a failed extra does not hide counts.
    await Future.wait<Object?>([
      _overview,
      if (_operations != null) _operations!,
      widget.notifications.getNotifications(refresh: true),
    ]).catchError((_) => <Object?>[]);
  }

  @override
  Widget build(BuildContext context) {
    if (!_current) return const SizedBox.shrink();
    return MerchantPage(
      title: 'Mağaza özeti',
      onRefresh: _refresh,
      actions: [
        IconButton(
          tooltip: 'Özeti yenile',
          onPressed: _refresh,
          icon: const Icon(Icons.refresh),
        ),
      ],
      children: [
        Text(
          widget.access.shop!.name,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        const Text('Mağazanın güncel durumunu kontrol et.'),
        if (widget.services.evaluations case final repository?)
          MerchantReviewSummary(
            key: ValueKey(_reviewsRevision),
            repository: repository,
            shopId: widget.access.shop!.id,
            ownerId: widget.access.user.id,
          ),
        FutureBuilder<Either<String, MerchantOverview>>(
          future: _overview,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snapshot.hasError || !snapshot.hasData) {
              return MerchantNotice(
                'Ürün özeti yüklenemedi.',
                error: true,
                onRetry: _refresh,
              );
            }
            return snapshot.data!.fold(
              (e) => MerchantNotice(e, error: true, onRetry: _refresh),
              (s) => Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  LayoutBuilder(
                    builder: (context, constraints) => Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        for (final entry in {
                          'Toplam ürün': s.total,
                          'Stokta var': s.available,
                          'Stokta yok': s.unavailable,
                          'Pasif': s.inactive,
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
                  const SizedBox(height: 8),
                  const Text(
                    'Sayılar ürün çeşidini gösterir; adet stoku tutulmaz.',
                  ),
                  if (s.total == 0)
                    const MerchantNotice(
                      'İlk ürününü katalogdan ekleyerek başla.',
                    ),
                ],
              ),
            );
          },
        ),
        FilledButton.icon(
          onPressed: widget.onAddProduct,
          icon: const Icon(Icons.add),
          label: const Text('Katalogdan ürün ekle'),
        ),
        OutlinedButton.icon(
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
        if (widget.services.catalogMedia != null) ...[
          if (_operations != null)
            FutureBuilder<Either<String, MerchantOperations>>(
              future: _operations,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const MerchantNotice('İşlem durumu yükleniyor…');
                }
                if (snapshot.hasError || !snapshot.hasData) {
                  return MerchantNotice(
                    'İşlem özeti yüklenemedi.',
                    error: true,
                    onRetry: _refresh,
                  );
                }
                return snapshot.data!.fold(
                  (e) => MerchantNotice(e, error: true, onRetry: _refresh),
                  (s) => MerchantSection(
                    title: 'Takip edilecek işlemler',
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        Text(
                          'İnceleniyor: ${s.pendingSubmissions} • Onaylandı: ${s.approvedSubmissions} • Reddedildi: ${s.rejectedSubmissions}',
                        ),
                        const SizedBox(height: 8),
                        const Text(
                          'Başvuru ürünün yayımlandığı anlamına gelmez. Onaylanan ürünü ayrıca mağazana eklersin.',
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'Yarım kalan fotoğraf yüklemesi: ${s.pendingListings} ürün',
                        ),
                        for (final u in s.uploads.take(3))
                          ListTile(
                            contentPadding: EdgeInsets.zero,
                            title: Text(u.productName),
                            subtitle: Text(
                              '${u.photoCount} fotoğraf tamamlanmadı',
                            ),
                            trailing: const Icon(Icons.chevron_right),
                            onTap: () => widget.onMedia(u.listingId),
                          ),
                        if (s.pendingListings > 0)
                          TextButton(
                            onPressed: widget.onPendingUploads,
                            child: const Text('Yarım kalan yüklemeleri aç'),
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          OutlinedButton(
            onPressed: widget.onSubmissions,
            child: const Text('Ürün başvurularım'),
          ),
        ],
        BlocBuilder<NotificationsCubit, NotificationsState>(
          bloc: widget.notifications,
          buildWhen: (_, next) => next is! NewNotificationReceived,
          builder: (context, state) {
            final items = state is NotificationsLoaded
                ? state.notifications
                      .where(
                        (n) =>
                            n.userId == widget.access.user.id &&
                            (n.data?['app_role'] == null ||
                                n.data?['app_role'] == 'merchant'),
                      )
                      .take(3)
                      .toList()
                : null;
            return MerchantSection(
              title: 'Son bildirimler',
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  if (state is NotificationsError)
                    Text(state.message)
                  else if (items == null)
                    const Text('Bildirimler yükleniyor…')
                  else if (items.isEmpty)
                    const Text('Henüz bildirimin yok.')
                  else
                    for (final n in items)
                      ListTile(
                        contentPadding: EdgeInsets.zero,
                        title: Text(n.title),
                        subtitle: Text(
                          n.body,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                        leading: Icon(
                          n.isRead
                              ? Icons.notifications_none
                              : Icons.notifications_active_outlined,
                        ),
                        onTap: widget.onNotifications,
                      ),
                  TextButton(
                    onPressed: widget.onNotifications,
                    child: const Text('Bildirim merkezini aç'),
                  ),
                ],
              ),
            );
          },
        ),
      ],
    );
  }
}
