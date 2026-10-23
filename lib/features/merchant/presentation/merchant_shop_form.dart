import 'package:t_store/features/merchant/presentation/merchant_workspace_continuation.dart';
import 'package:dartz/dartz.dart' hide State;
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import 'dart:ui' as ui;
import 'package:geolocator/geolocator.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:t_store/features/merchant/data/merchant_shop_location.dart';
import 'package:t_store/features/merchant/presentation/merchant_opening_hours.dart';
import 'package:t_store/features/shop/domain/entities/shop_opening_hours.dart';
import 'package:t_store/features/shop/presentation/widgets/shop_profile_photo.dart';
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
    this.pickImage,
    this.loadPosition,
    this.openMap,
  });
  final MerchantRepository repository;
  final MerchantAccess access;
  final VoidCallback onSaved;
  final VoidCallback? onSignOut;
  final Future<XFile?> Function()? pickImage;
  final Future<Position> Function()? loadPosition;
  final Future<bool> Function(Uri)? openMap;
  @override
  State<MerchantShopForm> createState() => _MerchantShopFormState();
}

class _MerchantShopFormState extends State<MerchantShopForm>
    with MerchantWorkspaceContinuation<MerchantShopForm> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name, _description, _phone, _address;
  late Map<String, dynamic> _hours;
  double? _latitude, _longitude;
  Position? _position;
  String? _photoPath;
  Uint8List? _photoPreview;
  bool _preparing = false;
  late MerchantAccess _access;
  late final MerchantEditRecovery<ShopEntity> _recovery;
  late Map<String, dynamic> _baseline;
  MerchantShopDraft? _submitted;
  bool get _saving => _recovery.busy;
  bool get _locked => _saving || _preparing || _recovery.needsReview;
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
    _hours = Map<String, dynamic>.from(shop?.openingHours ?? {});
    _latitude = shop?.latitude;
    _longitude = shop?.longitude;
    _photoPath = shop?.photoPath;
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
    for (final c in [_name, _description, _phone, _address]) {
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
    latitude: s.latitude,
    longitude: s.longitude,
    photoPath: s.photoPath,
    profileDetails: true,
  ).toPayload();

  bool _matches(ShopEntity current) =>
      _submitted != null &&
      merchantValuesEqual(_submitted!.toPayload(), _payload(current));

  void _review(ShopEntity? current, {required bool keepDraft}) {
    if (!mounted || !workspaceCurrent) return;
    if (current == null && _access.shop != null) return;
    _access = MerchantAccess(user: widget.access.user, shop: current);
    _baseline = current == null
        ? const MerchantShopDraft(name: '', profileDetails: true).toPayload()
        : _payload(current);
    if (!keepDraft) {
      _name.text = current?.name ?? '';
      _description.text = current?.description ?? '';
      _phone.text = current?.phone ?? '';
      _address.text = current?.address ?? '';
      _hours = Map<String, dynamic>.from(current?.openingHours ?? {});
      _latitude = current?.latitude;
      _longitude = current?.longitude;
      _position = null;
      _photoPath = current?.photoPath;
      _photoPreview = null;
      _baseline = _draft.toPayload();
    }
    _error = null;
    _recovery.reviewed();
  }

  @override
  void dispose() {
    _recovery.dispose();
    for (final c in [_name, _description, _phone, _address]) {
      c.dispose();
    }
    super.dispose();
  }

  MerchantShopDraft get _draft {
    return MerchantShopDraft(
      name: _name.text,
      description: _description.text,
      phone: _phone.text,
      address: _address.text,
      openingHours: _hours,
      latitude: _latitude,
      longitude: _longitude,
      photoPath: _photoPath,
      profileDetails: true,
    );
  }

  Future<void> _pickPhoto() async {
    final repository = widget.repository;
    if (_locked ||
        !workspaceCurrent ||
        repository is! MerchantShopPhotoRepository) {
      return;
    }
    setState(() {
      _preparing = true;
      _error = null;
    });
    try {
      final image =
          await (widget.pickImage?.call() ??
              ImagePicker().pickImage(
                source: ImageSource.gallery,
                maxWidth: 1024,
                maxHeight: 1024,
                imageQuality: 85,
              ));
      if (!workspaceCurrent || image == null) return;
      if (await image.length() > shopPhotoMaxBytes) {
        throw const FormatException('Fotoğraf en fazla 5 MB olabilir.');
      }
      if (!workspaceCurrent) return;
      final source = await image.readAsBytes();
      if (!workspaceCurrent) return;
      if (source.length > shopPhotoMaxBytes) {
        throw const FormatException('Fotoğraf en fazla 5 MB olabilir.');
      }
      // Re-encode pixels to remove camera/GPS metadata; limit decoded dimensions.
      final buffer = await ui.ImmutableBuffer.fromUint8List(source);
      ui.ImageDescriptor? descriptor;
      ui.Codec? codec;
      ui.Image? decoded;
      late Uint8List bytes;
      try {
        descriptor = await ui.ImageDescriptor.encoded(buffer);
        final scale =
            1024 /
            (descriptor.width > descriptor.height
                ? descriptor.width
                : descriptor.height);
        codec = await descriptor.instantiateCodec(
          targetWidth: scale < 1
              ? (descriptor.width * scale).round().clamp(1, 1024)
              : descriptor.width,
          targetHeight: scale < 1
              ? (descriptor.height * scale).round().clamp(1, 1024)
              : descriptor.height,
        );
        decoded = (await codec.getNextFrame()).image;
        bytes = (await decoded.toByteData(
          format: ui.ImageByteFormat.png,
        ))!.buffer.asUint8List();
      } finally {
        decoded?.dispose();
        codec?.dispose();
        descriptor?.dispose();
        buffer.dispose();
      }
      if (!workspaceCurrent) return;
      final result = await (repository as MerchantShopPhotoRepository)
          .stageShopPhoto(_access, bytes);
      if (!workspaceCurrent) return;
      result.fold(
        (error) =>
            setState(() => _error = '$error Mevcut fotoğraf değiştirilmedi.'),
        (path) => setState(() {
          _photoPath = path;
          _photoPreview = bytes;
        }),
      );
    } on FormatException catch (e) {
      if (workspaceCurrent) setState(() => _error = e.message);
    } catch (_) {
      if (workspaceCurrent) {
        setState(
          () => _error =
              'Fotoğraf hazırlanamadı. Mevcut fotoğraf değiştirilmedi; yeniden dene.',
        );
      }
    } finally {
      if (workspaceCurrent) setState(() => _preparing = false);
    }
  }

  Future<void> _locate() async {
    if (_locked || !workspaceCurrent) return;
    setState(() {
      _preparing = true;
      _error = null;
      _position = null;
    });
    try {
      final position =
          await (widget.loadPosition?.call() ?? loadMerchantShopPosition());
      if (!workspaceCurrent) return;
      final age = DateTime.now().difference(position.timestamp);
      if (!position.latitude.isFinite ||
          !position.longitude.isFinite ||
          position.latitude.abs() > 90 ||
          position.longitude.abs() > 180 ||
          !position.accuracy.isFinite ||
          position.accuracy < 0 ||
          position.accuracy > 100 ||
          age > const Duration(minutes: 2) ||
          age < const Duration(minutes: -1)) {
        throw const FormatException(
          'Konum yeterince kesin bulunamadı. Mağazanın girişinde yeniden dene.',
        );
      }
      setState(() => _position = position);
    } on FormatException catch (e) {
      if (workspaceCurrent) setState(() => _error = e.message);
    } on TimeoutException {
      if (workspaceCurrent) {
        setState(
          () => _error = 'Konum zamanında alınamadı. Açık alanda yeniden dene.',
        );
      }
    } catch (_) {
      if (workspaceCurrent) {
        setState(
          () => _error =
              'Konum alınamadı. Konum iznini ve telefon ayarlarını kontrol et.',
        );
      }
    } finally {
      if (workspaceCurrent) setState(() => _preparing = false);
    }
  }

  Future<void> _map(double lat, double lng) async {
    if (!workspaceCurrent || _locked) return;
    final url = Uri.https('www.google.com', '/maps/search/', {
      'api': '1',
      'query': '$lat,$lng',
    });
    try {
      final opened =
          await (widget.openMap?.call(url) ??
              launchUrl(url, mode: LaunchMode.externalApplication));
      if (!opened && workspaceCurrent) {
        setState(
          () =>
              _error = 'Harita açılamadı. Konumu yeniden kontrol edebilirsin.',
        );
      }
    } catch (_) {
      if (workspaceCurrent) {
        setState(
          () =>
              _error = 'Harita açılamadı. Konumu yeniden kontrol edebilirsin.',
        );
      }
    }
  }

  Widget _photo() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('Mağaza fotoğrafı', style: Theme.of(context).textTheme.titleMedium),
      Center(
        child: _photoPreview == null
            ? ShopProfilePhoto(
                path: _photoPath,
                size: 96,
                fallback: const Icon(Icons.storefront_outlined, size: 48),
              )
            : ClipOval(
                child: Image.memory(
                  _photoPreview!,
                  width: 96,
                  height: 96,
                  fit: BoxFit.cover,
                ),
              ),
      ),
      if (_access.shop == null)
        const Text('Fotoğraf eklemek için önce mağazanı kaydet.'),
      if (_access.shop != null &&
          widget.repository is MerchantShopPhotoRepository)
        TextButton.icon(
          onPressed: _locked ? null : _pickPhoto,
          icon: const Icon(Icons.add_photo_alternate_outlined),
          label: Text(
            _photoPath == null ? 'Fotoğraf ekle' : 'Fotoğrafı değiştir',
          ),
        ),
      if (_photoPath != null)
        TextButton(
          onPressed: _locked
              ? null
              : () {
                  if (workspaceCurrent) {
                    setState(() {
                      _photoPath = null;
                      _photoPreview = null;
                    });
                  }
                },
          child: const Text('Fotoğrafı kaldır'),
        ),
      const Text('Fotoğraf değişikliği Mağazayı kaydet ile yayımlanır.'),
      const SizedBox(height: 20),
    ],
  );

  Widget _location() => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('Mağaza konumu', style: Theme.of(context).textTheme.titleMedium),
      const Text(
        'Bu işlemi mağazanın girişindeyken yap. Açık adres tek başına haritadaki konumu belirlemez.',
      ),
      Text(
        _latitude == null || _longitude == null
            ? 'Konum belirtilmedi.'
            : 'Seçili konum: ${_latitude!.toStringAsFixed(6)}, ${_longitude!.toStringAsFixed(6)}',
      ),
      OutlinedButton.icon(
        onPressed: _locked ? null : _locate,
        icon: const Icon(Icons.my_location),
        label: const Text('Mağazadayım, konumumu al'),
      ),
      if (_latitude != null && _longitude != null && _position == null)
        TextButton(
          onPressed: _locked ? null : () => _map(_latitude!, _longitude!),
          child: const Text('Seçili konumu haritada gör'),
        ),
      if (_position case final p?) ...[
        Text(
          'Bulunan konum: ${p.latitude.toStringAsFixed(6)}, ${p.longitude.toStringAsFixed(6)} · Yaklaşık ${p.accuracy.ceil()} m hassasiyet',
        ),
        TextButton(
          onPressed: _locked ? null : () => _map(p.latitude, p.longitude),
          child: const Text('Bulunan konumu haritada kontrol et'),
        ),
        FilledButton.tonal(
          onPressed: _locked
              ? null
              : () {
                  if (workspaceCurrent) {
                    setState(() {
                      _latitude = p.latitude;
                      _longitude = p.longitude;
                      _position = null;
                    });
                  }
                },
          child: const Text('Bu konum mağazama ait'),
        ),
        TextButton(
          onPressed: _locked
              ? null
              : () {
                  if (workspaceCurrent) setState(() => _position = null);
                },
          child: const Text('Bu konumu kullanma'),
        ),
      ],
      if (_latitude != null || _longitude != null)
        TextButton(
          onPressed: _locked
              ? null
              : () {
                  if (workspaceCurrent) {
                    setState(() {
                      _latitude = null;
                      _longitude = null;
                      _position = null;
                    });
                  }
                },
          child: const Text('Kayıtlı konumu kaldır'),
        ),
      const SizedBox(height: 20),
    ],
  );

  Future<void> _save() async {
    if (!workspaceCurrent || _locked || !merchantValidateForm(_form)) return;
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
    child: MerchantInput(
      labelText: label,
      builder: (decoration) => TextFormField(
        controller: controller,
        enabled: !_locked,
        maxLines: lines,
        keyboardType: keyboard,
        maxLength: max,
        decoration: decoration,
        validator: (v) =>
            required && (v ?? '').trim().isEmpty ? 'Bu alanı doldurun.' : null,
      ),
    ),
  );
  @override
  Widget build(BuildContext context) => MerchantDraftGuard(
    uncertain: _recovery.needsReview,
    dirty:
        _recovery.needsReview ||
        !merchantValuesEqual(_baseline, _draft.toPayload()),
    busy: _saving || _preparing,
    child: MerchantPage(
      title: widget.access.shop == null ? 'Mağazanı oluştur' : 'Mağaza profili',
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
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
                matches:
                    _recovery.current != null && _matches(_recovery.current!),
                summary: _recovery.current == null
                    ? 'Mağaza kaydı bulunamadı.'
                    : '${_recovery.current!.name}\n'
                          '${_recovery.current!.description ?? ''}\n'
                          '${_recovery.current!.phone ?? ''}\n'
                          '${_recovery.current!.address ?? ''}\n'
                          '${ShopOpeningHours.format(_recovery.current!.openingHours)}\n'
                          'Konum: ${_recovery.current!.latitude ?? 'Belirtilmedi'}, ${_recovery.current!.longitude ?? ''}\n'
                          'Fotoğraf: ${_recovery.current!.photoPath == null ? 'Yok' : 'Var'}',
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
            if (_recovery.needsReview &&
                _recovery.loaded &&
                _recovery.current?.photoPath != null) ...[
              const Text('Güncel kayıttaki mağaza fotoğrafı'),
              Align(
                alignment: Alignment.centerLeft,
                child: ShopProfilePhoto(
                  path: _recovery.current!.photoPath,
                  fallback: const Icon(Icons.storefront_outlined),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Form(
              key: _form,
              child: Column(
                children: [
                  _field('Mağaza adı', _name, required: true),
                  _photo(),
                  _field(
                    'Mağaza açıklaması',
                    _description,
                    max: 2000,
                    lines: 3,
                  ),
                  _field(
                    'Telefon',
                    _phone,
                    max: 30,
                    keyboard: TextInputType.phone,
                  ),
                  _field('Adres', _address, max: 500, lines: 3),
                  _location(),
                  MerchantOpeningHours(
                    value: _hours,
                    enabled: !_locked,
                    isCurrent: () => workspaceCurrent,
                    onChanged: (hours) {
                      if (workspaceCurrent && !_locked) {
                        setState(() => _hours = hours);
                      }
                    },
                  ),
                ],
              ),
            ),
            FilledButton(
              onPressed: _locked ? null : _save,
              child: Text(
                _preparing
                    ? 'Hazırlanıyor…'
                    : _saving
                    ? 'Kaydediliyor…'
                    : 'Mağazayı kaydet',
              ),
            ),
            if (widget.onSignOut != null)
              TextButton(
                onPressed: _saving || _preparing ? null : widget.onSignOut,
                child: const Text('Çıkış yap'),
              ),
          ],
        ),
      ],
    ),
  );
}
