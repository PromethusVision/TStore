import 'package:flutter/material.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';

/// Light-mode customer shell used by the final UI rollout screens.
class EsnaftaVarScaffold extends StatelessWidget {
  const EsnaftaVarScaffold({
    super.key,
    required this.body,
    this.bottomNavigationBar,
    this.safeAreaTop = true,
    this.safeAreaBottom = false,
  });

  final Widget body;
  final Widget? bottomNavigationBar;
  final bool safeAreaTop;
  final bool safeAreaBottom;

  @override
  Widget build(BuildContext context) {
    return Theme(
      data: EsnaftaVarTheme.light,
      child: Scaffold(
        backgroundColor: EsnaftaVarColors.background,
        bottomNavigationBar: bottomNavigationBar,
        body: SafeArea(top: safeAreaTop, bottom: safeAreaBottom, child: body),
      ),
    );
  }
}
