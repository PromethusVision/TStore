import 'package:flutter/material.dart';
import 'package:t_store/core/utils/constants/customer_home_v1_tokens.dart';

class CustomerBrandWordmark extends StatelessWidget {
  const CustomerBrandWordmark({
    super.key,
    this.fontSize = 24,
    this.textAlign = TextAlign.start,
  });

  final double fontSize;
  final TextAlign textAlign;

  @override
  Widget build(BuildContext context) {
    return Text.rich(
      TextSpan(
        style: TextStyle(
          fontSize: fontSize,
          height: 1,
          fontWeight: FontWeight.w700,
          letterSpacing: -0.7,
        ),
        children: const [
          TextSpan(
            text: 'Esnafta',
            style: TextStyle(color: CustomerHomeV1Tokens.petrol),
          ),
          TextSpan(
            text: 'Var',
            style: TextStyle(color: CustomerHomeV1Tokens.coral),
          ),
        ],
      ),
      textAlign: textAlign,
    );
  }
}
