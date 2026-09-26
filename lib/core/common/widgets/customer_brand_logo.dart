import 'package:flutter/material.dart';

/// The Product Owner supplied artwork, including its transparent margins.
class CustomerBrandLogo extends StatelessWidget {
  const CustomerBrandLogo({super.key});

  static const assetPath = 'assets/logos/esnaftavar-logo.png';

  @override
  Widget build(BuildContext context) {
    return Semantics(
      container: true,
      image: true,
      label: 'EsnaftaVar',
      child: SizedBox(
        width: 168,
        child: AspectRatio(
          aspectRatio: 3,
          child: Image.asset(
            assetPath,
            fit: BoxFit.contain,
            excludeFromSemantics: true,
          ),
        ),
      ),
    );
  }
}
