import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/personalization/domain/entities/customer_saved_location_entity.dart';
import 'package:t_store/features/personalization/presentation/cubit/customer_saved_locations_cubit.dart';
import 'package:t_store/features/personalization/presentation/cubit/customer_saved_locations_state.dart';
import 'package:t_store/features/shop/domain/services/customer_location_service.dart';

class CustomerSavedLocationsView extends StatelessWidget {
  const CustomerSavedLocationsView({
    super.key,
    this.customerSavedLocationsCubit,
  });

  final CustomerSavedLocationsCubit? customerSavedLocationsCubit;

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) =>
          (customerSavedLocationsCubit ?? sl<CustomerSavedLocationsCubit>())
            ..loadLocations(),
      child: const _CustomerSavedLocationsContent(),
    );
  }
}

class _CustomerSavedLocationsContent extends StatelessWidget {
  const _CustomerSavedLocationsContent();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kayıtlı Konumlarım')),
      floatingActionButton:
          BlocBuilder<CustomerSavedLocationsCubit, CustomerSavedLocationsState>(
            builder: (context, state) {
              if (state is! CustomerSavedLocationsLoaded ||
                  state.locations.isEmpty) {
                return const SizedBox.shrink();
              }

              return FloatingActionButton.extended(
                key: const Key('saved-location-add-button'),
                onPressed: state.isBusy
                    ? null
                    : () => _openAddLocation(context),
                icon: const Icon(Icons.add_location_alt_outlined),
                label: const Text('Konum Ekle'),
              );
            },
          ),
      body: BlocBuilder<CustomerSavedLocationsCubit, CustomerSavedLocationsState>(
        builder: (context, state) {
          if (state is CustomerSavedLocationsInitial ||
              state is CustomerSavedLocationsLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (state is CustomerSavedLocationsError) {
            return _SavedLocationStatus(
              icon: Icons.location_off_outlined,
              title: 'Konumların yüklenemedi',
              description: state.message,
              actionLabel: 'Tekrar Dene',
              onAction: () =>
                  context.read<CustomerSavedLocationsCubit>().loadLocations(),
            );
          }

          final loadedState = state as CustomerSavedLocationsLoaded;
          if (loadedState.locations.isEmpty) {
            return _SavedLocationStatus(
              icon: Icons.add_location_alt_outlined,
              title: 'Henüz kayıtlı konumun yok',
              description:
                  'Sık kullandığın bir konumu kaydederek daha sonra kolayca seçebilirsin.',
              actionLabel: 'Mevcut Konumumu Kaydet',
              onAction: loadedState.isBusy
                  ? null
                  : () => _openAddLocation(context),
            );
          }

          return RefreshIndicator(
            onRefresh: () =>
                context.read<CustomerSavedLocationsCubit>().loadLocations(),
            child: ListView.separated(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                TSizes.defaultSpace,
                TSizes.defaultSpace,
                TSizes.defaultSpace,
                104,
              ),
              itemCount: loadedState.locations.length + 1,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: TSizes.spaceBtwItems),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const _SavedLocationsInfoCard();
                }

                final location = loadedState.locations[index - 1];
                return _SavedLocationCard(
                  location: location,
                  isBusy: loadedState.isBusy,
                  isCurrentOperation: loadedState.busyLocationId == location.id,
                  onSetDefault: () => _setDefaultLocation(context, location),
                  onDelete: () => _confirmDelete(context, location),
                );
              },
            ),
          );
        },
      ),
    );
  }

  Future<void> _openAddLocation(BuildContext context) async {
    final cubit = context.read<CustomerSavedLocationsCubit>();
    final didSave = await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      useSafeArea: true,
      builder: (_) => BlocProvider.value(
        value: cubit,
        child: const _AddSavedLocationSheet(),
      ),
    );

    if (didSave != true || !context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Konumun kaydedildi.')));
  }

  Future<void> _setDefaultLocation(
    BuildContext context,
    CustomerSavedLocationEntity location,
  ) async {
    final didSet = await context
        .read<CustomerSavedLocationsCubit>()
        .setDefaultLocation(location.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          didSet
              ? '${location.name} ana konum olarak seçildi.'
              : 'Ana konum şu anda değiştirilemedi.',
        ),
      ),
    );
  }

  Future<void> _confirmDelete(
    BuildContext context,
    CustomerSavedLocationEntity location,
  ) async {
    final shouldDelete = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: const Text('Konum silinsin mi?'),
        content: Text('${location.name} kayıtlı konumlardan kaldırılacak.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Vazgeç'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Sil'),
          ),
        ],
      ),
    );

    if (shouldDelete != true || !context.mounted) return;
    final didDelete = await context
        .read<CustomerSavedLocationsCubit>()
        .deleteLocation(location.id);
    if (!context.mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          didDelete ? '${location.name} silindi.' : 'Konum şu anda silinemedi.',
        ),
      ),
    );
  }
}

