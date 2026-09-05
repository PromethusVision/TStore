import 'package:flutter/material.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';

class ForgetPasswordHeaderSection extends StatelessWidget {
  const ForgetPasswordHeaderSection({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          TTexts.forgetPasswordTitle,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            color: EsnaftaVarColors.textPrimary,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: EsnaftaVarSpacing.xs),
        Text(
          TTexts.forgetPasswordSubTitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: EsnaftaVarColors.textSecondary,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
