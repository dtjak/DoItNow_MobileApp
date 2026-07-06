import 'package:flutter/material.dart';
import 'theme_controller.dart';

/// App palette. Every member is resolved at read-time against
/// [ThemeController.instance.isDark], so simply toggling the controller and
/// rebuilding the tree repaints the whole app in the other mode.
///
/// Because these are getters (not `const`), they cannot be used inside `const`
/// widget constructors — always use non-const widgets where an AppColors value
/// is passed.
class AppColors {
  static bool get _d => ThemeController.instance.isDark;
  static Color _p(Color light, Color dark) => _d ? dark : light;

  // Primary
  static Color get primary => _p(const Color(0xFF004AC6), const Color(0xFFADC6FF));
  static Color get onPrimary => _p(const Color(0xFFFFFFFF), const Color(0xFF002E69));
  static Color get primaryContainer => _p(const Color(0xFF2563EB), const Color(0xFF244999));
  static Color get onPrimaryContainer => _p(const Color(0xFFEEEFFF), const Color(0xFFDBE1FF));
  // "Fixed" accent tones (chip backgrounds with dark text) stay the same in both modes.
  static const Color primaryFixed = Color(0xFFDBE1FF);
  static const Color primaryFixedDim = Color(0xFFB4C5FF);
  static const Color onPrimaryFixed = Color(0xFF00174B);
  static const Color onPrimaryFixedVariant = Color(0xFF003EA8);

  // Secondary
  static Color get secondary => _p(const Color(0xFF4B41E1), const Color(0xFFC3C0FF));
  static Color get onSecondary => _p(const Color(0xFFFFFFFF), const Color(0xFF1C1099));
  static Color get secondaryContainer => _p(const Color(0xFF645EFB), const Color(0xFF3323CC));
  static Color get onSecondaryContainer => _p(const Color(0xFFFFFBFF), const Color(0xFFE2DFFF));
  static const Color secondaryFixed = Color(0xFFE2DFFF);
  static const Color secondaryFixedDim = Color(0xFFC3C0FF);
  static const Color onSecondaryFixed = Color(0xFF0F0069);
  static const Color onSecondaryFixedVariant = Color(0xFF3323CC);

  // Tertiary
  static Color get tertiary => _p(const Color(0xFF006242), const Color(0xFF4EDEA3));
  static Color get onTertiary => _p(const Color(0xFFFFFFFF), const Color(0xFF00391F));
  static Color get tertiaryContainer => _p(const Color(0xFF007D55), const Color(0xFF005236));
  static Color get onTertiaryContainer => _p(const Color(0xFFBDFFDB), const Color(0xFFBDFFDB));
  static const Color tertiaryFixed = Color(0xFF6FFBBE);
  static const Color tertiaryFixedDim = Color(0xFF4EDEA3);
  static const Color onTertiaryFixed = Color(0xFF002113);
  static const Color onTertiaryFixedVariant = Color(0xFF005236);

  // Surface
  static Color get surface => _p(const Color(0xFFF8F9FA), const Color(0xFF121417));
  static Color get surfaceBright => _p(const Color(0xFFF8F9FA), const Color(0xFF383A3D));
  static Color get surfaceDim => _p(const Color(0xFFD9DADB), const Color(0xFF121417));
  static Color get surfaceVariant => _p(const Color(0xFFE1E3E4), const Color(0xFF2A2D31));
  static Color get surfaceTint => _p(const Color(0xFF0053DB), const Color(0xFFADC6FF));
  static Color get surfaceContainerLowest => _p(const Color(0xFFFFFFFF), const Color(0xFF1A1C1F));
  static Color get surfaceContainerLow => _p(const Color(0xFFF3F4F5), const Color(0xFF1E2023));
  static Color get surfaceContainer => _p(const Color(0xFFEDEEEF), const Color(0xFF212428));
  static Color get surfaceContainerHigh => _p(const Color(0xFFE7E8E9), const Color(0xFF2A2D31));
  static Color get surfaceContainerHighest => _p(const Color(0xFFE1E3E4), const Color(0xFF33363A));

