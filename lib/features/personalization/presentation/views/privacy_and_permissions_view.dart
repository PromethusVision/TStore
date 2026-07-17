import 'package:flutter/material.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:t_store/core/utils/constants/sizes.dart';

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

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Gizlilik ve İzinler')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(TSizes.defaultSpace),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(TSizes.lg),
                decoration: BoxDecoration(
                  color: colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.privacy_tip_outlined,
                      size: 40,
                      color: colorScheme.onPrimaryContainer,
                    ),
                    const SizedBox(height: TSizes.spaceBtwItems),
                    Text(
                      'Gizliliğin ve kontrolün sende',
                      style: Theme.of(context).textTheme.headlineSmall
                          ?.copyWith(
                            color: colorScheme.onPrimaryContainer,
                            fontWeight: FontWeight.w700,
                          ),
                    ),
                    const SizedBox(height: TSizes.sm),
                    Text(
                      'Hangi bilgilerin ne için kullanıldığını ve cihaz '
                      'izinlerinin durumunu buradan görebilirsin.',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: colorScheme.onPrimaryContainer,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              _SectionTitle(title: 'İzinler'),
              const SizedBox(height: TSizes.spaceBtwItems),
              _LocationPermissionCard(
                status: _locationStatus,
                isLoading: _isLoading,
                hasError: _hasError,
                onRefresh: _refreshPermissionStatus,
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              _SectionTitle(title: 'Konumunu nasıl kullanıyoruz?'),
              const SizedBox(height: TSizes.spaceBtwItems),
              const _InformationCard(
                children: [
                  _InformationItem(
                    icon: Icons.touch_app_outlined,
                    title: 'Yalnızca sen istediğinde',
                    description:
                        'Mevcut GPS konumun, yalnızca “Konumumu Kullan” '
                        'dediğinde alınır. Bu sayfayı açmak konumunu almaz.',
                  ),
                  _InformationItem(
                    icon: Icons.storefront_outlined,
                    title: 'Yakındaki mağazaları sıralamak için',
                    description:
                        'Anlık konumun mağazaları yakından uzağa sıralamak '
                        'için kullanılır; mağazalarla paylaşılmaz ve arka '
                        'planda takip edilmez.',
                  ),
                  _InformationItem(
                    icon: Icons.bookmark_outline_rounded,
                    title: 'Kaydetmeyi sen seçersin',
                    description:
                        'Kayıtlı Konumlarım bölümünde bir konumu özellikle '
                        'kaydedersen koordinatları hesabında saklanır. '
                        'Kaydettiğin konumları daha sonra silebilirsin.',
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              _SectionTitle(title: 'Uygulamadaki bilgilerin'),
              const SizedBox(height: TSizes.spaceBtwItems),
              const _InformationCard(
                children: [
                  _InformationItem(
                    icon: Icons.person_outline,
                    title: 'Hesap bilgileri',
                    description:
                        'Ad, e-posta ve telefon bilgilerin hesabını ve müşteri '
                        'iletişimini yönetmek için kullanılır.',
                  ),
                  _InformationItem(
                    icon: Icons.chat_bubble_outline_rounded,
                    title: 'Mesajlar',
                    description:
                        'Mağazalarla yaptığın konuşmalar, mesaj geçmişine '
                        'yeniden ulaşabilmen için hesabınla ilişkilendirilir.',
                  ),
                  _InformationItem(
                    icon: Icons.receipt_long_outlined,
                    title: 'Alışveriş ve QR doğrulamaları',
                    description:
                        'Doğrulanan mağaza alışverişlerin, alışveriş geçmişini '
                        've iade taleplerini göstermek için kullanılır.',
                  ),
                  _InformationItem(
                    icon: Icons.star_outline_rounded,
                    title: 'Değerlendirmeler',
                    description:
                        'Mağazalara verdiğin puanlar değerlendirme geçmişinde '
                        'gösterilir.',
                  ),
                ],
              ),
              const SizedBox(height: TSizes.spaceBtwSections),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(TSizes.md),
                decoration: BoxDecoration(
                  color: colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
                  border: Border.all(color: colorScheme.outlineVariant),
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Icon(
                      Icons.info_outline_rounded,
                      color: colorScheme.primary,
                    ),
                    const SizedBox(width: TSizes.sm),
                    Expanded(
                      child: Text(
                        'Chrome’da adres çubuğundaki site ayarlarından; '
                        'Android veya iOS’ta cihazının uygulama ayarlarından '
                        'konum iznini yönetebilirsin.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
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
    final colorScheme = Theme.of(context).colorScheme;
    final presentation = _permissionPresentation(status);

    return Semantics(
      liveRegion: true,
      child: Container(
        key: const Key('location-permission-card'),
        width: double.infinity,
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          color: colorScheme.surface,
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          border: Border.all(color: colorScheme.outlineVariant),
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
                    color: colorScheme.primaryContainer,
                    shape: BoxShape.circle,
                  ),
                  alignment: Alignment.center,
                  child: Icon(
                    hasError ? Icons.error_outline : presentation.icon,
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: TSizes.sm),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Konum',
                        style: Theme.of(context).textTheme.titleMedium
                            ?.copyWith(fontWeight: FontWeight.w700),
                      ),
                      const SizedBox(height: TSizes.xs),
                      Text(
                        hasError
                            ? 'İzin durumu alınamadı'
                            : isLoading
                            ? 'İzin durumu kontrol ediliyor'
                            : presentation.label,
                        key: const Key('location-permission-status'),
                        style: Theme.of(context).textTheme.labelLarge?.copyWith(
                          color: hasError
                              ? colorScheme.error
                              : colorScheme.primary,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  key: const Key('location-permission-refresh'),
                  tooltip: 'İzin durumunu yenile',
                  onPressed: isLoading ? null : onRefresh,
                  icon: const Icon(Icons.refresh_rounded),
                ),
              ],
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(
              hasError
                  ? 'İzin durumunu şu anda okuyamadık. Bu kontrol konumunu '
                        'almaz ve yeni bir izin istemez.'
                  : isLoading
                  ? 'Yalnızca mevcut izin ayarı okunuyor; konumun alınmıyor.'
                  : presentation.description,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            if (isLoading) ...[
              const SizedBox(height: TSizes.spaceBtwItems),
              const LinearProgressIndicator(
                key: Key('location-permission-progress'),
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
            'Konum izni açık. GPS konumun yine de yalnızca sen '
            '“Konumumu Kullan” dediğinde alınır.',
      ),
      CustomerLocationPermissionStatus.blocked => const _PermissionPresentation(
        icon: Icons.location_off_outlined,
        label: 'Ayarlar üzerinden kapalı',
        description:
            'Konum izni tarayıcı veya cihaz ayarlarından kapatılmış. '
            'Mağazaları konum olmadan görüntülemeye devam edebilirsin.',
      ),
      CustomerLocationPermissionStatus.restricted =>
        const _PermissionPresentation(
          icon: Icons.gpp_maybe_outlined,
          label: 'Cihaz tarafından kısıtlı',
          description:
              'Cihaz ayarları konum kullanımını kısıtlıyor. Mağazaları '
              'konum olmadan görüntülemeye devam edebilirsin.',
        ),
      CustomerLocationPermissionStatus.notAllowed ||
      null => const _PermissionPresentation(
        icon: Icons.location_disabled_outlined,
        label: 'Kapalı veya henüz verilmedi',
        description:
            'Konum izni olmadan da mağazaları görebilirsin. Yakınlık '
            'sıralaması için Yakındakiler ekranından izin verebilirsin.',
      ),
    };
  }
}

class _PermissionPresentation {
  const _PermissionPresentation({
    required this.icon,
    required this.label,
    required this.description,
  });

  final IconData icon;
  final String label;
  final String description;
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle({required this.title});

  final String title;

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: Theme.of(
        context,
      ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.w700),
    );
  }
}

class _InformationCard extends StatelessWidget {
  const _InformationCard({required this.children});

  final List<_InformationItem> children;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: colorScheme.surface,
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
        border: Border.all(color: colorScheme.outlineVariant),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: [
          for (var index = 0; index < children.length; index++) ...[
            children[index],
            if (index != children.length - 1)
              Divider(height: 1, indent: 64, color: colorScheme.outlineVariant),
          ],
        ],
      ),
    );
  }
}

class _InformationItem extends StatelessWidget {
  const _InformationItem({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: const EdgeInsets.all(TSizes.md),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: colorScheme.primary),
          const SizedBox(width: TSizes.spaceBtwItems),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(
                    context,
                  ).textTheme.titleSmall?.copyWith(fontWeight: FontWeight.w700),
                ),
                const SizedBox(height: TSizes.xs),
                Text(
                  description,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: colorScheme.onSurfaceVariant,
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
