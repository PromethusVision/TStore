import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:t_store/core/common/view_models/app_bar_view_model.dart';
import 'package:t_store/core/common/widgets/app_bar.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/features/shop/domain/entities/shop_entity.dart';
import 'package:t_store/features/shop/presentation/cubit/my_shop_cubit.dart';
import 'package:t_store/features/shop/presentation/cubit/my_shop_state.dart';

class MyShopFormView extends StatefulWidget {
  final ShopEntity? shop;

  const MyShopFormView({super.key, this.shop});

  @override
  State<MyShopFormView> createState() => _MyShopFormViewState();
}

class _MyShopFormViewState extends State<MyShopFormView> {
  final _formKey = GlobalKey<FormState>();

  late final TextEditingController _nameController;
  late final TextEditingController _descriptionController;
  late final TextEditingController _phoneController;
  late final TextEditingController _addressController;
  late final TextEditingController _weekdayHoursController;
  late final TextEditingController _saturdayHoursController;
  late final TextEditingController _sundayHoursController;
  late final Map<String, dynamic> _originalOpeningHours;

  bool _didPopAfterSuccess = false;

  bool get _isEditMode => widget.shop != null;

  MyShopSaveOperation get _operation =>
      _isEditMode ? MyShopSaveOperation.update : MyShopSaveOperation.create;

