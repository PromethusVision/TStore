import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

const shopProfilePhotoBucket = 'shop-profile-media';

/// Private Storage URLs are short lived and are never persisted in shop rows.
class ShopProfilePhoto extends StatefulWidget {
  const ShopProfilePhoto({
    super.key,
    required this.path,
    required this.fallback,
    this.size = 64,
    this.resolve,
  });
  final String? path;
  final Widget fallback;
  final double size;
  final Future<String> Function(String)? resolve;
  @override
  State<ShopProfilePhoto> createState() => _ShopProfilePhotoState();
}

class _ShopProfilePhotoState extends State<ShopProfilePhoto> {
  Future<String>? _url;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(covariant ShopProfilePhoto oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.path != widget.path || oldWidget.resolve != widget.resolve) {
      _load();
    }
  }

  void _load() {
    final path = widget.path;
    _url = path == null ? null : _resolve(path);
  }

  Future<String> _resolve(String path) async => widget.resolve != null
      ? widget.resolve!(path)
      : Supabase.instance.client.storage
            .from(shopProfilePhotoBucket)
            .createSignedUrl(path, 300);
  @override
  Widget build(BuildContext context) => SizedBox(
    width: widget.size,
    height: widget.size,
    child: ClipOval(
      child: _url == null
          ? widget.fallback
          : FutureBuilder<String>(
              key: ValueKey(widget.path),
              future: _url,
              builder: (context, snapshot) {
                if (!snapshot.hasData) return widget.fallback;
                return Image.network(
                  snapshot.data!,
                  fit: BoxFit.cover,
                  errorBuilder: (_, _, _) => widget.fallback,
                );
              },
            ),
    ),
  );
}
