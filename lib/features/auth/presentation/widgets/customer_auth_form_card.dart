import 'package:flutter/material.dart';
import 'package:t_store/core/common/widgets/customer_light_input_theme.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';

class CustomerAuthFormCard extends StatelessWidget {
  const CustomerAuthFormCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(
      horizontal: CustomerHomeV1Tokens.space16,
    ),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final fieldBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius16),
      borderSide: const BorderSide(color: CustomerHomeV1Tokens.border),
    );

    return Container(
      padding: padding,
      decoration: BoxDecoration(
        color: CustomerHomeV1Tokens.surface,
        borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.radius24),
        border: Border.all(color: CustomerHomeV1Tokens.border),
        boxShadow: CustomerHomeV1Tokens.softShadow,
      ),
      child: Theme(
        data: theme.copyWith(
          inputDecorationTheme: theme.inputDecorationTheme.copyWith(
            filled: true,
            fillColor: CustomerHomeV1Tokens.cream,
            prefixIconColor: CustomerHomeV1Tokens.petrol,
            suffixIconColor: CustomerHomeV1Tokens.petrol,
            labelStyle: const TextStyle(color: CustomerHomeV1Tokens.muted),
            floatingLabelStyle: const TextStyle(
              color: CustomerHomeV1Tokens.petrol,
              fontWeight: FontWeight.w600,
            ),
            border: fieldBorder,
            enabledBorder: fieldBorder,
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(
                CustomerHomeV1Tokens.radius16,
              ),
              borderSide: const BorderSide(
                color: CustomerHomeV1Tokens.petrol,
                width: 1.5,
              ),
            ),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: CustomerHomeV1Tokens.petrol,
              foregroundColor: Colors.white,
              disabledBackgroundColor: CustomerHomeV1Tokens.mint,
              disabledForegroundColor: CustomerHomeV1Tokens.muted,
              minimumSize: const Size(double.infinity, 52),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  CustomerHomeV1Tokens.radius16,
                ),
              ),
            ),
          ),
          outlinedButtonTheme: OutlinedButtonThemeData(
            style: OutlinedButton.styleFrom(
              foregroundColor: CustomerHomeV1Tokens.petrol,
              minimumSize: const Size(double.infinity, 52),
              side: const BorderSide(color: CustomerHomeV1Tokens.petrol),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  CustomerHomeV1Tokens.radius16,
                ),
              ),
            ),
          ),
          textButtonTheme: TextButtonThemeData(
            style: TextButton.styleFrom(
              foregroundColor: CustomerHomeV1Tokens.petrol,
            ),
          ),
          checkboxTheme: CheckboxThemeData(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(CustomerHomeV1Tokens.space4),
            ),
            fillColor: WidgetStateProperty.resolveWith((states) {
              if (states.contains(WidgetState.selected)) {
                return CustomerHomeV1Tokens.petrol;
              }
              return Colors.transparent;
            }),
          ),
        ),
        child: CustomerLightInputTheme(child: child),
      ),
    );
  }
}
