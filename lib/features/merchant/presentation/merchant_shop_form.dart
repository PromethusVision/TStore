import 'package:flutter/material.dart';
import 'package:t_store/features/merchant/domain/merchant_repository.dart';
import 'package:t_store/features/merchant/presentation/merchant_widgets.dart';

class MerchantShopForm extends StatefulWidget {
  const MerchantShopForm({
    super.key,
    required this.repository,
    required this.access,
    required this.onSaved,
    this.onSignOut,
  });
  final MerchantRepository repository;
  final MerchantAccess access;
  final VoidCallback onSaved;
  final VoidCallback? onSignOut;
  @override
  State<MerchantShopForm> createState() => _MerchantShopFormState();
}

class _MerchantShopFormState extends State<MerchantShopForm> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name,
      _description,
      _phone,
      _address,
      _week,
      _saturday,
      _sunday;
  bool _saving = false;
  String? _error;
  @override
  void initState() {
    super.initState();
    final shop = widget.access.shop;
    _name = TextEditingController(text: shop?.name);
    _description = TextEditingController(text: shop?.description);
    _phone = TextEditingController(text: shop?.phone);
    _address = TextEditingController(text: shop?.address);
    final h = shop?.openingHours ?? {};
    _week = TextEditingController(
      text: (h['mon_fri'] ?? h['mon_sat'])?.toString(),
    );
    _saturday = TextEditingController(
      text: (h['sat'] ?? h['mon_sat'])?.toString(),
    );
    _sunday = TextEditingController(text: h['sun']?.toString());
  }

  @override
  void dispose() {
    for (final c in [
      _name,
      _description,
      _phone,
      _address,
      _week,
      _saturday,
      _sunday,
    ]) {
      c.dispose();
    }
    super.dispose();
  }

  Future<void> _save() async {
    if (_saving || !_form.currentState!.validate()) return;
    final hours = Map<String, dynamic>.from(
      widget.access.shop?.openingHours ?? {},
    )..remove('mon_sat');
    for (final entry in {
      'mon_fri': _week.text,
      'sat': _saturday.text,
      'sun': _sunday.text,
    }.entries) {
      if (entry.value.trim().isEmpty) {
        hours.remove(entry.key);
      } else {
        hours[entry.key] = entry.value.trim();
      }
    }
    setState(() {
      _saving = true;
      _error = null;
    });
    try {
      final result = await widget.repository.saveShop(
        widget.access,
        MerchantShopDraft(
          name: _name.text,
          description: _description.text,
          phone: _phone.text,
          address: _address.text,
          openingHours: hours,
        ),
      );
      if (!mounted) return;
      setState(() => _saving = false);
      result.fold((e) => setState(() => _error = e), (_) {
        merchantSaved(context, 'Mağaza bilgileri kaydedildi.');
        widget.onSaved();
      });
    } catch (_) {
      if (mounted) {
        setState(() {
          _saving = false;
          _error = 'Kayıt tamamlanamadı. Tekrar deneyin.';
        });
      }
    }
  }

  Widget _field(
    String label,
    TextEditingController controller, {
    int max = 120,
    bool required = false,
    int lines = 1,
    TextInputType? keyboard,
  }) => Padding(
    padding: const EdgeInsets.only(bottom: 16),
    child: TextFormField(
      controller: controller,
      enabled: !_saving,
      maxLines: lines,
      keyboardType: keyboard,
      maxLength: max,
      decoration: InputDecoration(labelText: label),
      validator: (v) =>
          required && (v ?? '').trim().isEmpty ? 'Bu alanı doldurun.' : null,
    ),
  );
  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_saving,
    child: MerchantPage(
      title: widget.access.shop == null ? 'Mağazanı oluştur' : 'Mağaza profili',
      children: [
        if (widget.access.shop == null)
          const MerchantNotice(
            'Esnaf yetkin doğrulandı. Müşterilerin göreceği mağaza bilgilerini ekle.',
          ),
        if (_error != null) MerchantNotice(_error!, error: true),
        Form(
          key: _form,
          child: Column(
            children: [
              _field('Mağaza adı', _name, required: true),
              _field('Mağaza açıklaması', _description, max: 2000, lines: 3),
              _field('Telefon', _phone, max: 30, keyboard: TextInputType.phone),
              _field('Adres', _address, max: 500, lines: 3),
              _field('Hafta içi çalışma saatleri', _week, max: 80),
              _field('Cumartesi çalışma saatleri', _saturday, max: 80),
              _field('Pazar çalışma saatleri', _sunday, max: 80),
            ],
          ),
        ),
        FilledButton(
          onPressed: _saving ? null : _save,
          child: Text(_saving ? 'Kaydediliyor…' : 'Mağazayı kaydet'),
        ),
        if (widget.onSignOut != null)
          TextButton(
            onPressed: _saving ? null : widget.onSignOut,
            child: const Text('Çıkış yap'),
          ),
      ],
    ),
  );
}
