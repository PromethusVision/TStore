import 'package:flutter/material.dart';
import 'package:t_store/core/common/widgets/customer_brand_wordmark.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/core/utils/constants/image_strings.dart';
import 'package:t_store/core/utils/constants/sizes.dart';
import 'package:t_store/core/utils/constants/text_strings.dart';
import 'package:t_store/core/utils/helpers/helper_functions.dart';

class LoginHeaderSection extends StatelessWidget {
  final bool isMerchantLogin;

  const LoginHeaderSection({super.key, this.isMerchantLogin = false});

  @override
  Widget build(BuildContext context) {
    if (!isMerchantLogin) {
      return Column(
        key: const Key('customer-login-header'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const CustomerBrandWordmark(key: Key('login-wordmark'), fontSize: 34),
          const SizedBox(height: EsnaftaVarSpacing.xl),
          Text(
            TTexts.loginTitle,
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              color: EsnaftaVarColors.textPrimary,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
            ),
          ),
          const SizedBox(height: EsnaftaVarSpacing.xs),
          Text(
            TTexts.loginSubTitle,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: EsnaftaVarColors.textSecondary,
              height: 1.45,
            ),
          ),
        ],
      );
    }

    final dark = THelperFunctions.isDarkMode(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Image(
          height: 150,
          image: AssetImage(dark ? TImages.lightAppLogo : TImages.darkAppLogo),
        ),
        Text('Esnaf Girişi', style: Theme.of(context).textTheme.headlineMedium),
        const SizedBox(height: TSizes.sm),
        Text(
          'Esnaf hesabınızla mağazanızı yönetin.',
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      ],
    );
  }
}
