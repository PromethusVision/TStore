import 'package:flutter/material.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:image_picker/image_picker.dart';
import 'package:t_store/features/merchant/domain/catalog_media_repository.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/presentation/merchant_widgets.dart';

class MerchantListingMedia extends StatefulWidget {
  const MerchantListingMedia({
    super.key,
    required this.repository,
    required this.access,
    required this.listingId,
    this.pickImage,
  });
  final CatalogMediaRepository repository;
  final MerchantAccess access;
  final String listingId;
  final Future<XFile?> Function()? pickImage;
  @override
  State<MerchantListingMedia> createState() => _MerchantListingMediaState();
}

class _MerchantListingMediaState extends State<MerchantListingMedia> {
  ListingMedia? _media;
  String? _error;
  bool _busy = false;
  int _epoch = 0;
  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load({bool afterMutation = false}) async {
    if (_busy && !afterMutation) return;
    final epoch = ++_epoch;
    setState(() => _busy = true);
    final r = await widget.repository.media(widget.access, widget.listingId);
    if (!mounted || epoch != _epoch) return;
    setState(() {
      _busy = false;
      r.fold((e) => _error = e, (v) {
        _media = v;
        _error = null;
      });
    });
  }

  Future<void> _mutate(Future<Either<String, void>> Function() fn) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
    });
    try {
      final r = await fn();
      if (!mounted) return;
      String? error;
      r.fold((e) => error = e, (_) => null);
      await _load(afterMutation: true);
      if (mounted && error != null) setState(() => _error = error);
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Fotoğraf işlemi tamamlanamadı. Yeniden dene.';
        });
      }
    }
  }

  Future<void> _upload() async {
    if (_busy || _media == null) return;
    setState(() => _busy = true);
    try {
      final image =
          await (widget.pickImage?.call() ??
              ImagePicker().pickImage(source: ImageSource.gallery));
      if (!mounted) return;
      if (image == null) {
        setState(() => _busy = false);
        return;
      }
      final size = await image.length();
      if (size > _media!.maxBytes) {
        setState(() {
          _busy = false;
          _error =
              'Fotoğraf en fazla ${(_media!.maxBytes / 1048576).ceil()} MB olabilir.';
        });
        return;
      }
      final bytes = await image.readAsBytes();
      if (!mounted) return;
      setState(() => _busy = false);
      await _mutate(
        () => widget.repository.upload(widget.access, widget.listingId, bytes),
      );
    } catch (_) {
      if (mounted) {
        setState(() {
          _busy = false;
          _error = 'Fotoğraf seçilemedi. Yeniden dene.';
        });
      }
    }
  }

  Future<void> _change(String action, ListingImage image) => _mutate(
    () => widget.repository.changeMedia(
      widget.access,
      widget.listingId,
      action,
      imageId: image.id,
    ),
  );
  Future<void> _move(int index, int delta) async {
    final ids = _media!.images.map((i) => i.id).toList();
    final id = ids.removeAt(index);
    ids.insert(index + delta, id);
    await _mutate(
      () => widget.repository.changeMedia(
        widget.access,
        widget.listingId,
        'reorder',
        order: ids,
      ),
    );
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: MerchantPage(
      title: 'Mağaza fotoğrafları',
      onRefresh: _load,
      children: [
        const Text(
          'Bu mağazaya ait ürün fotoğraflarını ekle. Ana fotoğraf müşterilere öncelikle gösterilir.',
        ),
        if (_error != null)
          MerchantNotice(_error!, error: true, onRetry: _load),
        if (_busy) const Center(child: CircularProgressIndicator()),
        if (_media != null) ...[
          Text(
            '${_media!.images.length} / ${_media!.maxPhotos} fotoğraf • JPEG, PNG, WebP',
          ),
          for (var i = 0; i < _media!.images.length; i++)
            Card(
              child: Column(
                children: [
                  ListTile(
                    leading: _media!.images[i].url == null
                        ? const Icon(Icons.image_outlined)
                        : Image.network(
                            _media!.images[i].url!,
                            width: 56,
                            height: 56,
                            fit: BoxFit.contain,
                            errorBuilder: (_, _, _) =>
                                const Icon(Icons.broken_image_outlined),
                          ),
                    title: Text(
                      _media!.images[i].primary
                          ? 'Ana fotoğraf'
                          : 'Fotoğraf ${i + 1}',
                    ),
                    subtitle: Text(
                      _media!.images[i].state == 'pending'
                          ? 'Yükleme tamamlanmadı'
                          : 'Yayında',
                    ),
                  ),
                  Wrap(
                    children: [
                      if (_media!.images[i].state == 'published' &&
                          !_media!.images[i].primary)
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () => _change('primary', _media!.images[i]),
                          child: const Text('Ana fotoğraf yap'),
                        ),
                      if (_media!.images[i].state == 'pending')
                        TextButton(
                          onPressed: _busy
                              ? null
                              : () => _change('publish', _media!.images[i]),
                          child: const Text('Yüklemeyi tamamla'),
                        ),
                      IconButton(
                        tooltip: 'Yukarı taşı',
                        onPressed: _busy || i == 0 ? null : () => _move(i, -1),
                        icon: const Icon(Icons.arrow_upward),
                      ),
                      IconButton(
                        tooltip: 'Aşağı taşı',
                        onPressed: _busy || i == _media!.images.length - 1
                            ? null
                            : () => _move(i, 1),
                        icon: const Icon(Icons.arrow_downward),
                      ),
                      TextButton(
                        onPressed: _busy
                            ? null
                            : () => _change('retire', _media!.images[i]),
                        child: const Text('Kaldır'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          FilledButton.icon(
            onPressed: _busy || _media!.images.length >= _media!.maxPhotos
                ? null
                : _upload,
            icon: const Icon(Icons.add_photo_alternate_outlined),
            label: const Text('Fotoğraf ekle'),
          ),
        ],
      ],
    ),
  );
}
