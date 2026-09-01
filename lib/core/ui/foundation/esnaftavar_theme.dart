import 'package:flutter/material.dart';
import 'package:t_store/core/ui/foundation/esnaftavar_design_tokens.dart';

abstract final class EsnaftaVarTheme {
  static ThemeData get light {
    final colorScheme = ColorScheme.fromSeed(
      seedColor: EsnaftaVarColors.primary,
      brightness: Brightness.light,
      primary: EsnaftaVarColors.primary,
      onPrimary: EsnaftaVarColors.textOnPrimary,
      secondary: EsnaftaVarColors.accent,
      onSecondary: EsnaftaVarColors.textOnPrimary,
      surface: EsnaftaVarColors.surface,
      onSurface: EsnaftaVarColors.textPrimary,
      error: EsnaftaVarColors.error,
      onError: EsnaftaVarColors.textOnPrimary,
    );

    final textTheme =
        const TextTheme(
          headlineLarge: TextStyle(
            fontSize: 30,
            height: 1.15,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
          ),
          headlineMedium: TextStyle(
            fontSize: 24,
            height: 1.2,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
          headlineSmall: TextStyle(
            fontSize: 20,
            height: 1.25,
            fontWeight: FontWeight.w600,
            letterSpacing: -0.25,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            height: 1.3,
            fontWeight: FontWeight.w600,
          ),
          titleMedium: TextStyle(
            fontSize: 16,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
          titleSmall: TextStyle(
            fontSize: 14,
            height: 1.35,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: TextStyle(
            fontSize: 16,
            height: 1.5,
            fontWeight: FontWeight.w400,
          ),
          bodyMedium: TextStyle(
            fontSize: 14,
            height: 1.45,
            fontWeight: FontWeight.w400,
          ),
          bodySmall: TextStyle(
            fontSize: 12,
            height: 1.4,
            fontWeight: FontWeight.w400,
          ),
          labelLarge: TextStyle(
            fontSize: 14,
            height: 1.25,
            fontWeight: FontWeight.w600,
          ),
          labelMedium: TextStyle(
            fontSize: 12,
            height: 1.25,
            fontWeight: FontWeight.w600,
          ),
          labelSmall: TextStyle(
            fontSize: 11,
            height: 1.25,
            fontWeight: FontWeight.w500,
          ),
        ).apply(
          fontFamily: 'Poppins',
          bodyColor: EsnaftaVarColors.textPrimary,
          displayColor: EsnaftaVarColors.textPrimary,
        );

    final roundedMedium = RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      fontFamily: 'Poppins',
      colorScheme: colorScheme,
      scaffoldBackgroundColor: EsnaftaVarColors.background,
      disabledColor: EsnaftaVarColors.textMuted.withValues(alpha: 0.45),
      textTheme: textTheme,
      dividerColor: EsnaftaVarColors.divider,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        scrolledUnderElevation: 0,
        backgroundColor: EsnaftaVarColors.background,
        foregroundColor: EsnaftaVarColors.textPrimary,
        surfaceTintColor: Colors.transparent,
      ),
      cardTheme: CardThemeData(
        elevation: 0,
        margin: EdgeInsets.zero,
        color: EsnaftaVarColors.surface,
        surfaceTintColor: Colors.transparent,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(EsnaftaVarRadii.large),
          side: const BorderSide(color: EsnaftaVarColors.borderDefault),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          minimumSize: const Size(
            EsnaftaVarTouchTargets.minimum,
            EsnaftaVarTouchTargets.preferred,
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: EsnaftaVarSpacing.lg,
            vertical: EsnaftaVarSpacing.sm,
          ),
          backgroundColor: EsnaftaVarColors.primary,
          foregroundColor: EsnaftaVarColors.textOnPrimary,
          disabledBackgroundColor: EsnaftaVarColors.surfaceAlt,
          disabledForegroundColor: EsnaftaVarColors.textMuted,
          shape: roundedMedium,
          textStyle: textTheme.labelLarge,
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          minimumSize: const Size(
            EsnaftaVarTouchTargets.minimum,
            EsnaftaVarTouchTargets.preferred,
          ),
          elevation: 0,
          backgroundColor: EsnaftaVarColors.primary,
          foregroundColor: EsnaftaVarColors.textOnPrimary,
          shape: roundedMedium,
          textStyle: textTheme.labelLarge,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          minimumSize: const Size(
            EsnaftaVarTouchTargets.minimum,
            EsnaftaVarTouchTargets.preferred,
          ),
          foregroundColor: EsnaftaVarColors.primary,
          side: const BorderSide(color: EsnaftaVarColors.primary),
          shape: roundedMedium,
          textStyle: textTheme.labelLarge,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          minimumSize: const Size(
            EsnaftaVarTouchTargets.minimum,
            EsnaftaVarTouchTargets.minimum,
          ),
          foregroundColor: EsnaftaVarColors.primary,
          padding: const EdgeInsets.symmetric(horizontal: EsnaftaVarSpacing.sm),
          textStyle: textTheme.labelMedium,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          minimumSize: const Size.square(EsnaftaVarTouchTargets.minimum),
          foregroundColor: EsnaftaVarColors.primary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: EsnaftaVarColors.surface,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: EsnaftaVarSpacing.md,
          vertical: EsnaftaVarSpacing.sm,
        ),
        constraints: const BoxConstraints(
          minHeight: EsnaftaVarTouchTargets.preferred,
        ),
        hintStyle: textTheme.bodyMedium?.copyWith(
          color: EsnaftaVarColors.textMuted,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
          borderSide: const BorderSide(color: EsnaftaVarColors.borderDefault),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
          borderSide: const BorderSide(
            color: EsnaftaVarColors.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(EsnaftaVarRadii.medium),
          borderSide: const BorderSide(color: EsnaftaVarColors.error),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        height: 72,
        backgroundColor: EsnaftaVarColors.surface,
        indicatorColor: EsnaftaVarColors.primarySoft,
        labelTextStyle: WidgetStateProperty.resolveWith((states) {
          return textTheme.labelSmall?.copyWith(
            color: states.contains(WidgetState.selected)
                ? EsnaftaVarColors.primary
                : EsnaftaVarColors.textMuted,
          );
        }),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: EsnaftaVarColors.surfaceAlt,
        selectedColor: EsnaftaVarColors.primarySoft,
        disabledColor: EsnaftaVarColors.surfaceAlt,
        side: const BorderSide(color: EsnaftaVarColors.borderDefault),
        labelStyle: textTheme.labelMedium,
        shape: const StadiumBorder(),
      ),
    );
  }
}
