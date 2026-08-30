import 'package:flutter/material.dart';

/// EsnaftaVar customer experience design tokens.
///
/// W39A intentionally ships a light-only visual foundation. Dark-mode values
/// are not inferred here; they will be introduced with an explicit product
/// decision in a later rollout wave.
abstract final class EsnaftaVarColors {
  static const primary = Color(0xFF146C6E);
  static const primaryPressed = Color(0xFF0D5557);
  static const primarySoft = Color(0xFFDCEDEA);

  static const accent = Color(0xFFB54732);
  static const accentPressed = Color(0xFF923724);
  static const accentSoft = Color(0xFFFBE8E2);
  static const highlight = Color(0xFFF5C451);

  static const background = Color(0xFFFFF8EE);
  static const surface = Color(0xFFFFFFFF);
  static const surfaceAlt = Color(0xFFF3EEE6);
  static const surfaceElevated = Color(0xFFFFFCF7);

  static const textPrimary = Color(0xFF17233B);
  static const textSecondary = Color(0xFF596274);
  static const textMuted = Color(0xFF667085);
  static const textOnPrimary = Color(0xFFFFFFFF);

  static const borderDefault = Color(0xFFDED9D1);
  static const borderStrong = Color(0xFFB8B1A7);
  static const divider = Color(0xFFE9E3DA);

  static const success = Color(0xFF247A55);
  static const successSoft = Color(0xFFDFF2E8);
  static const warning = Color(0xFF936018);
  static const warningSoft = Color(0xFFFFEBC7);
  static const error = Color(0xFFB42318);
  static const errorSoft = Color(0xFFFEE4E2);
  static const info = Color(0xFF175CD3);
  static const infoSoft = Color(0xFFDCE9FF);

  static const price = Color(0xFF17233B);
  static const rewardProgress = accent;
  static const rewardTrack = accentSoft;
}

/// Restrained decorative colors for discovery content and image fallbacks.
/// They are centralized so domain widgets never create a parallel palette.
abstract final class EsnaftaVarDiscoveryColors {
  static const categorySurfaces = <Color>[
    EsnaftaVarColors.primarySoft,
    Color(0xFFE4F0E0),
    Color(0xFFFFEDD3),
    Color(0xFFFFE1DC),
    Color(0xFFF9DFDF),
    Color(0xFFDDEDEA),
  ];

  static const merchantFallbacks = <Color>[
    EsnaftaVarColors.primary,
    Color(0xFF2A7E72),
    Color(0xFF274E67),
    Color(0xFF8B6045),
  ];

  static const campaignOverlay = Color(0xFF0D5C5E);
  static const campaignSupportingText = Color(0xFFF1F7F7);
}

abstract final class EsnaftaVarSpacing {
  static const xxs = 4.0;
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 20.0;
  static const xl = 24.0;
  static const xxl = 32.0;
  static const xxxl = 40.0;
  static const section = 48.0;
}

abstract final class EsnaftaVarRadii {
  static const small = 8.0;
  static const medium = 12.0;
  static const large = 16.0;
  static const xLarge = 20.0;
  static const xxLarge = 24.0;
  static const pill = 999.0;
}

abstract final class EsnaftaVarIconSizes {
  static const small = 16.0;
  static const medium = 20.0;
  static const large = 24.0;
  static const xLarge = 32.0;
}

abstract final class EsnaftaVarTouchTargets {
  static const minimum = 44.0;
  static const preferred = 48.0;
}

abstract final class EsnaftaVarElevation {
  static const xs = <BoxShadow>[
    BoxShadow(color: Color(0x0D17233B), blurRadius: 10, offset: Offset(0, 3)),
  ];

  static const sm = <BoxShadow>[
    BoxShadow(color: Color(0x1217233B), blurRadius: 18, offset: Offset(0, 6)),
  ];

  static const md = <BoxShadow>[
    BoxShadow(color: Color(0x1717233B), blurRadius: 28, offset: Offset(0, 10)),
  ];
}
