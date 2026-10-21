import 'package:t_store/features/merchant/presentation/merchant_workspace_continuation.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'package:t_store/features/merchant/presentation/merchant_edit_recovery.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
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

class _MerchantShopFormState extends State<MerchantShopForm>
    with MerchantWorkspaceContinuation<MerchantShopForm> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name,
      _description,
      _phone,
      _address,
      _week,
      _saturday,
      _sunday;
  late MerchantAccess _access;
  late final MerchantEditRecovery<ShopEntity> _recovery;
  late Map<String, dynamic> _baseline;
  MerchantShopDraft? _submitted;
  bool get _saving => _recovery.busy;
  bool get _locked => _saving || _recovery.needsReview;
  String? _error;
  @override
  void initState() {
    super.initState();
    _access = widget.access;
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
    _baseline = _draft.toPayload();
    _recovery = MerchantEditRecovery(
      isCurrent: () => workspaceCurrent,
      read: () async {
        final result = await widget.repository.loadAccess();
        return result.flatMap((fresh) {
          if (fresh == null ||
              fresh.user.id != widget.access.user.id ||
              !fresh.hasRole ||
              (fresh.shop != null && !fresh.canManage) ||
              (widget.access.shop != null &&
                  fresh.shop?.id != widget.access.shop!.id)) {
            return const Left(merchantAccessDenied);
          }
          return Right(fresh.shop);
        });
      },
    )..addListener(_changed);
    for (final c in [
      _name,
      _description,
      _phone,
      _address,
      _week,
      _saturday,
      _sunday,
    ]) {
      c.addListener(_changed);
    }
  }

  void _changed() {
    if (workspaceCurrent) setState(() {});
  }

  Map<String, dynamic> _payload(ShopEntity s) => MerchantShopDraft(
    name: s.name,
    description: s.description ?? '',
    phone: s.phone ?? '',
    address: s.address ?? '',
    openingHours: s.openingHours,
  ).toPayload();

  bool _matches(ShopEntity current) =>
      _submitted != null &&
      merchantValuesEqual(_submitted!.toPayload(), _payload(current));

  void _review(ShopEntity? current, {required bool keepDraft}) {
    if (!mounted || !workspaceCurrent) return;
    if (current == null && _access.shop != null) return;
    _access = MerchantAccess(user: widget.access.user, shop: current);
    _baseline = current == null
        ? const MerchantShopDraft(name: '').toPayload()
        : _payload(current);
    if (!keepDraft) {
      _name.text = current?.name ?? '';
      _description.text = current?.description ?? '';
      _phone.text = current?.phone ?? '';
      _address.text = current?.address ?? '';
      final hours = current?.openingHours ?? {};
      _week.text = (hours['mon_fri'] ?? hours['mon_sat'])?.toString() ?? '';
      _saturday.text = (hours['sat'] ?? hours['mon_sat'])?.toString() ?? '';
      _sunday.text = hours['sun']?.toString() ?? '';
      _baseline = _draft.toPayload();
    }
    _error = null;
    _recovery.reviewed();
  }

  @override
  void dispose() {
    _recovery.dispose();
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

  MerchantShopDraft get _draft {
    final hours = Map<String, dynamic>.from(_access.shop?.openingHours ?? {})
      ..remove('mon_sat');
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
    return MerchantShopDraft(
      name: _name.text,
      description: _description.text,
      phone: _phone.text,
      address: _address.text,
      openingHours: hours,
    );
  }

  Future<void> _save() async {
    if (!workspaceCurrent || _locked || !_form.currentState!.validate()) return;
    final draft = _draft;
    if (draft.error != null) {
      setState(() => _error = draft.error);
      return;
    }
    _error = null;
    _submitted = draft;
    FocusScope.of(context).unfocus();
    final saved = await _recovery.save(
      () => widget.repository.saveShop(_access, draft),
    );
    if (!mounted || !workspaceCurrent) return;
    if (saved != null) {
      merchantSaved(context, 'Mağaza bilgileri kaydedildi.');
      widget.onSaved();
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
      enabled: !_locked,
      maxLines: lines,
      keyboardType: keyboard,
      maxLength: max,
      decoration: InputDecoration(labelText: label),
      validator: (v) =>
          required && (v ?? '').trim().isEmpty ? 'Bu alanı doldurun.' : null,
    ),
  );
  @override
  Widget build(BuildContext context) => MerchantDraftGuard(
    uncertain: _recovery.needsReview,
    dirty:
        _recovery.needsReview ||
        !merchantValuesEqual(_baseline, _draft.toPayload()),
    busy: _saving,
    child: MerchantPage(
      title: widget.access.shop == null ? 'Mağazanı oluştur' : 'Mağaza profili',
      children: [
        if (widget.access.shop == null)
          const MerchantNotice(
            'Esnaf yetkin doğrulandı. Müşterilerin göreceği mağaza bilgilerini ekle.',
          ),
        if (_error != null) MerchantNotice(_error!, error: true),
        if (_recovery.error != null)
          MerchantNotice(_recovery.error!, error: true),
        if (_recovery.needsReview)
          MerchantRecoveryPanel(
            busy: _saving,
            loaded: _recovery.loaded,
            matches: _recovery.current != null && _matches(_recovery.current!),
            summary: _recovery.current == null
                ? 'Mağaza kaydı bulunamadı.'
                : '${_recovery.current!.name}\n'
                      '${_recovery.current!.description ?? ''}\n'
                      '${_recovery.current!.phone ?? ''}\n'
                      '${_recovery.current!.address ?? ''}\n'
                      'Hafta içi: ${_recovery.current!.openingHours['mon_fri'] ?? _recovery.current!.openingHours['mon_sat'] ?? 'Belirtilmedi'}\n'
                      'Cumartesi: ${_recovery.current!.openingHours['sat'] ?? _recovery.current!.openingHours['mon_sat'] ?? 'Belirtilmedi'}\n'
                      'Pazar: ${_recovery.current!.openingHours['sun'] ?? 'Belirtilmedi'}',
            onReload: _recovery.reload,
            onUseCurrent: _recovery.current == null
                ? null
                : () {
                    if (!mounted || !workspaceCurrent) return;
                    if (_matches(_recovery.current!)) {
                      widget.onSaved();
                    } else {
                      _review(_recovery.current, keepDraft: false);
                    }
                  },
            onKeepDraft: _recovery.current == null && _access.shop != null
                ? null
                : () => _review(_recovery.current, keepDraft: true),
          ),
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
          onPressed: _locked ? null : _save,
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
