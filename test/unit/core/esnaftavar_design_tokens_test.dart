import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_theme.dart';

void main() {
  test('primary ve accent beyaz metinle WCAG AA kontrastını geçer', () {
    expect(
      _contrastRatio(EsnaftaVarColors.primary, EsnaftaVarColors.textOnPrimary),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      _contrastRatio(EsnaftaVarColors.accent, EsnaftaVarColors.textOnPrimary),
      greaterThanOrEqualTo(4.5),
    );
  });

  test('ana metin rolleri açık arka planda okunabilir kalır', () {
    for (final color in [
      EsnaftaVarColors.textPrimary,
      EsnaftaVarColors.textSecondary,
      EsnaftaVarColors.textMuted,
    ]) {
      expect(
        _contrastRatio(color, EsnaftaVarColors.background),
        greaterThanOrEqualTo(4.5),
      );
    }
  });

  test('touch target ve Poppins light theme sözleşmesini korur', () {
    expect(EsnaftaVarTouchTargets.minimum, greaterThanOrEqualTo(44));
    expect(EsnaftaVarTouchTargets.preferred, greaterThanOrEqualTo(48));
    expect(EsnaftaVarTheme.light.textTheme.bodyMedium?.fontFamily, 'Poppins');
    expect(EsnaftaVarTheme.light.brightness, Brightness.light);
  });
}

double _contrastRatio(Color foreground, Color background) {
  final foregroundLuminance = foreground.computeLuminance();
  final backgroundLuminance = background.computeLuminance();
  final lighter = foregroundLuminance > backgroundLuminance
      ? foregroundLuminance
      : backgroundLuminance;
  final darker = foregroundLuminance > backgroundLuminance
      ? backgroundLuminance
      : foregroundLuminance;
  return (lighter + 0.05) / (darker + 0.05);
}
