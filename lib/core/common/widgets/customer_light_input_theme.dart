import 'package:flutter/material.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';

/// Keeps editable content readable on the customer's intentionally light
/// input surfaces even when the device uses a dark system theme.
class CustomerLightInputTheme extends StatelessWidget {
  const CustomerLightInputTheme({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final inputDecorationTheme = theme.inputDecorationTheme;
    final valueStyle = (theme.textTheme.bodyLarge ?? const TextStyle())
        .copyWith(color: CustomerHomeV1Tokens.navy);

    return Theme(
      data: theme.copyWith(
        textTheme: theme.textTheme.copyWith(bodyLarge: valueStyle),
        textSelectionTheme: theme.textSelectionTheme.copyWith(
          cursorColor: CustomerHomeV1Tokens.petrol,
          selectionColor: CustomerHomeV1Tokens.petrol.withValues(alpha: 0.24),
          selectionHandleColor: CustomerHomeV1Tokens.petrol,
        ),
        inputDecorationTheme: inputDecorationTheme.copyWith(
          labelStyle: (inputDecorationTheme.labelStyle ?? const TextStyle())
              .copyWith(color: CustomerHomeV1Tokens.muted),
          hintStyle: (inputDecorationTheme.hintStyle ?? const TextStyle())
              .copyWith(color: CustomerHomeV1Tokens.muted),
          floatingLabelStyle:
              (inputDecorationTheme.floatingLabelStyle ?? const TextStyle())
                  .copyWith(color: CustomerHomeV1Tokens.petrol),
          prefixIconColor: CustomerHomeV1Tokens.petrol,
          suffixIconColor: CustomerHomeV1Tokens.petrol,
          errorStyle: (inputDecorationTheme.errorStyle ?? const TextStyle())
              .copyWith(color: CustomerHomeV1Tokens.coral),
        ),
      ),
      child: child,
    );
  }
}
