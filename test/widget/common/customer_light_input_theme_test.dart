import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/common/widgets/customer_light_input_theme.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
import 'package:t_store/core/utils/theme/theme.dart';

void main() {
  testWidgets(
    'dark system theme keeps value, hint, cursor, and selection readable on light inputs',
    (tester) async {
      final controller = TextEditingController(text: 'Okunabilir değer');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        MaterialApp(
          theme: TAppTheme.lightTheme,
          darkTheme: TAppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: Scaffold(
            backgroundColor: CustomerHomeV1Tokens.cream,
            body: CustomerLightInputTheme(
              child: TextField(
                key: const Key('light-surface-input'),
                controller: controller,
                decoration: const InputDecoration(
                  hintText: 'İpucu',
                  labelText: 'Etiket',
                ),
              ),
            ),
          ),
        ),
      );

      final editableText = tester.widget<EditableText>(
        find.descendant(
          of: find.byKey(const Key('light-surface-input')),
          matching: find.byType(EditableText),
        ),
      );
      final decoration = tester.widget<InputDecorator>(
        find.descendant(
          of: find.byKey(const Key('light-surface-input')),
          matching: find.byType(InputDecorator),
        ),
      );

      expect(editableText.style.color, CustomerHomeV1Tokens.navy);
      expect(editableText.cursorColor, CustomerHomeV1Tokens.petrol);
      expect(
        Theme.of(
          tester.element(find.byKey(const Key('light-surface-input'))),
        ).textSelectionTheme.selectionColor,
        CustomerHomeV1Tokens.petrol.withValues(alpha: 0.24),
      );
      expect(
        decoration.decoration.hintStyle?.color,
        CustomerHomeV1Tokens.muted,
      );
      expect(
        decoration.decoration.labelStyle?.color,
        CustomerHomeV1Tokens.muted,
      );
    },
  );

  testWidgets(
    'password obscuring remains enabled inside the light input theme',
    (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          darkTheme: TAppTheme.darkTheme,
          themeMode: ThemeMode.dark,
          home: const Scaffold(
            body: CustomerLightInputTheme(
              child: TextField(key: Key('password-input'), obscureText: true),
            ),
          ),
        ),
      );

      final editableText = tester.widget<EditableText>(
        find.descendant(
          of: find.byKey(const Key('password-input')),
          matching: find.byType(EditableText),
        ),
      );

      expect(editableText.obscureText, isTrue);
      expect(editableText.style.color, CustomerHomeV1Tokens.navy);
    },
  );
}
