import 'package:flutter/material.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';

/// Backward-compatible facade for the W14 customer Home token API.
///
/// New code should use the semantic W39A token classes under `core/ui`.
abstract final class CustomerHomeV1Tokens {
  static const petrol = EsnaftaVarColors.primary;
  static const coral = EsnaftaVarColors.accent;
  static const yellow = EsnaftaVarColors.highlight;
  static const cream = EsnaftaVarColors.background;
  static const mint = EsnaftaVarColors.primarySoft;
  static const navy = EsnaftaVarColors.textPrimary;
  static const green = EsnaftaVarColors.success;
  static const surface = EsnaftaVarColors.surfaceElevated;
  static const border = EsnaftaVarColors.borderDefault;
  static const muted = EsnaftaVarColors.textMuted;
  static const onPrimary = EsnaftaVarColors.textOnPrimary;

  static const categorySurfaces = EsnaftaVarDiscoveryColors.categorySurfaces;
  static const merchantFallbacks = EsnaftaVarDiscoveryColors.merchantFallbacks;
  static const campaignOverlay = EsnaftaVarDiscoveryColors.campaignOverlay;
  static const campaignSupportingText =
      EsnaftaVarDiscoveryColors.campaignSupportingText;

  static const space4 = EsnaftaVarSpacing.xxs;
  static const space8 = EsnaftaVarSpacing.xs;
  static const space12 = EsnaftaVarSpacing.sm;
  static const space16 = EsnaftaVarSpacing.md;
  static const space20 = EsnaftaVarSpacing.lg;
  static const space24 = EsnaftaVarSpacing.xl;
  static const space32 = EsnaftaVarSpacing.xxl;

  static const radius12 = EsnaftaVarRadii.medium;
  static const radius16 = EsnaftaVarRadii.large;
  static const radius20 = EsnaftaVarRadii.xLarge;
  static const radius24 = EsnaftaVarRadii.xxLarge;
  static const radiusPill = EsnaftaVarRadii.pill;

  static List<BoxShadow> get softShadow => EsnaftaVarElevation.sm;
}
