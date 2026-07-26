import 'package:flutter/material.dart';

/// Approved V1 visual tokens scoped to the customer home experience.
///
/// These values intentionally do not alter the application's global theme.
abstract final class CustomerHomeV1Tokens {
  static const petrol = Color(0xFF146C6E);
  static const coral = Color(0xFFF06449);
  static const yellow = Color(0xFFF5C451);
  static const cream = Color(0xFFFFF8EE);
  static const mint = Color(0xFFDCEDEA);
  static const navy = Color(0xFF17233B);
  static const green = Color(0xFF28966F);
  static const surface = Color(0xFFFFFCF7);
  static const border = Color(0xFFE9E5DE);
  static const muted = Color(0xFF747B87);

  static const space4 = 4.0;
  static const space8 = 8.0;
  static const space12 = 12.0;
  static const space16 = 16.0;
  static const space20 = 20.0;
  static const space24 = 24.0;
  static const space32 = 32.0;

  static const radius12 = 12.0;
  static const radius16 = 16.0;
  static const radius20 = 20.0;
  static const radius24 = 24.0;
  static const radiusPill = 999.0;

  static List<BoxShadow> get softShadow => [
    BoxShadow(
      color: navy.withValues(alpha: 0.07),
      blurRadius: 18,
      offset: const Offset(0, 6),
    ),
  ];
}
