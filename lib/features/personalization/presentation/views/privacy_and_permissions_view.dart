import 'package:flutter/material.dart';
import 'package:t_store/core/ui/components/esnaftavar_scaffold.dart';
import 'package:t_store/core/ui/components/esnaftavar_section_header.dart';
import 'package:t_store/features/personalization/presentation/widgets/account_page_header.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
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
    return EsnaftaVarScaffold(
      safeAreaTop: false,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('customer-privacy-content'),
            constraints: const BoxConstraints(maxWidth: 430),
            child: Column(
              children: [
                const Padding(
                  padding: EdgeInsets.fromLTRB(
                    EsnaftaVarSpacing.md,
                    EsnaftaVarSpacing.xs,
                    EsnaftaVarSpacing.md,
                    0,
                  ),
                  child: _PrivacyHeader(),
                ),
                const SizedBox(height: EsnaftaVarSpacing.sm),
                Expanded(
                  child: SingleChildScrollView(
                    key: const Key('customer-privacy-scroll'),
                    padding: const EdgeInsets.fromLTRB(
                      EsnaftaVarSpacing.md,
                      EsnaftaVarSpacing.xxs,
                      EsnaftaVarSpacing.md,
                      EsnaftaVarSpacing.xl,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const _PrivacyHero(),
                        const SizedBox(height: EsnaftaVarSpacing.lg),
                        const _SectionTitle(
                          title: 'İzinler',
                          subtitle: 'Cihazındaki mevcut izin durumu',
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.sm),
                        _LocationPermissionCard(
                          status: _locationStatus,
                          isLoading: _isLoading,
                          hasError: _hasError,
                          onRefresh: _refreshPermissionStatus,
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.lg),
                        const _SectionTitle(
                          title: 'Konumunu nasıl kullanıyoruz?',
                          subtitle: 'Kontrol her zaman sende',
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.sm),
                        const _InformationCard(
                          children: [
                            _InformationItem(
                              icon: Icons.touch_app_outlined,
                              accent: EsnaftaVarColors.primary,
                              iconBackground: EsnaftaVarColors.primarySoft,
                              title: 'Yalnızca sen istediğinde',
                              description:
                                  'Mevcut GPS konumun, yalnızca “Konumumu Kullan” dediğinde alınır. Bu sayfayı açmak konumunu almaz.',
                            ),
                            _InformationItem(
                              icon: Icons.storefront_outlined,
                              accent: EsnaftaVarColors.accent,
                              iconBackground: EsnaftaVarColors.accentSoft,
                              title: 'Yakındaki mağazaları sıralamak için',
                              description:
                                  'Anlık konumun mağazaları yakından uzağa sıralamak için kullanılır; mağazalarla paylaşılmaz ve arka planda takip edilmez.',
                            ),
                            _InformationItem(
                              icon: Icons.bookmark_outline_rounded,
                              accent: EsnaftaVarColors.warning,
                              iconBackground: EsnaftaVarColors.warningSoft,
                              title: 'Kaydetmeyi sen seçersin',
                              description:
                                  'Kayıtlı Konumlarım bölümünde bir konumu özellikle kaydedersen koordinatları hesabında saklanır. Kaydettiğin konumları daha sonra silebilirsin.',
                            ),
                          ],
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.lg),
                        const _SectionTitle(
                          title: 'Uygulamadaki bilgilerin',
                          subtitle: 'Hangi amaçlarla kullanılıyor?',
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.sm),
                        const _InformationCard(
                          children: [
                            _InformationItem(
                              icon: Icons.person_outline_rounded,
                              accent: EsnaftaVarColors.primary,
                              iconBackground: EsnaftaVarColors.primarySoft,
                              title: 'Hesap bilgileri',
                              description:
                                  'Ad, e-posta ve telefon bilgilerin hesabını ve müşteri iletişimini yönetmek için kullanılır.',
                            ),
                            _InformationItem(
                              icon: Icons.chat_bubble_outline_rounded,
                              accent: EsnaftaVarColors.primary,
                              iconBackground: EsnaftaVarColors.primarySoft,
                              title: 'Mesajlar',
                              description:
                                  'Mağazalarla yaptığın konuşmalar, mesaj geçmişine yeniden ulaşabilmen için hesabınla ilişkilendirilir.',
                            ),
                            _InformationItem(
                              icon: Icons.receipt_long_outlined,
                              accent: EsnaftaVarColors.accent,
                              iconBackground: EsnaftaVarColors.accentSoft,
                              title: 'Alışveriş ve QR doğrulamaları',
                              description:
                                  'Doğrulanan mağaza alışverişlerin, alışveriş geçmişini ve iade taleplerini göstermek için kullanılır.',
                            ),
                            _InformationItem(
                              icon: Icons.star_outline_rounded,
                              accent: EsnaftaVarColors.warning,
                              iconBackground: EsnaftaVarColors.warningSoft,
                              title: 'Değerlendirmeler',
                              description:
                                  'Mağazalara verdiğin puanlar değerlendirme geçmişinde gösterilir.',
                            ),
                          ],
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.lg),
                        const _SectionTitle(
                          title: 'Yasal Metinler',
                          subtitle: 'Güncel bilgilendirme ve kullanım şartları',
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.sm),
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
                        const SizedBox(height: EsnaftaVarSpacing.xs),
                        _LegalDocumentTile(
                          key: const Key('privacy-terms-action'),
                          icon: Icons.description_outlined,
                          title: 'Kullanım Koşulları',
                          subtitle:
                              'Uygulamanın kullanım kurallarını görüntüle',
                          onTap: () =>
                              _openLegalDocument((_) => const TermsOfUseView()),
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.lg),
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
  Widget build(BuildContext context) => const AccountPageHeader(
    key: Key('customer-privacy-header'),
    backKey: Key('customer-privacy-back-button'),
    title: 'Gizlilik ve İzinler',
    subtitle: 'Bilgilerin ve cihaz izinlerin senin kontrolünde',
  );
}

class _PrivacyHero extends StatelessWidget {
  const _PrivacyHero();
  @override
  Widget build(BuildContext context) => Container(
    key: const Key('customer-privacy-hero'),
    width: double.infinity,
    padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
    decoration: BoxDecoration(
      color: EsnaftaVarColors.primarySoft,
      borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Gizliliğin ve kontrolün sende',
          style: Theme.of(
            context,
          ).textTheme.titleMedium?.copyWith(color: EsnaftaVarColors.primary),
        ),
        const SizedBox(height: EsnaftaVarSpacing.xs),
        Text(
          'Hangi bilgilerin ne için kullanıldığını ve cihaz izinlerinin durumunu buradan görebilirsin.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    ),
  );
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title, required this.subtitle});
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) =>
      EsnaftaVarSectionHeader(title: title, subtitle: subtitle);
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
    final accent = hasError ? EsnaftaVarColors.accent : presentation.accent;
    final background = hasError
        ? EsnaftaVarColors.accentSoft
        : presentation.background;

    return Semantics(
      liveRegion: true,
      child: Container(
        key: const Key('location-permission-card'),
        width: double.infinity,
        padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
        decoration: BoxDecoration(
          color: EsnaftaVarColors.surface,
          borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
          border: Border.all(color: EsnaftaVarColors.borderDefault),
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
                const SizedBox(width: EsnaftaVarSpacing.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Konum İzni',
                        style: TextStyle(
                          color: EsnaftaVarColors.textPrimary,
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: EsnaftaVarSpacing.xxs),
                      Text(
                        hasError
                            ? 'İzin durumu alınamadı'
                            : isLoading
                            ? 'İzin durumu kontrol ediliyor'
                            : presentation.label,
                        key: const Key('location-permission-status'),
                        style: TextStyle(
                          color: accent,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: const Key('location-permission-refresh'),
                  constraints: const BoxConstraints(
                    minWidth: 48,
                    minHeight: 48,
                  ),
                  tooltip: 'İzin durumunu yenile',
                  onPressed: isLoading ? null : onRefresh,
                  color: EsnaftaVarColors.primary,
                  icon: const Icon(Icons.refresh_rounded, size: 20),
                ),
              ],
            ),
            const SizedBox(height: EsnaftaVarSpacing.sm),
            Text(
              hasError
                  ? 'İzin durumunu şu anda okuyamadık. Bu kontrol konumunu almaz ve yeni bir izin istemez.'
                  : isLoading
                  ? 'Yalnızca mevcut izin ayarı okunuyor; konumun alınmıyor.'
                  : presentation.description,
              style: const TextStyle(
                color: EsnaftaVarColors.textSecondary,
                fontSize: 12,
                height: 1.45,
                fontWeight: FontWeight.w500,
              ),
            ),
            if (isLoading) ...[
              const SizedBox(height: EsnaftaVarSpacing.sm),
              const ClipRRect(
                borderRadius: BorderRadius.all(
                  Radius.circular(EsnaftaVarRadii.pill),
                ),
                child: LinearProgressIndicator(
                  key: Key('location-permission-progress'),
                  color: EsnaftaVarColors.primary,
                  backgroundColor: EsnaftaVarColors.primarySoft,
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
        accent: EsnaftaVarColors.success,
        background: EsnaftaVarColors.successSoft,
      ),
      CustomerLocationPermissionStatus.blocked => const _PermissionPresentation(
        icon: Icons.location_off_outlined,
        label: 'Ayarlar üzerinden kapalı',
        description:
            'Konum izni tarayıcı veya cihaz ayarlarından kapatılmış. Mağazaları konum olmadan görüntülemeye devam edebilirsin.',
        accent: EsnaftaVarColors.accent,
        background: EsnaftaVarColors.accentSoft,
      ),
      CustomerLocationPermissionStatus.restricted =>
        const _PermissionPresentation(
          icon: Icons.gpp_maybe_outlined,
          label: 'Cihaz tarafından kısıtlı',
          description:
              'Cihaz ayarları konum kullanımını kısıtlıyor. Mağazaları konum olmadan görüntülemeye devam edebilirsin.',
          accent: EsnaftaVarColors.warning,
          background: EsnaftaVarColors.warningSoft,
        ),
      CustomerLocationPermissionStatus.notAllowed ||
      null => const _PermissionPresentation(
        icon: Icons.location_disabled_outlined,
        label: 'Kapalı veya henüz verilmedi',
        description:
            'Konum izni olmadan da mağazaları görebilirsin. Yakınlık sıralaması için Yakındakiler ekranından izin verebilirsin.',
        accent: EsnaftaVarColors.textSecondary,
        background: EsnaftaVarColors.background,
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
        color: EsnaftaVarColors.surface,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
        border: Border.all(color: EsnaftaVarColors.borderDefault),
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
                color: EsnaftaVarColors.borderDefault,
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
      padding: const EdgeInsets.all(EsnaftaVarSpacing.sm),
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
          const SizedBox(width: EsnaftaVarSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: EsnaftaVarColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: EsnaftaVarSpacing.xxs),
                Text(
                  description,
                  style: const TextStyle(
                    color: EsnaftaVarColors.textSecondary,
                    fontSize: 14,
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
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
        child: Ink(
          padding: const EdgeInsets.all(EsnaftaVarSpacing.sm),
          decoration: BoxDecoration(
            color: EsnaftaVarColors.surface,
            borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
            border: Border.all(color: EsnaftaVarColors.borderDefault),
          ),
          child: Row(
            children: [
              Container(
                width: 42,
                height: 42,
                decoration: const BoxDecoration(
                  color: EsnaftaVarColors.primarySoft,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: EsnaftaVarColors.primary, size: 20),
              ),
              const SizedBox(width: EsnaftaVarSpacing.sm),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        color: EsnaftaVarColors.textPrimary,
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(height: EsnaftaVarSpacing.xxs),
                    Text(
                      subtitle,
                      style: const TextStyle(
                        color: EsnaftaVarColors.textSecondary,
                        fontSize: 12,
                        height: 1.35,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const Icon(
                Icons.chevron_right_rounded,
                color: EsnaftaVarColors.textSecondary,
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
      padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
      decoration: BoxDecoration(
        color: EsnaftaVarColors.surface,
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
        border: Border.all(color: EsnaftaVarColors.borderDefault),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.settings_outlined,
            color: EsnaftaVarColors.primary,
            size: 21,
          ),
          SizedBox(width: EsnaftaVarSpacing.sm),
          Expanded(
            child: Text(
              'Chrome’da adres çubuğundaki site ayarlarından; Android veya iOS’ta cihazının uygulama ayarlarından konum iznini yönetebilirsin.',
              style: TextStyle(
                color: EsnaftaVarColors.textSecondary,
                fontSize: 12,
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
