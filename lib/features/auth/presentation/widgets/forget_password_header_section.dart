import 'package:flutter/material.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';
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
            color: CustomerHomeV1Tokens.navy,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: CustomerHomeV1Tokens.space8),
        Text(
          TTexts.forgetPasswordSubTitle,
          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: CustomerHomeV1Tokens.muted,
            height: 1.4,
          ),
        ),
      ],
    );
  }
}
