import 'package:flutter/material.dart';
import 'package:t_store/features/merchant/presentation/merchant_workspace_continuation.dart';
import 'package:t_store/features/merchant/presentation/merchant_read.dart';
import 'package:t_store/features/merchant/domain/catalog_media_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_operations_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/presentation/merchant_listing_media.dart';
import 'package:t_store/features/merchant/presentation/merchant_widgets.dart';

class MerchantPendingUploads extends StatefulWidget {
  const MerchantPendingUploads({
    super.key,
    required this.operations,
    required this.media,
    required this.access,
  });
  final MerchantOperationsRepository operations;
  final CatalogMediaRepository media;
  final MerchantAccess access;
  @override
  State<MerchantPendingUploads> createState() => _MerchantPendingUploadsState();
}

class _MerchantPendingUploadsState extends State<MerchantPendingUploads>
    with MerchantWorkspaceContinuation<MerchantPendingUploads> {
  List<PendingListingUpload> _items = [];
  bool _loading = false, _more = false, _opening = false;
  int _page = 0, _epoch = 0;
  String? _error;
  @override
  void initState() {
    super.initState();
    _load(refresh: true);
  }

  Future<void> _load({bool refresh = false}) async {
    if (!workspaceCurrent || (_loading && !refresh)) return;
    final epoch = ++_epoch;
    if (refresh) {
      _page = 0;
      _items = [];
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final r = await merchantRead(
        () => widget.operations.read(widget.access, page: _page),
      );
      if (!workspaceCurrent || epoch != _epoch) return;
      setState(() {
        _loading = false;
        r.fold((e) => _error = e, (v) {
          _items = {
            ...{for (final i in _items) i.listingId: i},
            for (final i in v.uploads) i.listingId: i,
          }.values.toList();
          _more = v.uploads.length == merchantOperationsPageSize;
          ++_page;
        });
      });
    } catch (_) {
      if (workspaceCurrent && epoch == _epoch) {
        setState(() {
          _loading = false;
          _error = 'Yarım kalan yüklemeler alınamadı.';
        });
      }
    }
  }

  Future<void> _open(PendingListingUpload upload) async {
    if (!workspaceCurrent || _opening) return;
    _opening = true;
    await Navigator.of(context).push<void>(
      MaterialPageRoute(
        builder: (_) => MerchantListingMedia(
          repository: widget.media,
          access: widget.access,
          listingId: upload.listingId,
        ),
      ),
    );
    _opening = false;
    if (workspaceCurrent) await _load(refresh: true);
  }

  @override
  Widget build(BuildContext context) => MerchantPage(
    title: 'Yarım kalan fotoğraflar',
    onRefresh: () => _load(refresh: true),
    children: [
      const Text(
        'İlgili ürünü açarak yüklemeyi tamamlayabilir veya yarım kalan kaydı kaldırabilirsin.',
      ),
      if (_error != null)
        MerchantNotice(
          _error!,
          error: true,
          onRetry: () => _load(refresh: _items.isEmpty),
        ),
      if (!_loading && _error == null && _items.isEmpty)
        const MerchantNotice('Yarım kalan fotoğraf yüklemen yok.'),
      for (final i in _items)
        Card(
          child: ListTile(
            title: Text(i.productName),
            subtitle: Text('${i.photoCount} fotoğraf tamamlanmadı'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => _open(i),
          ),
        ),
      if (_loading) const Center(child: CircularProgressIndicator()),
      if (!_loading && _more && _error == null)
        OutlinedButton(onPressed: _load, child: const Text('Daha fazla ürün')),
    ],
  );
}
