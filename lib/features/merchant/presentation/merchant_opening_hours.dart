import 'package:flutter/material.dart';
import 'package:t_store/features/shop/domain/entities/shop_opening_hours.dart';

class MerchantOpeningHours extends StatefulWidget {
  const MerchantOpeningHours({
    super.key,
    required this.value,
    required this.onChanged,
    required this.isCurrent,
    this.enabled = true,
  });
  final Map<String, dynamic> value;
  final ValueChanged<Map<String, dynamic>> onChanged;
  final bool Function() isCurrent;
  final bool enabled;

  @override
  State<MerchantOpeningHours> createState() => _MerchantOpeningHoursState();
}

class _MerchantOpeningHoursState extends State<MerchantOpeningHours> {
  Map<String, dynamic> get value => widget.value;
  ValueChanged<Map<String, dynamic>> get onChanged => widget.onChanged;
  bool Function() get isCurrent => widget.isCurrent;
  bool get enabled => widget.enabled;
  bool _editing = false;

  Future<void> _edit(BuildContext context, String day) async {
    if (_editing || !enabled || !isCurrent()) return;
    _editing = true;
    try {
      await _choose(context, day);
    } finally {
      _editing = false;
    }
  }

  Future<void> _choose(BuildContext context, String day) async {
    if (!enabled || !isCurrent()) return;
    final old = ShopOpeningHours.value(value, day);
    final choice = await showDialog<String>(
      context: context,
      builder: (ctx) => !isCurrent()
          ? const SizedBox.shrink()
          : SimpleDialog(
              title: Text(ShopOpeningHours.days[day]!),
              children: [
                for (final option in {
                  'hours': 'Saat seç',
                  'closed': 'Kapalı',
                  '': 'Belirtilmedi',
                }.entries)
                  SimpleDialogOption(
                    onPressed: () => Navigator.pop(ctx, option.key),
                    child: Text(option.value),
                  ),
              ],
            ),
    );
    if (!context.mounted || !isCurrent() || choice == null) return;
    String next = choice;
    if (choice == 'hours') {
      final previous = ShopOpeningHours.minutes(old);
      final start = await showTimePicker(
        context: context,
        cancelText: 'Vazgeç',
        confirmText: 'Onayla',
        hourLabelText: 'Saat',
        minuteLabelText: 'Dakika',
        errorInvalidText: 'Geçerli bir saat seçin.',
        helpText: '${ShopOpeningHours.days[day]} · Açılış',
        initialTime: TimeOfDay(
          hour: (previous?[0] ?? 540) ~/ 60,
          minute: (previous?[0] ?? 540) % 60,
        ),
        builder: (ctx, child) => !isCurrent()
            ? const SizedBox.shrink()
            : MediaQuery(
                data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
                child: child!,
              ),
      );
      if (!context.mounted || !isCurrent() || start == null) return;
      final end = await showTimePicker(
        context: context,
        cancelText: 'Vazgeç',
        confirmText: 'Onayla',
        hourLabelText: 'Saat',
        minuteLabelText: 'Dakika',
        errorInvalidText: 'Geçerli bir saat seçin.',
        helpText: '${ShopOpeningHours.days[day]} · Kapanış',
        initialTime: TimeOfDay(
          hour: (previous?[1] ?? 1080) ~/ 60,
          minute: (previous?[1] ?? 1080) % 60,
        ),
        builder: (ctx, child) => !isCurrent()
            ? const SizedBox.shrink()
            : MediaQuery(
                data: MediaQuery.of(ctx).copyWith(alwaysUse24HourFormat: true),
                child: child!,
              ),
      );
      if (!context.mounted || !isCurrent() || end == null) return;
      final from = start.hour * 60 + start.minute,
          to = end.hour * 60 + end.minute;
      if (from == to) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Açılış ve kapanış saatleri farklı olmalı.'),
          ),
        );
        return;
      }
      next = ShopOpeningHours.range(from, to);
    }
    if (isCurrent()) onChanged({...value, day: next});
  }

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text('Çalışma saatleri', style: Theme.of(context).textTheme.titleMedium),
      const Text(
        'Her gün için saat seçebilir veya Kapalı olarak işaretleyebilirsin.',
      ),
      for (final day in ShopOpeningHours.days.entries)
        ListTile(
          contentPadding: EdgeInsets.zero,
          key: ValueKey('hours-${day.key}'),
          title: Text(day.value),
          subtitle: Text(
            ShopOpeningHours.label(ShopOpeningHours.value(value, day.key)),
          ),
          trailing: const Icon(Icons.edit_outlined),
          enabled: enabled,
          onTap: () => _edit(context, day.key),
        ),
      TextButton(
        onPressed: !enabled
            ? null
            : () {
                if (!isCurrent()) return;
                final monday = ShopOpeningHours.value(value, 'mon') ?? '';
                onChanged({
                  ...value,
                  for (final day in ['mon', 'tue', 'wed', 'thu', 'fri'])
                    day: monday,
                });
              },
        child: const Text('Pazartesi saatlerini hafta içine uygula'),
      ),
    ],
  );
}
