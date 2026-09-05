import 'package:flutter/material.dart';
import 'package:t_store/core/common/widgets/customer_light_input_theme.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';

/// Auth form composition; field/button styling comes from the Final UI theme.
class CustomerAuthFormCard extends StatelessWidget {
  const CustomerAuthFormCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.symmetric(horizontal: EsnaftaVarSpacing.md),
  });

  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) {
    final theme = EsnaftaVarTheme.light;
    return Theme(
      data: theme.copyWith(
        inputDecorationTheme: theme.inputDecorationTheme.copyWith(
          errorMaxLines: 4,
        ),
      ),
      child: Card(
        child: Padding(
          padding: padding,
          child: CustomerLightInputTheme(
            child: AutofillGroup(
              onDisposeAction: AutofillContextAction.cancel,
              child: child,
            ),
          ),
        ),
      ),
    );
  }
}
