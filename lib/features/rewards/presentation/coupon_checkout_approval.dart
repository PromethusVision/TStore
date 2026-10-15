import 'dart:async';
import 'package:flutter/material.dart';
import 'package:t_store/features/cart/data/qr_installation.dart';
import 'package:t_store/features/cart/domain/entities/qr_session_entity.dart';
import 'package:t_store/features/commerce_ledger/domain/commerce_ledger.dart';
import 'package:t_store/features/rewards/domain/coupon_checkout.dart';
import 'package:t_store/features/rewards/domain/reward_program.dart';

/// The customer, never the merchant, chooses the exact coupon authorization.
class CouponCheckoutApproval extends StatefulWidget {
  const CouponCheckoutApproval({
    super.key,
    required this.cartId,
    required this.repository,
    required this.onApproved,
    required this.onWithoutCoupon,
  });
  final String cartId;
  final CouponCheckoutRepository repository;
  final ValueChanged<QrSessionEntity> onApproved;
  final VoidCallback onWithoutCoupon;
  @override
  State<CouponCheckoutApproval> createState() => _CouponCheckoutApprovalState();
}

class _CouponCheckoutApprovalState extends State<CouponCheckoutApproval> {
  final _amount = TextEditingController();
  StreamSubscription<void>? _auth;
  CouponCheckoutPreview? _preview;
  String? _error;
  bool _loading = true, _busy = false, _attempted = false;
  int _generation = 0;
  String _request = newQrRequestId();
  @override
  void initState() {
    super.initState();
    _listen();
    _load();
  }

  void _listen() {
    _auth = widget.repository.sessionChanges.listen(
      (_) {
        _load();
      },
      onError: (Object _) {
        if (mounted) {
          setState(() {
            _generation++;
            _preview = null;
            _busy = false;
            _loading = false;
            _error = 'Oturum doğrulanamadı. Yeniden giriş yapın.';
          });
        }
      },
    );
  }

  @override
  void didUpdateWidget(CouponCheckoutApproval old) {
    super.didUpdateWidget(old);
    if (old.cartId != widget.cartId || old.repository != widget.repository) {
      _auth?.cancel();
      _listen();
      _load();
    }
  }

  Future<void> _load() async {
    final ticket = ++_generation;
    setState(() {
      _loading = true;
      _busy = false;
      _error = null;
      _preview = null;
      _attempted = false;
      _request = newQrRequestId();
      _amount.clear();
    });
    final result = await widget.repository.preview(widget.cartId);
    if (!mounted || ticket != _generation) return;
    result.fold(
      (error) => setState(() {
        _loading = false;
        _error = error;
      }),
      (value) {
        if (value.existingSession != null) {
          widget.onApproved(value.existingSession!);
          return;
        }
        if (!value.enabled) {
          setState(() => _loading = false);
          widget.onWithoutCoupon();
          return;
        }
        setState(() {
          _loading = false;
          _preview = value;
          final raw = value.maximum.value.toString().padLeft(3, '0');
          _amount.text =
              '${raw.substring(0, raw.length - 2)},${raw.substring(raw.length - 2)}';
        });
      },
    );
  }

  LedgerMinorUnits? get _selected {
    final value = _amount.text.trim();
    if (!RegExp(r'^(0|[1-9][0-9]{0,16})([,.][0-9]{1,2})?$').hasMatch(value)) {
      return null;
    }
    final parts = value.replaceAll(',', '.').split('.');
    final minor =
        BigInt.parse(parts.first) * BigInt.from(100) +
        BigInt.parse(parts.length == 1 ? '0' : parts[1].padRight(2, '0'));
    if (minor <= BigInt.zero ||
        _preview == null ||
        minor > _preview!.maximum.value) {
      return null;
    }
    return LedgerMinorUnits.fromWire(minor.toString());
  }

  Future<void> _approve() async {
    if (_busy || _preview == null || _selected == null) return;
    final selected = _selected!, preview = _preview!, ticket = _generation;
    setState(() {
      _busy = true;
      _attempted = true;
      _error = null;
    });
    final result = await widget.repository.approve(preview, _request, selected);
    if (!mounted || ticket != _generation) return;
    result.fold(
      (error) => setState(() {
        _busy = false;
        _error = error;
      }),
      widget.onApproved,
    );
  }

  @override
  void dispose() {
    _generation++;
    _auth?.cancel();
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Padding(
        padding: EdgeInsets.all(32),
        child: Center(child: CircularProgressIndicator()),
      );
    }
    final preview = _preview, selected = _selected;
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          'Kupon kullanımını onayla',
          style: Theme.of(context).textTheme.titleLarge,
        ),
        const SizedBox(height: 12),
        if (preview != null) ...[
          Text('Satış tutarı: ${rewardMoney(preview.sale)}'),
          Text('Kullanılabilir kupon: ${rewardMoney(preview.available)}'),
          if (preview.maximum.value > BigInt.zero) ...[
            const SizedBox(height: 12),
            TextField(
              controller: _amount,
              enabled: !_busy && !_attempted,
              keyboardType: const TextInputType.numberWithOptions(
                decimal: true,
              ),
              decoration: InputDecoration(
                labelText: 'Kullanılacak kupon (TL)',
                helperText: 'En fazla ${rewardMoney(preview.maximum)}',
              ),
              onChanged: (_) => setState(() {}),
            ),
            const SizedBox(height: 12),
            if (selected != null)
              Text(
                'Mağazada ödenecek: ${rewardMoney(LedgerMinorUnits.fromWire((preview.sale.value - selected.value).toString()))}',
              ),
            const Text(
              'Yalnızca bu alışveriş ve bu tutar için onay verirsiniz. Kupon, esnaf satışı doğruladığında kullanılır.',
            ),
            const SizedBox(height: 12),
            FilledButton(
              onPressed: _busy || selected == null ? null : _approve,
              child: Text(
                _busy
                    ? 'Onay kontrol ediliyor…'
                    : _attempted
                    ? 'Aynı onayı tekrar kontrol et'
                    : 'Kuponu onayla ve QR oluştur',
              ),
            ),
          ] else
            Text(
              preview.eligibility == 'classification_unavailable'
                  ? 'Bu sepette kupon uygunluğu doğrulanamayan ürün var. Kupon kullanımı kapalı.'
                  : preview.eligibility == 'merchant_not_accepting'
                  ? 'Bu mağazada kupon kabulü kapalı.'
                  : 'Bu alışverişte kullanılabilir kupon bulunmuyor.',
            ),
        ],
        if (_error != null)
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 12),
            child: Text(_error!, semanticsLabel: _error),
          ),
        if (!_attempted) ...[
          if (_error != null)
            TextButton(
              onPressed: _busy ? null : _load,
              child: const Text('Bilgileri yenile'),
            ),
          if (preview != null)
            TextButton(
              onPressed: _busy ? null : widget.onWithoutCoupon,
              child: const Text('Kuponsuz devam et'),
            ),
        ] else
          const Text(
            'Sonuç belirsizse aynı onayı kontrol edin. Tutarı değiştirmek için açık QR işlemini sepetten iptal edin.',
          ),
      ],
    );
  }
}
