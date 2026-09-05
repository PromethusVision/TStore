import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/features/auth/presentation/widgets/customer_auth_form_card.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';
import 'package:t_store/core/ui/components/esnaftavar_scaffold.dart';
import 'package:t_store/core/ui/components/esnaftavar_state_card.dart';
import 'package:t_store/features/personalization/presentation/widgets/account_page_header.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
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

class _CustomerSavedLocationsContent extends StatefulWidget {
  const _CustomerSavedLocationsContent();

  @override
  State<_CustomerSavedLocationsContent> createState() =>
      _CustomerSavedLocationsContentState();
}

class _CustomerSavedLocationsContentState
    extends State<_CustomerSavedLocationsContent> {
  bool _isPageActionPending = false;

  @override
  Widget build(BuildContext context) {
    return EsnaftaVarScaffold(
      safeAreaTop: false,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('customer-saved-locations-content'),
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
                  child: _SavedLocationsHeader(),
                ),
                const SizedBox(height: EsnaftaVarSpacing.sm),
                Expanded(
                  child:
                      BlocBuilder<
                        CustomerSavedLocationsCubit,
                        CustomerSavedLocationsState
                      >(
                        builder: (context, state) {
                          if (state is CustomerSavedLocationsInitial ||
                              state is CustomerSavedLocationsLoading) {
                            return const _SavedLocationsLoadingState();
                          }

                          if (state is CustomerSavedLocationsError) {
                            return _SavedLocationStatus(
                              icon: Icons.location_off_outlined,
                              title: 'Konumların yüklenemedi',
                              description: state.message,
                              actionLabel: 'Tekrar Dene',
                              onAction: () => context
                                  .read<CustomerSavedLocationsCubit>()
                                  .loadLocations(),
                            );
                          }

                          final loadedState =
                              state as CustomerSavedLocationsLoaded;
                          final isInteractionBlocked =
                              loadedState.isBusy || _isPageActionPending;
                          if (loadedState.locations.isEmpty) {
                            return _SavedLocationStatus(
                              icon: Icons.add_location_alt_outlined,
                              title: 'Henüz kayıtlı konumun yok',
                              description:
                                  'Sık kullandığın bir konumu kaydederek daha sonra kolayca seçebilirsin.',
                              actionLabel: 'Mevcut Konumumu Kaydet',
                              onAction: isInteractionBlocked
                                  ? null
                                  : () => _openAddLocation(context),
                            );
                          }

                          return _SavedLocationsLoadedContent(
                            state: loadedState,
                            isInteractionBlocked: isInteractionBlocked,
                            onAddLocation: () => _openAddLocation(context),
                            onSetDefault: (location) =>
                                _setDefaultLocation(context, location),
                            onDelete: (location) =>
                                _confirmDelete(context, location),
                          );
                        },
                      ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _openAddLocation(BuildContext context) async {
    if (_isPageActionPending) return;

    setState(() => _isPageActionPending = true);
    final cubit = context.read<CustomerSavedLocationsCubit>();
    bool didSave = false;
    try {
      didSave =
          await showModalBottomSheet<bool>(
            context: context,
            isScrollControlled: true,
            useSafeArea: true,
            backgroundColor: Colors.transparent,
            builder: (_) => BlocProvider.value(
              value: cubit,
              child: const _AddSavedLocationSheet(),
            ),
          ) ==
          true;
    } finally {
      if (mounted) {
        setState(() => _isPageActionPending = false);
      } else {
        _isPageActionPending = false;
      }
    }

    if (!didSave || !context.mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Konumun kaydedildi.')));
  }

  Future<void> _setDefaultLocation(
    BuildContext context,
    CustomerSavedLocationEntity location,
  ) async {
    if (_isPageActionPending) return;

    setState(() => _isPageActionPending = true);
    bool didSet = false;
    try {
      didSet = await context
          .read<CustomerSavedLocationsCubit>()
          .setDefaultLocation(location.id);
    } finally {
      if (mounted) {
        setState(() => _isPageActionPending = false);
      } else {
        _isPageActionPending = false;
      }
    }
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
    if (_isPageActionPending) return;

    setState(() => _isPageActionPending = true);
    bool shouldDelete = false;
    bool didDelete = false;
    try {
      var isDialogResolving = false;
      shouldDelete =
          await showDialog<bool>(
            context: context,
            builder: (dialogContext) => StatefulBuilder(
              builder: (context, setDialogState) {
                void closeDialog(bool result) {
                  if (isDialogResolving) return;
                  isDialogResolving = true;
                  setDialogState(() {});
                  Navigator.of(dialogContext).pop(result);
                }

                return Theme(
                  data: EsnaftaVarTheme.light,
                  child: AlertDialog(
                    key: const Key('saved-location-delete-dialog'),
                    scrollable: true,
                    backgroundColor: EsnaftaVarColors.surface,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        EsnaftaVarRadii.large,
                      ),
                    ),
                    title: const Text('Konum silinsin mi?'),
                    content: Text(
                      '${location.name} kayıtlı konumlardan kaldırılacak.',
                    ),
                    actions: [
                      TextButton(
                        key: const Key('saved-location-delete-cancel'),
                        onPressed: isDialogResolving
                            ? null
                            : () => closeDialog(false),
                        child: const Text('Vazgeç'),
                      ),
                      FilledButton(
                        key: const Key('saved-location-delete-confirm'),
                        onPressed: isDialogResolving
                            ? null
                            : () => closeDialog(true),
                        style: FilledButton.styleFrom(
                          backgroundColor: EsnaftaVarColors.error,
                        ),
                        child: const Text('Sil'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ) ==
          true;

      if (!shouldDelete || !context.mounted) return;
      didDelete = await context
          .read<CustomerSavedLocationsCubit>()
          .deleteLocation(location.id);
    } finally {
      if (mounted) {
        setState(() => _isPageActionPending = false);
      } else {
        _isPageActionPending = false;
      }
    }

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

class _SavedLocationsHeader extends StatelessWidget {
  const _SavedLocationsHeader();
  @override
  Widget build(BuildContext context) => const AccountPageHeader(
    key: Key('customer-saved-locations-header'),
    backKey: Key('customer-saved-locations-back-button'),
    title: 'Kayıtlı Konumlarım',
    subtitle: 'Sık kullandığın konumları yönet',
  );
}

class _SavedLocationsLoadingState extends StatelessWidget {
  const _SavedLocationsLoadingState();
  @override
  Widget build(BuildContext context) => const Center(
    child: SingleChildScrollView(
      padding: EdgeInsets.all(EsnaftaVarSpacing.md),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(semanticsLabel: 'Konumların yükleniyor'),
          SizedBox(height: EsnaftaVarSpacing.md),
          EsnaftaVarStateCard(
            key: Key('customer-saved-locations-loading-state'),
            icon: Icons.location_on_outlined,
            title: 'Konumların yükleniyor',
            message: 'Lütfen kısa bir süre bekleyin.',
          ),
        ],
      ),
    ),
  );
}

class _SavedLocationsLoadedContent extends StatelessWidget {
  const _SavedLocationsLoadedContent({
    required this.state,
    required this.isInteractionBlocked,
    required this.onAddLocation,
    required this.onSetDefault,
    required this.onDelete,
  });

  final CustomerSavedLocationsLoaded state;
  final bool isInteractionBlocked;
  final VoidCallback onAddLocation;
  final ValueChanged<CustomerSavedLocationEntity> onSetDefault;
  final ValueChanged<CustomerSavedLocationEntity> onDelete;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: RefreshIndicator(
            color: EsnaftaVarColors.primary,
            onRefresh: () =>
                context.read<CustomerSavedLocationsCubit>().loadLocations(),
            child: ListView.separated(
              key: const Key('customer-saved-locations-list'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                EsnaftaVarSpacing.md,
                EsnaftaVarSpacing.xxs,
                EsnaftaVarSpacing.md,
                EsnaftaVarSpacing.sm,
              ),
              itemCount: state.locations.length + 1,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: EsnaftaVarSpacing.sm),
              itemBuilder: (context, index) {
                if (index == 0) {
                  return const _SavedLocationsInfoCard();
                }

                final location = state.locations[index - 1];
                return _SavedLocationCard(
                  location: location,
                  isBusy: isInteractionBlocked,
                  isCurrentOperation: state.busyLocationId == location.id,
                  onSetDefault: () => onSetDefault(location),
                  onDelete: () => onDelete(location),
                );
              },
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.fromLTRB(
            EsnaftaVarSpacing.md,
            EsnaftaVarSpacing.xs,
            EsnaftaVarSpacing.md,
            EsnaftaVarSpacing.sm,
          ),
          color: EsnaftaVarColors.background,
          child: FilledButton.icon(
            key: const Key('saved-location-add-button'),
            onPressed: isInteractionBlocked ? null : onAddLocation,
            style: FilledButton.styleFrom(
              backgroundColor: EsnaftaVarColors.primary,
              foregroundColor: Colors.white,
              disabledBackgroundColor: EsnaftaVarColors.primarySoft,
              disabledForegroundColor: EsnaftaVarColors.textSecondary,
              padding: const EdgeInsets.symmetric(
                vertical: EsnaftaVarSpacing.sm,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
              ),
            ),
            icon: const Icon(Icons.add_location_alt_outlined, size: 20),
            label: const Text('Konum Ekle'),
          ),
        ),
      ],
    );
  }
}

class _SavedLocationsInfoCard extends StatelessWidget {
  const _SavedLocationsInfoCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      key: const Key('saved-locations-info-card'),
      padding: const EdgeInsets.all(EsnaftaVarSpacing.sm),
      decoration: BoxDecoration(
        color: EsnaftaVarColors.primarySoft.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
        border: Border.all(
          color: EsnaftaVarColors.primary.withValues(alpha: 0.12),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: EsnaftaVarColors.primary,
            size: 20,
          ),
          SizedBox(width: EsnaftaVarSpacing.xs),
          Expanded(
            child: Text(
              'Kaydettiğin konumlardan birini ana konum olarak belirleyebilirsin.',
              style: TextStyle(
                color: EsnaftaVarColors.primary,
                fontSize: 12,
                height: 1.4,
                fontWeight: FontWeight.w600,
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
  Widget build(BuildContext context) => Container(
    key: Key('saved-location-card-${location.id}'),
    padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
    decoration: BoxDecoration(
      color: EsnaftaVarColors.surface,
      borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
      border: Border.all(
        color: location.isDefault
            ? EsnaftaVarColors.primary
            : EsnaftaVarColors.borderDefault,
      ),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(_iconForName(location.name), color: EsnaftaVarColors.primary),
            const SizedBox(width: EsnaftaVarSpacing.xs),
            Expanded(
              child: Text(
                location.name,
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),
          ],
        ),
        if (location.isDefault) ...[
          const SizedBox(height: EsnaftaVarSpacing.xs),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: EsnaftaVarSpacing.xs,
              vertical: EsnaftaVarSpacing.xxs,
            ),
            decoration: BoxDecoration(
              color: EsnaftaVarColors.primarySoft,
              borderRadius: BorderRadius.circular(EsnaftaVarRadii.small),
            ),
            child: Text(
              'Ana Konum',
              style: Theme.of(context).textTheme.labelMedium?.copyWith(
                color: EsnaftaVarColors.primary,
              ),
            ),
          ),
        ],
        const SizedBox(height: EsnaftaVarSpacing.xs),
        Text(
          location.addressText,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
        const SizedBox(height: EsnaftaVarSpacing.sm),
        const Divider(height: 1),
        const SizedBox(height: EsnaftaVarSpacing.xxs),
        Row(
          children: [
            Expanded(
              child: location.isDefault
                  ? Text(
                      'Yakındaki sonuçlarda kullanılıyor',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: EsnaftaVarColors.success,
                      ),
                    )
                  : TextButton.icon(
                      key: Key('saved-location-default-${location.id}'),
                      onPressed: isBusy ? null : onSetDefault,
                      style: TextButton.styleFrom(
                        alignment: Alignment.centerLeft,
                        minimumSize: const Size(48, 48),
                      ),
                      icon: const Icon(
                        Icons.check_circle_outline_rounded,
                        size: 20,
                      ),
                      label: const Text('Ana Konum Yap'),
                    ),
            ),
            const SizedBox(width: EsnaftaVarSpacing.xs),
            if (isCurrentOperation)
              const SizedBox.square(
                dimension: 48,
                child: Padding(
                  padding: EdgeInsets.all(12),
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    semanticsLabel: 'Konum güncelleniyor',
                  ),
                ),
              )
            else
              IconButton(
                key: Key('saved-location-delete-${location.id}'),
                tooltip: 'Konumu sil',
                onPressed: isBusy ? null : onDelete,
                constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
                color: EsnaftaVarColors.error,
                icon: const Icon(Icons.delete_outline_rounded),
              ),
          ],
        ),
      ],
    ),
  );

  IconData _iconForName(String name) {
    final normalizedName = name.toLowerCase();
    if (normalizedName.contains('ev')) return Icons.home_outlined;
    if (normalizedName == 'iş' ||
        normalizedName == 'is' ||
        normalizedName.contains('ofis')) {
      return Icons.work_outline_rounded;
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
  Widget build(BuildContext context) => Align(
    alignment: Alignment.bottomCenter,
    heightFactor: 1,
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 430),
      child: SingleChildScrollView(
        padding: EdgeInsets.only(
          bottom: MediaQuery.viewInsetsOf(context).bottom,
        ),
        child: CustomerAuthFormCard(
          key: const Key('saved-location-add-sheet'),
          padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
          child: SafeArea(
            top: false,
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Center(
                    child: Container(
                      width: 40,
                      height: 4,
                      decoration: BoxDecoration(
                        color: EsnaftaVarColors.borderStrong,
                        borderRadius: BorderRadius.circular(
                          EsnaftaVarRadii.pill,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: EsnaftaVarSpacing.md),
                  Builder(
                    builder: (context) => Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Konum Ekle',
                          style: Theme.of(context).textTheme.titleLarge,
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.xxs),
                        Text(
                          'Mevcut GPS konumunu kaydet',
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                        const SizedBox(height: EsnaftaVarSpacing.md),
                        Text(
                          'Konumunu bulduktan sonra kolay hatırlayacağın bir ad ve adres açıklaması ekle.',
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: EsnaftaVarSpacing.lg),
                  TextFormField(
                    key: const Key('saved-location-name-field'),
                    controller: _nameController,
                    enabled: !_isSaving,
                    textInputAction: TextInputAction.next,
                    maxLength: 50,
                    decoration: const InputDecoration(
                      labelText: 'Konum Adı',
                      hintText: 'Ev, İş...',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Konum adı gerekli.'
                        : null,
                  ),
                  const SizedBox(height: EsnaftaVarSpacing.sm),
                  TextFormField(
                    key: const Key('saved-location-address-field'),
                    controller: _addressController,
                    enabled: !_isSaving,
                    minLines: 2,
                    maxLines: 3,
                    maxLength: 200,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Adres Açıklaması',
                      hintText:
                          'Mahalle, sokak veya kolay hatırlayacağın bir açıklama',
                    ),
                    validator: (value) => value == null || value.trim().isEmpty
                        ? 'Adres açıklaması gerekli.'
                        : null,
                  ),
                  const SizedBox(height: EsnaftaVarSpacing.sm),
                  OutlinedButton.icon(
                    key: const Key('saved-location-capture-button'),
                    onPressed: _isLocating || _isSaving
                        ? null
                        : _captureLocation,
                    icon: _isLocating
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              semanticsLabel: 'Konum alınıyor',
                            ),
                          )
                        : Icon(
                            _coordinates == null
                                ? Icons.my_location_rounded
                                : Icons.check_circle_outline_rounded,
                          ),
                    label: Text(
                      _coordinates == null
                          ? 'Mevcut Konumumu Al'
                          : 'Konum Alındı',
                    ),
                  ),
                  if (_locationError != null) ...[
                    const SizedBox(height: EsnaftaVarSpacing.sm),
                    Semantics(
                      liveRegion: true,
                      child: EsnaftaVarStateCard(
                        key: const Key('saved-location-add-error'),
                        icon: Icons.error_outline_rounded,
                        title: 'Konum kaydedilemedi',
                        message: _locationError!,
                      ),
                    ),
                  ],
                  const SizedBox(height: EsnaftaVarSpacing.lg),
                  FilledButton(
                    key: const Key('saved-location-save-button'),
                    onPressed: _isSaving || _isLocating ? null : _save,
                    child: _isSaving
                        ? const SizedBox.square(
                            dimension: 20,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              semanticsLabel: 'Konum kaydediliyor',
                            ),
                          )
                        : const Text('Konumu Kaydet'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    ),
  );

  Future<void> _captureLocation() async {
    if (_isLocating || _isSaving) return;

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
    if (_isSaving || _isLocating) return;
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
        'Konum izni verilmedi. Tekrar deneyerek sistem izin ekranını açabilirsin.',
      CustomerLocationFailure.permissionDeniedForever =>
        'Konum izni uygulama ayarlarında kapalı. Ayarlardan izni açıp tekrar dene.',
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
    this.onAction,
  });
  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback? onAction;
  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(EsnaftaVarSpacing.md),
      child: EsnaftaVarStateCard(
        key: const Key('customer-saved-locations-status'),
        icon: icon,
        title: title,
        message: description,
        actionLabel: actionLabel,
        onAction: onAction,
      ),
    ),
  );
}
