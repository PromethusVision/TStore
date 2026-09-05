import 'package:flutter/material.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';

class TLoadingIndicator extends StatelessWidget {
  final double size;
  final Color? color;
  final String label;

  const TLoadingIndicator({
    super.key,
    this.size = 40.0,
    this.color,
    this.label = 'Yükleniyor',
  });

  @override
  Widget build(BuildContext context) {
    final Color indicatorColor = color ?? EsnaftaVarColors.primary;

    return SizedBox(
      width: size,
      height: size,
      child: CircularProgressIndicator(
        semanticsLabel: label,
        strokeWidth: 3.0,
        valueColor: AlwaysStoppedAnimation<Color>(indicatorColor),
        backgroundColor: EsnaftaVarColors.primarySoft,
      ),
    );
  }
}