  @override
  void initState() {
    super.initState();

    final shop = widget.shop;
    _originalOpeningHours = Map<String, dynamic>.from(
      shop?.openingHours ?? const <String, dynamic>{},
    );

    _nameController = TextEditingController(text: shop?.name ?? '');
    _descriptionController = TextEditingController(
      text: shop?.description ?? '',
    );
    _phoneController = TextEditingController(text: shop?.phone ?? '');
    _addressController = TextEditingController(text: shop?.address ?? '');
    _weekdayHoursController = TextEditingController(
      text: _openingHourText(
        _originalOpeningHours['mon_fri'] ?? _originalOpeningHours['mon_sat'],
      ),
    );
    _saturdayHoursController = TextEditingController(
      text: _openingHourText(
        _originalOpeningHours['sat'] ?? _originalOpeningHours['mon_sat'],
      ),
    );
    _sundayHoursController = TextEditingController(
      text: _openingHourText(_originalOpeningHours['sun']),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _descriptionController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _weekdayHoursController.dispose();
    _saturdayHoursController.dispose();
    _sundayHoursController.dispose();
    super.dispose();
  }

  bool _matchesOperation(MyShopSaveOperation operation) {
    return operation == _operation;
  }

  Future<void> _submit() async {
    final cubit = context.read<MyShopCubit>();
    if (cubit.state is MyShopSaving) return;

    final formState = _formKey.currentState;
    if (formState == null || !formState.validate()) return;

    FocusScope.of(context).unfocus();

    final name = _nameController.text.trim();
    final description = _trimToNull(_descriptionController.text);
    final phone = _trimToNull(_phoneController.text);
    final address = _trimToNull(_addressController.text);
    final openingHours = _buildOpeningHours();

    if (_isEditMode) {
      await cubit.updateMyShop(
        shopId: widget.shop!.id,
        name: name,
        description: description,
        phone: phone,
        address: address,
        openingHours: openingHours,
      );
      return;
    }

    await cubit.createMyShop(
      name: name,
      description: description,
      phone: phone,
      address: address,
      openingHours: openingHours,
    );
  }

  Map<String, dynamic> _buildOpeningHours() {
    final weekday = _weekdayHoursController.text.trim();
    final saturday = _saturdayHoursController.text.trim();
    final sunday = _sundayHoursController.text.trim();

    if (weekday.isEmpty && saturday.isEmpty && sunday.isEmpty) {
      return <String, dynamic>{};
    }

    final openingHours = Map<String, dynamic>.from(_originalOpeningHours)
      ..remove('mon_sat');

    _setOrRemove(openingHours, 'mon_fri', weekday);
    _setOrRemove(openingHours, 'sat', saturday);
    _setOrRemove(openingHours, 'sun', sunday);

    return openingHours;
  }

  static void _setOrRemove(
    Map<String, dynamic> openingHours,
    String key,
    String value,
  ) {
    if (value.isEmpty) {
      openingHours.remove(key);
    } else {
      openingHours[key] = value;
    }
  }

  static String _openingHourText(dynamic value) {
    return value?.toString() ?? '';
  }

  static String? _trimToNull(String value) {
    final trimmed = value.trim();
    return trimmed.isEmpty ? null : trimmed;
  }

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final title = _isEditMode ? 'Mağazayı Düzenle' : 'Mağaza Oluştur';
    final submitLabel = _isEditMode
        ? 'Değişiklikleri Kaydet'
        : 'Mağaza Oluştur';

    return BlocListener<MyShopCubit, MyShopState>(
      listenWhen: (previous, current) {
        if (current is MyShopSaveFailure) {
          return _matchesOperation(current.operation);
        }
        if (current is MyShopSaveSuccess) {
          return _matchesOperation(current.operation);
        }
        return false;
      },
      listener: (context, state) {
        if (state is MyShopSaveFailure) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.message)));
          return;
        }

        if (state is MyShopSaveSuccess) {
          if (_didPopAfterSuccess || !context.mounted) return;
          _didPopAfterSuccess = true;
          Navigator.of(context).pop(state.shop);
        }
      },
      child: Scaffold(
        appBar: CustomAppBar(
          appBarModel: AppBarModel(title: Text(title), hasArrowBack: true),
        ),
        body: SafeArea(
          child: SingleChildScrollView(
            padding: EdgeInsets.fromLTRB(
              TSizes.defaultSpace,
              TSizes.defaultSpace,
              TSizes.defaultSpace,
              TSizes.defaultSpace + MediaQuery.of(context).viewInsets.bottom,
            ),
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  TextFormField(
                    controller: _nameController,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Mağaza adı',
                      prefixIcon: Icon(Icons.storefront_outlined),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) {
                        return 'Mağaza adı zorunludur.';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),
                  TextFormField(
                    controller: _descriptionController,
                    minLines: 3,
                    maxLines: 5,
                    textInputAction: TextInputAction.newline,
                    decoration: const InputDecoration(
                      labelText: 'Açıklama',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),
                  TextFormField(
                    controller: _phoneController,
                    keyboardType: TextInputType.phone,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Telefon',
                      prefixIcon: Icon(Icons.call_outlined),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),
                  TextFormField(
                    controller: _addressController,
                    minLines: 2,
                    maxLines: 4,
                    textInputAction: TextInputAction.newline,
                    decoration: const InputDecoration(
                      labelText: 'Adres',
                      alignLabelWithHint: true,
                      prefixIcon: Icon(Icons.location_on_outlined),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                  Text(
                    'Çalışma saatleri',
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  const SizedBox(height: TSizes.sm),
                  Text(
                    'Kapalı günleri boş bırakabilirsiniz.',
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),
                  TextFormField(
                    controller: _weekdayHoursController,
                    keyboardType: TextInputType.datetime,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Hafta içi',
                      hintText: '09:00 - 18:00',
                      prefixIcon: Icon(Icons.schedule_outlined),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),
                  TextFormField(
                    controller: _saturdayHoursController,
                    keyboardType: TextInputType.datetime,
                    textInputAction: TextInputAction.next,
                    decoration: const InputDecoration(
                      labelText: 'Cumartesi',
                      hintText: '09:00 - 18:00',
                      prefixIcon: Icon(Icons.schedule_outlined),
                    ),
                  ),
                  const SizedBox(height: TSizes.spaceBtwInputFields),
                  TextFormField(
                    controller: _sundayHoursController,
                    keyboardType: TextInputType.datetime,
                    textInputAction: TextInputAction.done,
                    decoration: const InputDecoration(
                      labelText: 'Pazar',
                      hintText: '09:00 - 18:00',
                      prefixIcon: Icon(Icons.schedule_outlined),
                    ),
                    onFieldSubmitted: (_) => _submit(),
                  ),
                  const SizedBox(height: TSizes.spaceBtwSections),
                  BlocBuilder<MyShopCubit, MyShopState>(
                    buildWhen: (previous, current) {
                      return previous is MyShopSaving ||
                          current is MyShopSaving;
                    },
                    builder: (context, state) {
                      final isSaving = state is MyShopSaving;

                      return SizedBox(
                        width: double.infinity,
                        child: FilledButton(
                          onPressed: isSaving ? null : _submit,
                          child: isSaving
                              ? SizedBox(
                                  width: 20,
                                  height: 20,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: colorScheme.onPrimary,
                                  ),
                                )
                              : Text(submitLabel),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