class _SavedLocationsInfoCard extends StatelessWidget {
  const _SavedLocationsInfoCard();

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Container(
      padding: const EdgeInsets.all(TSizes.md),
      decoration: BoxDecoration(
        color: colorScheme.secondaryContainer.withValues(alpha: 0.45),
        borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(Icons.info_outline, color: colorScheme.onSecondaryContainer),
          const SizedBox(width: TSizes.sm),
          Expanded(
            child: Text(
              'Kaydettiğin konumlardan birini ana konum olarak belirleyebilirsin.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSecondaryContainer,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedLocationCard extends StatelessWidget {
  const _SavedLocationCard({
    required this.location,
    required this.isBusy,
    required this.isCurrentOperation,
    required this.onSetDefault,
    required this.onDelete,
  });

  final CustomerSavedLocationEntity location;
  final bool isBusy;
  final bool isCurrentOperation;
  final VoidCallback onSetDefault;
  final VoidCallback onDelete;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Semantics(
      label:
          '${location.name}, ${location.addressText}${location.isDefault ? ', ana konum' : ''}',
      child: Container(
        padding: const EdgeInsets.all(TSizes.md),
        decoration: BoxDecoration(
          color: location.isDefault
              ? colorScheme.primaryContainer.withValues(alpha: 0.35)
              : colorScheme.surface,
          borderRadius: BorderRadius.circular(TSizes.cardRadiusLg),
          border: Border.all(
            color: location.isDefault
                ? colorScheme.primary.withValues(alpha: 0.4)
                : colorScheme.outlineVariant,
          ),
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
                  child: Icon(
                    _iconForName(location.name),
                    color: colorScheme.onPrimaryContainer,
                  ),
                ),
                const SizedBox(width: TSizes.spaceBtwItems),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Text(
                              location.name,
                              style: Theme.of(context).textTheme.titleMedium
                                  ?.copyWith(fontWeight: FontWeight.w700),
                            ),
                          ),
                          if (location.isDefault)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: TSizes.sm,
                                vertical: TSizes.xs,
                              ),
                              decoration: BoxDecoration(
                                color: colorScheme.primary,
                                borderRadius: BorderRadius.circular(999),
                              ),
                              child: Text(
                                'Ana Konum',
                                style: Theme.of(context).textTheme.labelSmall
                                    ?.copyWith(
                                      color: colorScheme.onPrimary,
                                      fontWeight: FontWeight.w700,
                                    ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: TSizes.xs),
                      Text(
                        location.addressText,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: colorScheme.onSurfaceVariant,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: TSizes.md),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (!location.isDefault)
                  TextButton.icon(
                    onPressed: isBusy ? null : onSetDefault,
                    icon: const Icon(Icons.check_circle_outline),
                    label: const Text('Ana Konum Yap'),
                  ),
                const Spacer(),
                if (isCurrentOperation)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                else
                  IconButton(
                    tooltip: 'Konumu sil',
                    onPressed: isBusy ? null : onDelete,
                    icon: const Icon(Icons.delete_outline),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  IconData _iconForName(String name) {
    final normalizedName = name.toLowerCase();
    if (normalizedName.contains('ev')) return Icons.home_outlined;
    if (normalizedName == 'iş' ||
        normalizedName == 'is' ||
        normalizedName.contains('ofis')) {
      return Icons.work_outline;
    }
    return Icons.location_on_outlined;
  }
}

class _AddSavedLocationSheet extends StatefulWidget {
  const _AddSavedLocationSheet();

  @override
  State<_AddSavedLocationSheet> createState() => _AddSavedLocationSheetState();
}

class _AddSavedLocationSheetState extends State<_AddSavedLocationSheet> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _addressController = TextEditingController();
  CustomerCoordinates? _coordinates;
  String? _locationError;
  bool _isLocating = false;
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Padding(
      padding: EdgeInsets.only(
        left: TSizes.defaultSpace,
        right: TSizes.defaultSpace,
        top: TSizes.defaultSpace,
        bottom: MediaQuery.viewInsetsOf(context).bottom + TSizes.defaultSpace,
      ),
      child: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: colorScheme.outlineVariant,
                    borderRadius: BorderRadius.circular(999),
                  ),
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              Text(
                'Konum Ekle',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: TSizes.sm),
              Text(
                'Konumunu bulduktan sonra kolay hatırlayacağın bir ad ve adres açıklaması ekle.',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: colorScheme.onSurfaceVariant,
                ),
              ),
              const SizedBox(height: TSizes.spaceBtwItems),
              TextFormField(
                key: const Key('saved-location-name-field'),
                controller: _nameController,
                textInputAction: TextInputAction.next,
                maxLength: 50,
                decoration: const InputDecoration(
                  labelText: 'Konum Adı',
                  hintText: 'Ev, İş veya başka bir ad',
                  prefixIcon: Icon(Icons.label_outline),
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Konum adı gerekli.'
                    : null,
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),
              TextFormField(
                key: const Key('saved-location-address-field'),
                controller: _addressController,
                textInputAction: TextInputAction.done,
                minLines: 2,
                maxLines: 3,
                maxLength: 200,
                decoration: const InputDecoration(
                  labelText: 'Adres Açıklaması',
                  hintText: 'Örn. Esenler, İstanbul',
                  prefixIcon: Icon(Icons.location_on_outlined),
                  alignLabelWithHint: true,
                ),
                validator: (value) => value == null || value.trim().isEmpty
                    ? 'Adres açıklaması gerekli.'
                    : null,
              ),
              const SizedBox(height: TSizes.spaceBtwInputFields),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  key: const Key('saved-location-capture-button'),
                  onPressed: _isLocating || _isSaving ? null : _captureLocation,
                  icon: _isLocating
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          _coordinates == null
                              ? Icons.my_location
                              : Icons.check_circle,
                        ),
                  label: Text(
                    _coordinates == null
                        ? 'Mevcut Konumumu Al'
                        : 'Konum Alındı',
                  ),
                ),
              ),
              if (_locationError != null) ...[
                const SizedBox(height: TSizes.sm),
                Text(
                  _locationError!,
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(color: colorScheme.error),
                ),
              ],
              const SizedBox(height: TSizes.defaultSpace),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  key: const Key('saved-location-save-button'),
                  onPressed: _isSaving ? null : _save,
                  child: _isSaving
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Konumu Kaydet'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _captureLocation() async {
    setState(() {
      _isLocating = true;
      _locationError = null;
    });
    final result = await context
        .read<CustomerSavedLocationsCubit>()
        .captureCurrentLocation();
    if (!mounted) return;

    setState(() {
      _isLocating = false;
      _coordinates = result.coordinates;
      _locationError = result.isSuccess
          ? null
          : _messageForLocationFailure(result.failure);
    });
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    final coordinates = _coordinates;
    if (coordinates == null) {
      setState(() {
        _locationError = 'Kaydetmeden önce mevcut konumunu almalısın.';
      });
      return;
    }

    setState(() => _isSaving = true);
    final didSave = await context
        .read<CustomerSavedLocationsCubit>()
        .addLocation(
          name: _nameController.text,
          addressText: _addressController.text,
          coordinates: coordinates,
        );
    if (!mounted) return;

    if (didSave) {
      Navigator.of(context).pop(true);
      return;
    }

    setState(() {
      _isSaving = false;
      _locationError = 'Konum şu anda kaydedilemedi. Lütfen tekrar dene.';
    });
  }

  String _messageForLocationFailure(CustomerLocationFailure? failure) {
    return switch (failure) {
      CustomerLocationFailure.permissionDenied =>
        'Konum izni verilmedi. Tarayıcı izinlerinden konuma izin verebilirsin.',
      CustomerLocationFailure.servicesDisabled =>
        'Cihazının konum hizmeti kapalı. Açtıktan sonra tekrar dene.',
      CustomerLocationFailure.timedOut =>
        'Konumun zamanında alınamadı. Lütfen tekrar dene.',
      CustomerLocationFailure.unavailable ||
      null => 'Konumun şu anda alınamıyor. Lütfen tekrar dene.',
    };
  }
}

class _SavedLocationStatus extends StatelessWidget {
  const _SavedLocationStatus({
    required this.icon,
    required this.title,
    required this.description,
    required this.actionLabel,
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;

    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(TSizes.defaultSpace),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 64, color: colorScheme.primary),
            const SizedBox(height: TSizes.spaceBtwItems),
            Text(
              title,
              textAlign: TextAlign.center,
              style: Theme.of(
                context,
              ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w700),
            ),
            const SizedBox(height: TSizes.sm),
            Text(
              description,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: TSizes.spaceBtwItems),
            FilledButton.icon(
              onPressed: onAction,
              icon: const Icon(Icons.add_location_alt_outlined),
              label: Text(actionLabel),
            ),
          ],
        ),
      ),
    );
  }
}
