import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/widgets/customer_light_input_theme.dart';
import 'package:t_store/core/dependency_injection/service_locator.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
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
    return Scaffold(
      backgroundColor: CustomerHomeV1Tokens.cream,
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            key: const Key('customer-saved-locations-content'),
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
                  child: _SavedLocationsHeader(),
                ),
                const SizedBox(height: CustomerHomeV1Tokens.space12),
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

                return AlertDialog(
                  backgroundColor: CustomerHomeV1Tokens.surface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      CustomerHomeV1Tokens.radius20,
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
                        backgroundColor: CustomerHomeV1Tokens.coral,
                      ),
                      child: const Text('Sil'),
                    ),
                  ],
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
  Widget build(BuildContext context) {
    return Container(
      key: const Key('customer-saved-locations-header'),
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
              key: const Key('customer-saved-locations-back-button'),
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
                  'Kayıtlı Konumlarım',
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
                  'Yakındaki mağazalar için ana konumunu seç',
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
              color: const Color(0xFFFFE4DE),
              borderRadius: BorderRadius.circular(
                CustomerHomeV1Tokens.radius12,
              ),
            ),
            child: const Icon(
              Icons.location_on_outlined,
              color: CustomerHomeV1Tokens.coral,
              size: 21,
            ),
          ),
        ],
      ),
    );
  }
}

