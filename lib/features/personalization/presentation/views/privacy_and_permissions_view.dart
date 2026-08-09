import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/features/auth/presentation/views/legal/legal_document_views.dart';

typedef CustomerLocationPermissionLoader =
    Future<CustomerLocationPermissionStatus> Function();

enum CustomerLocationPermissionStatus {
  allowed,
  notAllowed,
  blocked,
  restricted,
}

class PrivacyAndPermissionsView extends StatefulWidget {
  const PrivacyAndPermissionsView({super.key, this.locationPermissionLoader});

  final CustomerLocationPermissionLoader? locationPermissionLoader;

  @override
  State<PrivacyAndPermissionsView> createState() =>
      _PrivacyAndPermissionsViewState();
}

class _PrivacyAndPermissionsViewState extends State<PrivacyAndPermissionsView> {
  CustomerLocationPermissionStatus? _locationStatus;
  bool _isLoading = true;
  bool _hasError = false;
  bool _isOpeningLegalDocument = false;

  CustomerLocationPermissionLoader get _permissionLoader =>
      widget.locationPermissionLoader ?? _loadLocationPermission;

  @override
  void initState() {
    super.initState();
    _readPermissionStatus();
  }

  Future<void> _readPermissionStatus() async {
    try {
      final status = await _permissionLoader();
      if (!mounted) return;

      setState(() {
        _locationStatus = status;
        _hasError = false;
        _isLoading = false;
      });
    } catch (_) {
      if (!mounted) return;

      setState(() {
        _locationStatus = null;
        _hasError = true;
        _isLoading = false;
      });
    }
  }

  Future<void> _refreshPermissionStatus() async {
    if (_isLoading) return;

    setState(() {
      _hasError = false;
      _isLoading = true;
    });
    await _readPermissionStatus();
  }