  // Background
  static Color get background => _p(const Color(0xFFF8F9FA), const Color(0xFF121417));
  static Color get onBackground => _p(const Color(0xFF191C1D), const Color(0xFFE3E4E6));

  // On Surface
  static Color get onSurface => _p(const Color(0xFF191C1D), const Color(0xFFE3E4E6));
  static Color get onSurfaceVariant => _p(const Color(0xFF434655), const Color(0xFFC3C6CF));
  static Color get inverseSurface => _p(const Color(0xFF2E3132), const Color(0xFFE3E4E6));
  static Color get inverseOnSurface => _p(const Color(0xFFF0F1F2), const Color(0xFF2E3132));
  static Color get inversePrimary => _p(const Color(0xFFB4C5FF), const Color(0xFF004AC6));

  // Outline
  static Color get outline => _p(const Color(0xFF737686), const Color(0xFF8C8F99));
  static Color get outlineVariant => _p(const Color(0xFFC3C6D7), const Color(0xFF44474F));

  // Error
  static Color get error => _p(const Color(0xFFBA1A1A), const Color(0xFFFFB4AB));
  static Color get onError => _p(const Color(0xFFFFFFFF), const Color(0xFF690005));
  static Color get errorContainer => _p(const Color(0xFFFFDAD6), const Color(0xFF93000A));
  static Color get onErrorContainer => _p(const Color(0xFF93000A), const Color(0xFFFFDAD6));
}

class AppTextStyles {
  static const String fontFamily = 'Inter';

  static const TextStyle displayLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 32,
    height: 1.25,
    letterSpacing: -0.64,
    fontWeight: FontWeight.w700,
  );

  static const TextStyle headlineMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 24,
    height: 1.33,
    letterSpacing: -0.24,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headlineMdMobile = TextStyle(
    fontFamily: fontFamily,
    fontSize: 22,
    height: 1.27,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle headlineSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 20,
    height: 1.4,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle titleLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 18,
    height: 1.33,
    fontWeight: FontWeight.w600,
  );

  static const TextStyle bodyLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle bodyMd = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.43,
    fontWeight: FontWeight.w400,
  );

  static const TextStyle labelLg = TextStyle(
    fontFamily: fontFamily,
    fontSize: 14,
    height: 1.43,
    letterSpacing: 0.14,
    fontWeight: FontWeight.w500,
  );

  static const TextStyle labelSm = TextStyle(
    fontFamily: fontFamily,
    fontSize: 12,
    height: 1.33,
    letterSpacing: 0.24,
    fontWeight: FontWeight.w500,
  );
}

class AppTheme {
  /// Resolves against the current [ThemeController] mode. Rebuild the
  /// MaterialApp when the controller changes to pick up the new theme.
  static ThemeData get theme {
    final brightness =
        ThemeController.instance.isDark ? Brightness.dark : Brightness.light;
    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      fontFamily: AppTextStyles.fontFamily,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: AppColors.primary,
        onPrimary: AppColors.onPrimary,
        primaryContainer: AppColors.primaryContainer,
        onPrimaryContainer: AppColors.onPrimaryContainer,
        secondary: AppColors.secondary,
        onSecondary: AppColors.onSecondary,
        secondaryContainer: AppColors.secondaryContainer,
        onSecondaryContainer: AppColors.onSecondaryContainer,
        tertiary: AppColors.tertiary,
        onTertiary: AppColors.onTertiary,
        tertiaryContainer: AppColors.tertiaryContainer,
        onTertiaryContainer: AppColors.onTertiaryContainer,
        error: AppColors.error,
        onError: AppColors.onError,
        errorContainer: AppColors.errorContainer,
        onErrorContainer: AppColors.onErrorContainer,
        surface: AppColors.surface,
        onSurface: AppColors.onSurface,
        onSurfaceVariant: AppColors.onSurfaceVariant,
        outline: AppColors.outline,
        outlineVariant: AppColors.outlineVariant,
        inverseSurface: AppColors.inverseSurface,
        onInverseSurface: AppColors.inverseOnSurface,
        inversePrimary: AppColors.inversePrimary,
      ),
      scaffoldBackgroundColor: AppColors.background,
    );
  }

  /// Backwards-compatible alias.
  static ThemeData get lightTheme => theme;
}