class _SavedLocationsLoadingState extends StatelessWidget {
  const _SavedLocationsLoadingState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Container(
        key: const Key('customer-saved-locations-loading-state'),
        margin: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
        padding: const EdgeInsets.symmetric(
          horizontal: CustomerHomeV1Tokens.space24,
          vertical: CustomerHomeV1Tokens.space20,
        ),
        decoration: BoxDecoration(
          color: CustomerHomeV1Tokens.surface,
          borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
          border: Border.all(color: CustomerHomeV1Tokens.border),
          boxShadow: CustomerHomeV1Tokens.softShadow,
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            SizedBox(
              width: 22,
              height: 22,
              child: CircularProgressIndicator(
                strokeWidth: 2.5,
                color: CustomerHomeV1Tokens.petrol,
              ),
            ),
            SizedBox(width: CustomerHomeV1Tokens.space12),
            Flexible(
              child: Text(
                'Konumların yükleniyor',
                style: TextStyle(
                  color: CustomerHomeV1Tokens.navy,
                  fontSize: 13,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
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
            color: CustomerHomeV1Tokens.petrol,
            onRefresh: () =>
                context.read<CustomerSavedLocationsCubit>().loadLocations(),
            child: ListView.separated(
              key: const Key('customer-saved-locations-list'),
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(
                CustomerHomeV1Tokens.space16,
                CustomerHomeV1Tokens.space4,
                CustomerHomeV1Tokens.space16,
                CustomerHomeV1Tokens.space12,
              ),
              itemCount: state.locations.length + 1,
              separatorBuilder: (_, _) =>
                  const SizedBox(height: CustomerHomeV1Tokens.space12),
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
            CustomerHomeV1Tokens.space16,
            CustomerHomeV1Tokens.space8,
            CustomerHomeV1Tokens.space16,
            CustomerHomeV1Tokens.space12,
          ),
          color: CustomerHomeV1Tokens.cream,
          child: FilledButton.icon(
            key: const Key('saved-location-add-button'),
            onPressed: isInteractionBlocked ? null : onAddLocation,
            style: FilledButton.styleFrom(
              backgroundColor: CustomerHomeV1Tokens.petrol,
              foregroundColor: Colors.white,
              disabledBackgroundColor: CustomerHomeV1Tokens.mint,
              disabledForegroundColor: CustomerHomeV1Tokens.muted,
              padding: const EdgeInsets.symmetric(
                vertical: CustomerHomeV1Tokens.space12,
              ),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  CustomerHomeV1Tokens.radius12,
                ),
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
      padding: const EdgeInsets.all(CustomerHomeV1Tokens.space12),
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.mint.withValues(alpha: 0.65),
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
        border: Border.all(
          color: CustomerHomeV1Tokens.petrol.withValues(alpha: 0.12),
        ),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            Icons.info_outline_rounded,
            color: CustomerHomeV1Tokens.petrol,
            size: 20,
          ),
          SizedBox(width: CustomerHomeV1Tokens.space8),
          Expanded(
            child: Text(
              'Kaydettiğin konumlardan birini ana konum olarak belirleyebilirsin.',
              style: TextStyle(
                color: CustomerHomeV1Tokens.petrol,
                fontSize: 11,
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
  Widget build(BuildContext context) {
    return Semantics(
      label:
          '${location.name}, ${location.addressText}${location.isDefault ? ', ana konum' : ''}',
      child: Container(
        key: Key('saved-location-card-${location.id}'),
        padding: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
        decoration: BoxDecoration(
          color: CustomerHomeV1Tokens.surface,
          borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
          border: Border.all(
            color: location.isDefault
                ? CustomerHomeV1Tokens.petrol.withValues(alpha: 0.35)
                : CustomerHomeV1Tokens.border,
          ),
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
                    color: location.isDefault
                        ? CustomerHomeV1Tokens.mint
                        : CustomerHomeV1Tokens.cream,
                    shape: BoxShape.circle,
                    border: Border.all(color: CustomerHomeV1Tokens.border),
                  ),
                  child: Icon(
                    _iconForName(location.name),
                    color: CustomerHomeV1Tokens.petrol,
                    size: 21,
                  ),
                ),
                const SizedBox(width: CustomerHomeV1Tokens.space12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Text(
                              location.name,
                              maxLines: 2,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: CustomerHomeV1Tokens.navy,
                                fontSize: 15,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                          if (location.isDefault) ...[
                            const SizedBox(width: CustomerHomeV1Tokens.space8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: CustomerHomeV1Tokens.space8,
                                vertical: CustomerHomeV1Tokens.space4,
                              ),
                              decoration: BoxDecoration(
                                color: CustomerHomeV1Tokens.petrol,
                                borderRadius: BorderRadius.circular(
                                  CustomerHomeV1Tokens.radiusPill,
                                ),
                              ),
                              child: const Text(
                                'Ana Konum',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w800,
                                ),
                              ),
                            ),
                          ],
                        ],
                      ),
                      const SizedBox(height: CustomerHomeV1Tokens.space4),
                      Text(
                        location.addressText,
                        style: const TextStyle(
                          color: CustomerHomeV1Tokens.muted,
                          fontSize: 11.5,
                          height: 1.4,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: CustomerHomeV1Tokens.space12),
            const Divider(height: 1, color: CustomerHomeV1Tokens.border),
            const SizedBox(height: CustomerHomeV1Tokens.space8),
            Row(
              children: [
                if (!location.isDefault)
                  Expanded(
                    child: TextButton.icon(
                      onPressed: isBusy ? null : onSetDefault,
                      style: TextButton.styleFrom(
                        foregroundColor: CustomerHomeV1Tokens.petrol,
                        alignment: Alignment.centerLeft,
                        padding: const EdgeInsets.symmetric(
                          horizontal: CustomerHomeV1Tokens.space8,
                        ),
                      ),
                      icon: const Icon(Icons.check_circle_outline, size: 18),
                      label: const Text(
                        'Ana Konum Yap',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  )
                else
                  const Expanded(
                    child: Text(
                      'Yakındaki sonuçlarda kullanılıyor',
                      style: TextStyle(
                        color: CustomerHomeV1Tokens.green,
                        fontSize: 10.5,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                if (isCurrentOperation)
                  const SizedBox(
                    width: 24,
                    height: 24,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: CustomerHomeV1Tokens.petrol,
                    ),
                  )
                else
                  IconButton(
                    tooltip: 'Konumu sil',
                    onPressed: isBusy ? null : onDelete,
                    color: CustomerHomeV1Tokens.coral,
                    icon: const Icon(Icons.delete_outline_rounded, size: 20),
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
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomCenter,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 430),
        child: Container(
          key: const Key('saved-location-add-sheet'),
          decoration: const BoxDecoration(
            color: CustomerHomeV1Tokens.surface,
            borderRadius: BorderRadius.vertical(
              top: Radius.circular(CustomerHomeV1Tokens.radius24),
            ),
          ),
          padding: EdgeInsets.only(
            left: CustomerHomeV1Tokens.space20,
            right: CustomerHomeV1Tokens.space20,
            top: CustomerHomeV1Tokens.space16,
            bottom:
                MediaQuery.viewInsetsOf(context).bottom +
                CustomerHomeV1Tokens.space20,
          ),
          child: SingleChildScrollView(
            child: CustomerLightInputTheme(
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
                          color: CustomerHomeV1Tokens.border,
                          borderRadius: BorderRadius.circular(
                            CustomerHomeV1Tokens.radiusPill,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: CustomerHomeV1Tokens.space16),
                    const Row(
                      children: [
                        CircleAvatar(
                          radius: 22,
                          backgroundColor: CustomerHomeV1Tokens.mint,
                          child: Icon(
                            Icons.add_location_alt_outlined,
                            color: CustomerHomeV1Tokens.petrol,
                            size: 22,
                          ),
                        ),
                        SizedBox(width: CustomerHomeV1Tokens.space12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Konum Ekle',
                                style: TextStyle(
                                  color: CustomerHomeV1Tokens.navy,
                                  fontSize: 19,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              SizedBox(height: CustomerHomeV1Tokens.space4),
                              Text(
                                'Mevcut GPS konumunu kaydet',
                                style: TextStyle(
                                  color: CustomerHomeV1Tokens.muted,
                                  fontSize: 10.5,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: CustomerHomeV1Tokens.space12),
                    const Text(
                      'Konumunu bulduktan sonra kolay hatırlayacağın bir ad ve adres açıklaması ekle.',
                      style: TextStyle(
                        color: CustomerHomeV1Tokens.muted,
                        fontSize: 12,
                        height: 1.4,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: CustomerHomeV1Tokens.space16),
                    TextFormField(
                      key: const Key('saved-location-name-field'),
                      controller: _nameController,
                      textInputAction: TextInputAction.next,
                      maxLength: 50,
                      decoration: _inputDecoration(
                        label: 'Konum Adı',
                        hint: 'Ev, İş veya başka bir ad',
                        icon: Icons.label_outline_rounded,
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Konum adı gerekli.'
                          : null,
                    ),
                    const SizedBox(height: CustomerHomeV1Tokens.space8),
                    TextFormField(
                      key: const Key('saved-location-address-field'),
                      controller: _addressController,
                      textInputAction: TextInputAction.done,
                      minLines: 2,
                      maxLines: 3,
                      maxLength: 200,
                      decoration: _inputDecoration(
                        label: 'Adres Açıklaması',
                        hint: 'Örn. Esenler, İstanbul',
                        icon: Icons.location_on_outlined,
                      ).copyWith(alignLabelWithHint: true),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? 'Adres açıklaması gerekli.'
                          : null,
                    ),
                    const SizedBox(height: CustomerHomeV1Tokens.space8),
                    SizedBox(
                      width: double.infinity,
                      child: OutlinedButton.icon(
                        key: const Key('saved-location-capture-button'),
                        onPressed: _isLocating || _isSaving
                            ? null
                            : _captureLocation,
                        style: OutlinedButton.styleFrom(
                          foregroundColor: CustomerHomeV1Tokens.petrol,
                          side: const BorderSide(
                            color: CustomerHomeV1Tokens.petrol,
                          ),
                          padding: const EdgeInsets.symmetric(
                            vertical: CustomerHomeV1Tokens.space12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              CustomerHomeV1Tokens.radius12,
                            ),
                          ),
                        ),
                        icon: _isLocating
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: CustomerHomeV1Tokens.petrol,
                                ),
                              )
                            : Icon(
                                _coordinates == null
                                    ? Icons.my_location_rounded
                                    : Icons.check_circle_rounded,
                              ),
                        label: Text(
                          _coordinates == null
                              ? 'Mevcut Konumumu Al'
                              : 'Konum Alındı',
                        ),
                      ),
                    ),
                    if (_locationError != null) ...[
                      const SizedBox(height: CustomerHomeV1Tokens.space8),
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(
                          CustomerHomeV1Tokens.space12,
                        ),
                        decoration: BoxDecoration(
                          color: const Color(0xFFFFE4DE),
                          borderRadius: BorderRadius.circular(
                            CustomerHomeV1Tokens.radius12,
                          ),
                        ),
                        child: Text(
                          _locationError!,
                          style: const TextStyle(
                            color: CustomerHomeV1Tokens.coral,
                            fontSize: 11,
                            height: 1.35,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(height: CustomerHomeV1Tokens.space16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton(
                        key: const Key('saved-location-save-button'),
                        onPressed: _isSaving || _isLocating ? null : _save,
                        style: FilledButton.styleFrom(
                          backgroundColor: CustomerHomeV1Tokens.petrol,
                          foregroundColor: Colors.white,
                          disabledBackgroundColor: CustomerHomeV1Tokens.mint,
                          padding: const EdgeInsets.symmetric(
                            vertical: CustomerHomeV1Tokens.space12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(
                              CustomerHomeV1Tokens.radius12,
                            ),
                          ),
                        ),
                        child: _isSaving
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: CustomerHomeV1Tokens.petrol,
                                ),
                              )
                            : const Text('Konumu Kaydet'),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String label,
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      labelText: label,
      hintText: hint,
      prefixIcon: Icon(icon, color: CustomerHomeV1Tokens.petrol),
      filled: true,
      fillColor: CustomerHomeV1Tokens.cream,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius12),
        borderSide: const BorderSide(color: CustomerHomeV1Tokens.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius12),
        borderSide: const BorderSide(color: CustomerHomeV1Tokens.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius12),
        borderSide: const BorderSide(
          color: CustomerHomeV1Tokens.petrol,
          width: 1.4,
        ),
      ),
    );
  }

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
    required this.onAction,
  });

  final IconData icon;
  final String title;
  final String description;
  final String actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(CustomerHomeV1Tokens.space16),
        child: Container(
          key: const Key('customer-saved-locations-status'),
          width: double.infinity,
          padding: const EdgeInsets.all(CustomerHomeV1Tokens.space24),
          decoration: BoxDecoration(
            color: CustomerHomeV1Tokens.surface,
            borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius20),
            border: Border.all(color: CustomerHomeV1Tokens.border),
            boxShadow: CustomerHomeV1Tokens.softShadow,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 58,
                height: 58,
                decoration: const BoxDecoration(
                  color: CustomerHomeV1Tokens.mint,
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, size: 29, color: CustomerHomeV1Tokens.petrol),
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space16),
              Text(
                title,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CustomerHomeV1Tokens.navy,
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space8),
              Text(
                description,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: CustomerHomeV1Tokens.muted,
                  fontSize: 12.5,
                  height: 1.45,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: CustomerHomeV1Tokens.space20),
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: onAction,
                  style: OutlinedButton.styleFrom(
                    foregroundColor: CustomerHomeV1Tokens.petrol,
                    side: const BorderSide(color: CustomerHomeV1Tokens.petrol),
                    padding: const EdgeInsets.symmetric(
                      vertical: CustomerHomeV1Tokens.space12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(
                        CustomerHomeV1Tokens.radius12,
                      ),
                    ),
                  ),
                  icon: Icon(
                    actionLabel == 'Tekrar Dene'
                        ? Icons.refresh_rounded
                        : Icons.add_location_alt_outlined,
                    size: 19,
                  ),
                  label: Text(actionLabel),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