  Future<void> _openLegalDocument(WidgetBuilder builder) async {
    if (_isOpeningLegalDocument) return;
    _isOpeningLegalDocument = true;

    try {
      await Navigator.of(
        context,
      ).push<void>(MaterialPageRoute<void>(builder: builder));
    } finally {
      _isOpeningLegalDocument = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: CustomerHomeV1Tokens.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('customer-privacy-content'),
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    CustomerHomeV1Tokens.space16,
                    CustomerHomeV1Tokens.space8,
                    CustomerHomeV1Tokens.space16,
                    0,
                  ),
                  child: _PrivacyHeader(),
                ),
                const SizedBox(height: CustomerHomeV1Tokens.space12),
                Expanded(
                  child: SingleChildScrollView(
                    key: const Key('customer-privacy-scroll'),
                    padding: const EdgeInsets.fromLTRB(
                      CustomerHomeV1Tokens.space16,
                      CustomerHomeV1Tokens.space4,
                      CustomerHomeV1Tokens.space16,
                      CustomerHomeV1Tokens.space24,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _PrivacyHero(),
                        const SizedBox(height: CustomerHomeV1Tokens.space20),
                        const _SectionTitle(
                          title: 'İzinler',
                          subtitle: 'Cihazındaki mevcut izin durumu',
                        ),
                        const SizedBox(height: CustomerHomeV1Tokens.space12),
                        _LocationPermissionCard(
                          status: _locationStatus,
                          isLoading: _isLoading,
                          hasError: _hasError,
                          onRefresh: _refreshPermissionStatus,
                        ),
                        const SizedBox(height: CustomerHomeV1Tokens.space20),
                        const _SectionTitle(
                          title: 'Konumunu nasıl kullanıyoruz?',
                          subtitle: 'Kontrol her zaman sende',
                        ),
                        const SizedBox(height: CustomerHomeV1Tokens.space12),
                        const _InformationCard(
                          children: [
                            _InformationItem(
                              icon: Icons.touch_app_outlined,
                              accent: CustomerHomeV1Tokens.petrol,
                              iconBackground: CustomerHomeV1Tokens.mint,
                              title: 'Yalnızca sen istediğinde',
                              description:
                                  'Mevcut GPS konumun, yalnızca “Konumumu Kullan” dediğinde alınır. Bu sayfayı açmak konumunu almaz.',
                            ),
                            _InformationItem(
                              icon: Icons.storefront_outlined,
                              accent: CustomerHomeV1Tokens.coral,
                              iconBackground: Color(0xFFFFE4DE),
                              title: 'Yakındaki mağazaları sıralamak için',
                              description:
                                  'Anlık konumun mağazaları yakından uzağa sıralamak için kullanılır; mağazalarla paylaşılmaz ve arka planda takip edilmez.',
                            ),
                            _InformationItem(
                              icon: Icons.bookmark_outline_rounded,
                              accent: Color(0xFFA66A00),
                              iconBackground: Color(0xFFFFF0C7),
                              title: 'Kaydetmeyi sen seçersin',
                              description:
                                  'Kayıtlı Konumlarım bölümünde bir konumu özellikle kaydedersen koordinatları hesabında saklanır. Kaydettiğin konumları daha sonra silebilirsin.',
                            ),
                          ],
                        ),
                        const SizedBox(height: CustomerHomeV1Tokens.space20),
                        const _SectionTitle(
                          title: 'Uygulamadaki bilgilerin',
                          subtitle: 'Hangi amaçlarla kullanılıyor?',
                        ),
                        const SizedBox(height: CustomerHomeV1Tokens.space12),
                        const _InformationCard(
                          children: [
                            _InformationItem(
                              icon: Icons.person_outline_rounded,
                              accent: CustomerHomeV1Tokens.petrol,
                              iconBackground: CustomerHomeV1Tokens.mint,
                              title: 'Hesap bilgileri',
                              description:
                                  'Ad, e-posta ve telefon bilgilerin hesabını ve müşteri iletişimini yönetmek için kullanılır.',
                            ),
                            _InformationItem(
                              icon: Icons.chat_bubble_outline_rounded,
                              accent: Color(0xFF3F6E9C),
                              iconBackground: Color(0xFFE6F0F9),
                              title: 'Mesajlar',
                              description:
                                  'Mağazalarla yaptığın konuşmalar, mesaj geçmişine yeniden ulaşabilmen için hesabınla ilişkilendirilir.',
                            ),
                            _InformationItem(
                              icon: Icons.receipt_long_outlined,
                              accent: CustomerHomeV1Tokens.coral,
                              iconBackground: Color(0xFFFFE4DE),
                              title: 'Alışveriş ve QR doğrulamaları',
                              description:
                                  'Doğrulanan mağaza alışverişlerin, alışveriş geçmişini ve iade taleplerini göstermek için kullanılır.',
                            ),
                            _InformationItem(
                              icon: Icons.star_outline_rounded,
                              accent: Color(0xFFA66A00),
                              iconBackground: Color(0xFFFFF0C7),
                              title: 'Değerlendirmeler',
                              description:
                                  'Mağazalara verdiğin puanlar değerlendirme geçmişinde gösterilir.',
                            ),
                          ],
                        ),
                        const SizedBox(height: CustomerHomeV1Tokens.space20),
                        const _SectionTitle(
                          title: 'Yasal Metinler',
                          subtitle: 'Güncel bilgilendirme ve kullanım şartları',
                        ),
                        const SizedBox(height: CustomerHomeV1Tokens.space12),
                        _LegalDocumentTile(
                          key: const Key('privacy-kvkk-action'),
                          icon: Icons.verified_user_outlined,
                          title: 'KVKK Aydınlatma Metni',
                          subtitle:
                              'Kişisel verilerin nasıl işlendiğini incele',
                          onTap: () => _openLegalDocument(
                            (_) => const KvkkInformationView(),
                          ),
                        ),
                        const SizedBox(height: CustomerHomeV1Tokens.space8),
                        _LegalDocumentTile(
                          key: const Key('privacy-terms-action'),
                          icon: Icons.description_outlined,
                          title: 'Kullanım Koşulları',
                          subtitle:
                              'Uygulamanın kullanım kurallarını görüntüle',
                          onTap: () =>
                              _openLegalDocument((_) => const TermsOfUseView()),
                        ),
                        const SizedBox(height: CustomerHomeV1Tokens.space20),
                        const _PermissionManagementNote(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PrivacyHeader extends StatelessWidget {
  const _PrivacyHeader();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-privacy-header'),
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        border: Border.all(color: CustomerHomeV1Tokens.border),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Row(
        children: [
          Material(
            color: CustomerHomeV1Tokens.mint,
            shape: const CircleBorder(),
            child: IconButton(
              key: const Key('customer-privacy-back-button'),
              tooltip: 'Geri',
              onPressed: () => Navigator.of(context).maybePop(),
              icon: const Icon(
                Icons.arrow_back_rounded,
                color: CustomerHomeV1Tokens.petrol,
                size: 21,
              ),
            ),
          ),
          const SizedBox(width: CustomerHomeV1Tokens.space12),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Gizlilik ve İzinler',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CustomerHomeV1Tokens.navy,
                    fontSize: 19,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                SizedBox(height: CustomerHomeV1Tokens.space4),
                Text(
                  'Bilgilerin ve cihaz izinlerin senin kontrolünde',
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: CustomerHomeV1Tokens.muted,
                    fontSize: 10.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: CustomerHomeV1Tokens.mint,
              borderRadius: BorderRadius.circular(
                CustomerHomeV1Tokens.radius12,
              ),
            ),
            child: const Icon(
              Icons.privacy_tip_outlined,
              color: CustomerHomeV1Tokens.petrol,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }
}

class _PrivacyHero extends StatelessWidget {
  const _PrivacyHero();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-privacy-hero'),
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [CustomerHomeV1Tokens.petrol, Color(0xFF0E817C)],
        ),
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Stack(
        children: [
          const Positioned(
            right: -20,
            bottom: -30,
            child: Icon(
              Icons.shield_outlined,
              color: Color(0x26FFFFFF),
              size: 118,
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const CircleAvatar(
                radius: 23,
                backgroundColor: Color(0x2AFFFFFF),
                child: Icon(
                  Icons.verified_user_outlined,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space16),
              const Text(
                'Gizliliğin ve kontrolün sende',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 21,
                  height: 1.15,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.4,
                ),
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space8),
              ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 300),
                child: const Text(
                  'Hangi bilgilerin ne için kullanıldığını ve cihaz izinlerinin durumunu buradan görebilirsin.',
                  style: TextStyle(
                    color: Color(0xFFE7F3F1),
                    fontSize: 12,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});

  final String title;
  final String subtitle;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            color: CustomerHomeV1Tokens.navy,
            fontSize: 17,
            fontWeight: FontWeight.w800,
            letterSpacing: -0.2,
          ),
        ),
        const SizedBox(height: CustomerHomeV1Tokens.space4),
        Text(
          subtitle,
          style: const TextStyle(
            color: CustomerHomeV1Tokens.muted,
            fontSize: 10.5,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}

class _LocationPermissionCard extends StatelessWidget {
  const _LocationPermissionCard({
    required this.status,
    required this.isLoading,
    required this.hasError,
    required this.onRefresh,
  });

  final CustomerLocationPermissionStatus? status;
  final bool isLoading;
  final bool hasError;
  final Future<void> Function() onRefresh;

  @override
  Widget build(BuildContext context) {
    final presentation = _permissionPresentation(status);
    final accent = hasError ? CustomerHomeV1Tokens.coral : presentation.accent;
    final background = hasError
        ? const Color(0xFFFFE4DE)
        : presentation.background;

    return Semantics(
      liveRegion: true,
      child: Container(
        key: const Key('location-permission-card'),
        width: double.infinity,
        padding: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
        decoration: BoxDecoration(
          color: CustomerHomeV1Tokens.surface,
          borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
          border: Border.all(color: CustomerHomeV1Tokens.border),
          boxShadow: CustomerHomeV1Tokens.softShadow,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    color: background,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    hasError ? Icons.error_outline_rounded : presentation.icon,
                    color: accent,
                    size: 22,
                  ),
                ),
                const SizedBox(width: CustomerHomeV1Tokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Konum İzni',
                        style: TextStyle(
                          color: CustomerHomeV1Tokens.navy,
                          fontSize: 14,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: CustomerHomeV1Tokens.space4),
                      Text(
                        hasError
                            ? 'İzin durumu alınamadı'
                            : isLoading
                            ? 'İzin durumu kontrol ediliyor'
                            : presentation.label,
                        key: const Key('location-permission-status'),
                        style: TextStyle(
                          color: accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: const Key('location-permission-refresh'),
                  tooltip: 'İzin durumunu yenile',
                  onPressed: isLoading ? null : onRefresh,
                  color: CustomerHomeV1Tokens.petrol,
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                ),
              ],
            ),
            const SizedBox(height: CustomerHomeV1Tokens.space12),
            Text(
              hasError
                  ? 'İzin durumunu şu anda okuyamadık. Bu kontrol konumunu almaz ve yeni bir izin istemez.'
                  : isLoading
                  ? 'Yalnızca mevcut izin ayarı okunuyor; konumun alınmıyor.'
                  : presentation.description,
              style: const TextStyle(
                color: CustomerHomeV1Tokens.muted,
                fontSize: 11.5,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isLoading) ...[
              const SizedBox(height: CustomerHomeV1Tokens.space12),
              const ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(CustomerHomeV1Tokens.radiusPill),
                ),
                child: LinearProgressIndicator(
                  key: Key('location-permission-progress'),
                  color: CustomerHomeV1Tokens.petrol,
                  backgroundColor: CustomerHomeV1Tokens.mint,
                  minHeight: 4,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  _PermissionPresentation _permissionPresentation(
    CustomerLocationPermissionStatus? status,
  ) {
    return switch (status) {
      CustomerLocationPermissionStatus.allowed => const _PermissionPresentation(
        icon: Icons.location_on_outlined,
        label: 'İzin verildi',
        description:
            'Konum izni açık. GPS konumun yine de yalnızca sen “Konumumu Kullan” dediğinde alınır.',
        accent: CustomerHomeV1Tokens.green,
        background: Color(0xFFE4F3EA),
      ),
      CustomerLocationPermissionStatus.blocked => const _PermissionPresentation(
        icon: Icons.location_off_outlined,
        label: 'Ayarlar üzerinden kapalı',
        description:
            'Konum izni tarayıcı veya cihaz ayarlarından kapatılmış. Mağazaları konum olmadan görüntülemeye devam edebilirsin.',
        accent: CustomerHomeV1Tokens.coral,
        background: Color(0xFFFFE4DE),
      ),
      CustomerLocationPermissionStatus.restricted =>
        const _PermissionPresentation(
          icon: Icons.gpp_maybe_outlined,
          label: 'Cihaz tarafından kısıtlı',
          description:
              'Cihaz ayarları konum kullanımını kısıtlıyor. Mağazaları konum olmadan görüntülemeye devam edebilirsin.',
          accent: Color(0xFFA66A00),
          background: Color(0xFFFFF0C7),
        ),
      CustomerLocationPermissionStatus.notAllowed ||
      null => const _PermissionPresentation(
        icon: Icons.location_disabled_outlined,
        label: 'Kapalı veya henüz verilmedi',
        description:
            'Konum izni olmadan da mağazaları görebilirsin. Yakınlık sıralaması için Yakındakiler ekranından izin verebilirsin.',
        accent: CustomerHomeV1Tokens.muted,
        background: CustomerHomeV1Tokens.cream,
      ),
    };
  }
}

class _PermissionPresentation {
  const _PermissionPresentation({
    required this.icon,
    required this.label,
    required this.description,
    required this.accent,
    required this.background,
  });

  final IconData icon;
  final String label;
  final String description;
  final Color accent;
  final Color background;
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({required this.children});

  final List<_InformationItem> children;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
        border: Border.all(color: CustomerHomeV1Tokens.border),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1)
              const Divider(
                height: 1,
                indent: 64,
                color: CustomerHomeV1Tokens.border,
              ),
          ],
        ],
      ),
    );
  }
}

class _InformationItem extends StatelessWidget {
  const _InformationItem({
    required this.icon,
    required this.accent,
    required this.iconBackground,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final Color accent;
  final Color iconBackground;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: iconBackground,
              shape: BoxShape.circle,
            ),
            alignment: Alignment.center,
            child: Icon(icon, color: accent, size: 19),
          ),
          const SizedBox(width: CustomerHomeV1Tokens.space12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: CustomerHomeV1Tokens.navy,
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: CustomerHomeV1Tokens.space4),
                Text(
                  description,
                  style: const TextStyle(
                    color: CustomerHomeV1Tokens.muted,
                    fontSize: 10.5,
                    height: 1.45,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LegalDocumentTile extends StatelessWidget {
  const _LegalDocumentTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
        child: Ink(
          padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
          decoration: BoxDecoration(
            color: CustomerHomeV1Tokens.surface,
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
            border: Border.all(color: CustomerHomeV1Tokens.border),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: CustomerHomeV1Tokens.mint,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: CustomerHomeV1Tokens.petrol, size: 20),
              ),
              const SizedBox(width: CustomerHomeV1Tokens.space12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: CustomerHomeV1Tokens.navy,
                        fontSize: 12.5,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: CustomerHomeV1Tokens.space4),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: CustomerHomeV1Tokens.muted,
                        fontSize: 10.5,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: CustomerHomeV1Tokens.muted,
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PermissionManagementNote extends StatelessWidget {
  const _PermissionManagementNote();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-permission-management-note'),
      width: double.infinity,
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
        border: Border.all(color: CustomerHomeV1Tokens.border),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.settings_outlined,
            color: CustomerHomeV1Tokens.petrol,
            size: 21,
          ),
          SizedBox(width: CustomerHomeV1Tokens.space12),
          Expanded(
            child: Text(
              'Chrome’da adres çubuğundaki site ayarlarından; Android veya iOS’ta cihazının uygulama ayarlarından konum iznini yönetebilirsin.',
              style: TextStyle(
                color: CustomerHomeV1Tokens.muted,
                fontSize: 10.5,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

Future<CustomerLocationPermissionStatus> _loadLocationPermission() async {
  final status = await Permission.location.status;

  if (status.isGranted || status.isLimited) {
    return CustomerLocationPermissionStatus.allowed;
  }
  if (status.isPermanentlyDenied) {
    return CustomerLocationPermissionStatus.blocked;
  }
  if (status.isRestricted) {
    return CustomerLocationPermissionStatus.restricted;
  }
  return CustomerLocationPermissionStatus.notAllowed;
}
