import 'package:flutter/material.dart';
import '../domain/merchant_promotion.dart';
import 'merchant_promotion_center.dart';
import 'promotion_view_session.dart';

/// Capture the opener before Navigator schedules the destination's first frame.
class MerchantPromotionEntry extends StatefulWidget {
  const MerchantPromotionEntry({
    super.key,
    required this.repository,
    required this.ownerId,
    required this.shopId,
  });
  final MerchantPromotionRepository repository;
  final String ownerId, shopId;
  @override
  State<MerchantPromotionEntry> createState() => _MerchantPromotionEntryState();
}

class _MerchantPromotionEntryState extends State<MerchantPromotionEntry> {
  late PromotionViewSession _session;
  bool _opening = false;
  @override
  void initState() {
    super.initState();
    _bind();
  }

  void _bind() {
    _session = PromotionViewSession(
      repository: widget.repository,
      owner: widget.ownerId,
      onLost: () {
        if (mounted) setState(() {});
      },
    );
  }

  @override
  void didUpdateWidget(covariant MerchantPromotionEntry oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.ownerId != widget.ownerId ||
        oldWidget.shopId != widget.shopId) {
      _session.close();
      _bind();
    }
  }

  @override
  void dispose() {
    _session.close();
    super.dispose();
  }

  Future<void> _open() async {
    if (_opening || !_session.current) return;
    final origin = _session;
    final repository = widget.repository,
        shop = widget.shopId,
        owner = widget.ownerId;
    setState(() => _opening = true);
    try {
      await Navigator.of(context).push<void>(
        MaterialPageRoute(
          builder: (_) => MerchantPromotionCenter(
            repository: repository,
            shopId: shop,
            ownerId: owner,
            originIsCurrent: () =>
                mounted && identical(_session, origin) && origin.current,
          ),
        ),
      );
    } finally {
      if (mounted) setState(() => _opening = false);
    }
  }

  @override
  Widget build(BuildContext context) => !_session.current
      ? const SizedBox.shrink()
      : Card(
          child: ListTile(
            leading: const Icon(Icons.campaign_outlined),
            title: const Text('Tanıtım Merkezi'),
            subtitle: const Text(
              'İçerik hazırla, önizle ve taslaklarını yönet',
            ),
            trailing: const Icon(Icons.chevron_right),
            onTap: _opening ? null : _open,
          ),
        );
}
