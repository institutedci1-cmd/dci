// ignore_for_file: overridden_fields, annotate_overrides

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:shared_preferences/shared_preferences.dart';

const kThemeModeKey = '__theme_mode__';

SharedPreferences? _prefs;

abstract class FlutterFlowTheme {
  static Future initialize() async =>
      _prefs = await SharedPreferences.getInstance();

  static ThemeMode get themeMode {
    final darkMode = _prefs?.getBool(kThemeModeKey);
    return darkMode == null
        ? ThemeMode.system
        : darkMode
            ? ThemeMode.dark
            : ThemeMode.light;
  }

  static void saveThemeMode(ThemeMode mode) => mode == ThemeMode.system
      ? _prefs?.remove(kThemeModeKey)
      : _prefs?.setBool(kThemeModeKey, mode == ThemeMode.dark);

  static FlutterFlowTheme of(BuildContext context) {
    return Theme.of(context).brightness == Brightness.dark
        ? DarkModeTheme()
        : LightModeTheme();
  }

  late Color primary;
  late Color secondary;
  late Color tertiary;
  late Color alternate;
  late Color primaryText;
  late Color secondaryText;
  late Color primaryBackground;
  late Color secondaryBackground;
  late Color accent1;
  late Color accent2;
  late Color accent3;
  late Color accent4;
  late Color success;
  late Color warning;
  late Color error;
  late Color info;

  late Color primaryDark;
  late Color primaryLight;

  late Color onPrimary;
  late Color primaryContainer;
  late Color onPrimaryContainer;
  late Color onSecondary;
  late Color secondaryContainer;
  late Color onSecondaryContainer;
  late Color onAccent;
  late Color accentContainer;
  late Color onAccentContainer;
  late Color onBackground;
  late Color onSurface;
  late Color surfaceVariant;
  late Color onSurfaceVariant;
  late Color onSuccess;
  late Color onWarning;
  late Color onError;
  late Color onInfo;
  late Color transparent;
  late Color fullContrast;
  late Color onBackground80;
  late Color onPrimary15;
  late Color primary10;
  late Color onPrimary20;
  late Color onPrimary80;
  late Color error10;
  late Color onSurface80;
  late Color onPrimary70;
  late Color onBackground90;

  late Color successSubtle;
  late Color warningSubtle;
  late Color errorSubtle;
  late Color infoSubtle;

  FFDesignTokens get designToken => FFDesignTokens(this);

  String get displayLargeFamily => typography.displayLargeFamily;
  TextStyle get displayLarge => typography.displayLarge;
  String get displayMediumFamily => typography.displayMediumFamily;
  TextStyle get displayMedium => typography.displayMedium;
  String get displaySmallFamily => typography.displaySmallFamily;
  TextStyle get displaySmall => typography.displaySmall;
  String get headlineLargeFamily => typography.headlineLargeFamily;
  TextStyle get headlineLarge => typography.headlineLarge;
  String get headlineMediumFamily => typography.headlineMediumFamily;
  TextStyle get headlineMedium => typography.headlineMedium;
  String get headlineSmallFamily => typography.headlineSmallFamily;
  TextStyle get headlineSmall => typography.headlineSmall;
  String get titleLargeFamily => typography.titleLargeFamily;
  TextStyle get titleLarge => typography.titleLarge;
  String get titleMediumFamily => typography.titleMediumFamily;
  TextStyle get titleMedium => typography.titleMedium;
  String get titleSmallFamily => typography.titleSmallFamily;
  TextStyle get titleSmall => typography.titleSmall;
  String get labelLargeFamily => typography.labelLargeFamily;
  TextStyle get labelLarge => typography.labelLarge;
  String get labelMediumFamily => typography.labelMediumFamily;
  TextStyle get labelMedium => typography.labelMedium;
  String get labelSmallFamily => typography.labelSmallFamily;
  TextStyle get labelSmall => typography.labelSmall;
  String get bodyLargeFamily => typography.bodyLargeFamily;
  TextStyle get bodyLarge => typography.bodyLarge;
  String get bodyMediumFamily => typography.bodyMediumFamily;
  TextStyle get bodyMedium => typography.bodyMedium;
  String get bodySmallFamily => typography.bodySmallFamily;
  TextStyle get bodySmall => typography.bodySmall;

  Typography get typography => ThemeTypography(this);
}

class LightModeTheme extends FlutterFlowTheme {
  late Color primary = const Color(0xFF1565C0); // Royal Blue 800
  late Color secondary = const Color(0xFFFB8C00); // Orange 600
  late Color tertiary = const Color(0xFF1A237E); // Indigo 900
  late Color alternate = const Color(0xFFE0E0E0); // Grey 300
  late Color primaryText = const Color(0xFF212121); // Dark Grey
  late Color secondaryText = const Color(0xFF757575); // Grey 600
  late Color primaryBackground = const Color(0xFFF5F7FA); // Soft Grey-Blue
  late Color secondaryBackground = const Color(0xFFFFFFFF); // White
  late Color accent1 = const Color(0x1A1565C0);
  late Color accent2 = const Color(0x1AFB8C00);
  late Color accent3 = const Color(0x1A1A237E);
  late Color accent4 = const Color(0xCCFFFFFF);
  late Color success = const Color(0xFF2E7D32);
  late Color warning = const Color(0xFFFB8C00);
  late Color error = const Color(0xFFC62828);
  late Color info = const Color(0xFF0277BD);

  late Color primaryDark = const Color(0xFF0D47A1);
  late Color primaryLight = const Color(0xFF1E88E5);

  late Color onPrimary = const Color(0xFFFFFFFF);
  late Color primaryContainer = const Color(0xFFD1FAE5);
  late Color onPrimaryContainer = const Color(0xFF065F46);
  late Color onSecondary = const Color(0xFFFFFFFF);
  late Color secondaryContainer = const Color(0xFFF1F5F9);
  late Color onSecondaryContainer = const Color(0xFF1E293B);
  late Color onAccent = const Color(0xFFFFFFFF);
  late Color accentContainer = const Color(0xFFF0FDF4);
  late Color onAccentContainer = const Color(0xFF0F172A);
  late Color onBackground = const Color(0xFF0F172A);
  late Color onSurface = const Color(0xFF0F172A);
  late Color surfaceVariant = const Color(0xFFF1F5F9);
  late Color onSurfaceVariant = const Color(0xFF64748B);
  late Color onSuccess = const Color(0xFFFFFFFF);
  late Color onWarning = const Color(0xFFFFFFFF);
  late Color onError = const Color(0xFFFFFFFF);
  late Color onInfo = const Color(0xFFFFFFFF);
  late Color transparent = const Color(0x00000000);
  late Color fullContrast = const Color(0xFF000000);
  late Color onBackground80 = const Color(0xCC0F172A);
  late Color onPrimary15 = const Color(0x26FFFFFF);
  late Color primary10 = const Color(0x1A10B981);
  late Color onPrimary20 = const Color(0x33FFFFFF);
  late Color onPrimary80 = const Color(0xCCFFFFFF);
  late Color error10 = const Color(0x1AEF4444);
  late Color onSurface80 = const Color(0xCC0F172A);
  late Color onPrimary70 = const Color(0xB3FFFFFF);
  late Color onBackground90 = const Color(0xE60F172A);

  late Color successSubtle = const Color(0xFFE8F5E9);
  late Color warningSubtle = const Color(0xFFFFF3E0);
  late Color errorSubtle = const Color(0xFFFFEBEE);
  late Color infoSubtle = const Color(0xFFE1F5FE);
}

abstract class Typography {
  String get displayLargeFamily;
  TextStyle get displayLarge;
  String get displayMediumFamily;
  TextStyle get displayMedium;
  String get displaySmallFamily;
  TextStyle get displaySmall;
  String get headlineLargeFamily;
  TextStyle get headlineLarge;
  String get headlineMediumFamily;
  TextStyle get headlineMedium;
  String get headlineSmallFamily;
  TextStyle get headlineSmall;
  String get titleLargeFamily;
  TextStyle get titleLarge;
  String get titleMediumFamily;
  TextStyle get titleMedium;
  String get titleSmallFamily;
  TextStyle get titleSmall;
  String get labelLargeFamily;
  TextStyle get labelLarge;
  String get labelMediumFamily;
  TextStyle get labelMedium;
  String get labelSmallFamily;
  TextStyle get labelSmall;
  String get bodyLargeFamily;
  TextStyle get bodyLarge;
  String get bodyMediumFamily;
  TextStyle get bodyMedium;
  String get bodySmallFamily;
  TextStyle get bodySmall;
}

class ThemeTypography extends Typography {
  ThemeTypography(this.theme);

  final FlutterFlowTheme theme;

  String get displayLargeFamily => 'Plus Jakarta Sans';
  TextStyle get displayLarge => GoogleFonts.plusJakartaSans(
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
        fontSize: 57.0,
        height: 1.12,
      );
  String get displayMediumFamily => 'Plus Jakarta Sans';
  TextStyle get displayMedium => GoogleFonts.plusJakartaSans(
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
        fontSize: 45.0,
        height: 1.16,
      );
  String get displaySmallFamily => 'Plus Jakarta Sans';
  TextStyle get displaySmall => GoogleFonts.plusJakartaSans(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 36.0,
        height: 1.22,
      );
  String get headlineLargeFamily => 'Plus Jakarta Sans';
  TextStyle get headlineLarge => GoogleFonts.plusJakartaSans(
        color: theme.primaryText,
        fontWeight: FontWeight.bold,
        fontSize: 32.0,
        height: 1.2,
      );
  String get headlineMediumFamily => 'Plus Jakarta Sans';
  TextStyle get headlineMedium => GoogleFonts.plusJakartaSans(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 28.0,
        height: 1.25,
      );
  String get headlineSmallFamily => 'Plus Jakarta Sans';
  TextStyle get headlineSmall => GoogleFonts.plusJakartaSans(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 24.0,
        height: 1.3,
      );
  String get titleLargeFamily => 'Plus Jakarta Sans';
  TextStyle get titleLarge => GoogleFonts.plusJakartaSans(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 20.0,
        height: 1.27,
      );
  String get titleMediumFamily => 'Plus Jakarta Sans';
  TextStyle get titleMedium => GoogleFonts.plusJakartaSans(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 16.0,
        height: 1.35,
      );
  String get titleSmallFamily => 'Plus Jakarta Sans';
  TextStyle get titleSmall => GoogleFonts.plusJakartaSans(
        color: theme.primaryText,
        fontWeight: FontWeight.w600,
        fontSize: 14.0,
        height: 1.4,
      );
  String get labelLargeFamily => 'Inter';
  TextStyle get labelLarge => GoogleFonts.inter(
        color: theme.secondaryText,
        fontWeight: FontWeight.w600,
        fontSize: 14.0,
        height: 1.33,
      );
  String get labelMediumFamily => 'Inter';
  TextStyle get labelMedium => GoogleFonts.inter(
        color: theme.secondaryText,
        fontWeight: FontWeight.w600,
        fontSize: 13.0,
        height: 1.38,
      );
  String get labelSmallFamily => 'Inter';
  TextStyle get labelSmall => GoogleFonts.inter(
        color: theme.secondaryText,
        fontWeight: FontWeight.w600,
        fontSize: 12.0,
        height: 1.27,
      );
  String get bodyLargeFamily => 'Inter';
  TextStyle get bodyLarge => GoogleFonts.inter(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 16.0,
        height: 1.5,
      );
  String get bodyMediumFamily => 'Inter';
  TextStyle get bodyMedium => GoogleFonts.inter(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 14.0,
        height: 1.47,
      );
  String get bodySmallFamily => 'Inter';
  TextStyle get bodySmall => GoogleFonts.inter(
        color: theme.primaryText,
        fontWeight: FontWeight.normal,
        fontSize: 13.0,
        height: 1.38,
      );
}

class DarkModeTheme extends FlutterFlowTheme {
  late Color primary = const Color(0xFF3B82F6); // Brighter blue for dark mode
  late Color secondary = const Color(0xFFF59E0B); // Amber
  late Color tertiary = const Color(0xFFF1F5F9); 
  late Color alternate = const Color(0xFF334155); // Slate 700 (Border)
  late Color primaryText = const Color(0xFFF8FAFC); // Slate 50
  late Color secondaryText = const Color(0xFF94A3B8); // Slate 400
  late Color primaryBackground = const Color(0xFF0F172A); // Slate 900
  late Color secondaryBackground = const Color(0xFF1E293B); // Slate 800
  late Color accent1 = const Color(0x1A1E88E5);
  late Color accent2 = const Color(0x1AFFA726);
  late Color accent3 = const Color(0x1AF5F7FA);
  late Color accent4 = const Color(0xB20F172A);
  late Color success = const Color(0xFF22C55E); // Green 500
  late Color warning = const Color(0xFFF59E0B); // Amber 500
  late Color error = const Color(0xFFEF4444); // Red 500
  late Color info = const Color(0xFF3B82F6); // Blue 500

  late Color primaryDark = const Color(0xFF1D4ED8);
  late Color primaryLight = const Color(0xFF60A5FA);

  late Color onPrimary = const Color(0xFFFFFFFF);
  late Color primaryContainer = const Color(0xFF1E3A8A);
  late Color onPrimaryContainer = const Color(0xFFDBEAFE);
  late Color onSecondary = const Color(0xFFFFFFFF);
  late Color secondaryContainer = const Color(0xFF334155);
  late Color onSecondaryContainer = const Color(0xFFF1F5F9);
  late Color onAccent = const Color(0xFFFFFFFF);
  late Color accentContainer = const Color(0xFF1E293B);
  late Color onAccentContainer = const Color(0xFFF1F5F9);
  late Color onBackground = const Color(0xFFF8FAFC);
  late Color onSurface = const Color(0xFFF8FAFC);
  late Color surfaceVariant = const Color(0xFF334155);
  late Color onSurfaceVariant = const Color(0xFFCBD5E1);
  late Color onSuccess = const Color(0xFFFFFFFF);
  late Color onWarning = const Color(0xFFFFFFFF);
  late Color onError = const Color(0xFFFFFFFF);
  late Color onInfo = const Color(0xFFFFFFFF);
  late Color transparent = const Color(0x00000000);
  late Color fullContrast = const Color(0xFFFFFFFF);
  late Color onBackground80 = const Color(0xCCF8FAFC);
  late Color onPrimary15 = const Color(0x26FFFFFF);
  late Color primary10 = const Color(0x1A10B981);
  late Color onPrimary20 = const Color(0x33FFFFFF);
  late Color onPrimary80 = const Color(0xCCFFFFFF);
  late Color error10 = const Color(0x1AFE7171);
  late Color onSurface80 = const Color(0xCCF8FAFC);
  late Color onPrimary70 = const Color(0xB3FFFFFF);
  late Color onBackground90 = const Color(0xE6F8FAFC);

  late Color successSubtle = const Color(0x1A22C55E);
  late Color warningSubtle = const Color(0x1AF59E0B);
  late Color errorSubtle = const Color(0x1AEF4444);
  late Color infoSubtle = const Color(0x1A3B82F6);
}

class FFDesignTokens {
  const FFDesignTokens(this.theme);
  final FlutterFlowTheme theme;
  FFSpacing get spacing => const FFSpacing();
  FFRadius get radius => const FFRadius();
  FFShadows get shadow => FFShadows(theme);
}

class FFSpacing {
  const FFSpacing();
  double get none => 0.0;
  double get xs => 4.0;
  double get sm => 8.0;
  double get md => 16.0;
  double get lg => 24.0;
  double get xl => 32.0;
  double get xxl => 48.0;
  double get xxxl => 64.0;
}

class FFRadius {
  const FFRadius();
  double get none => 0.0;
  double get xs => 4.0;
  double get sm => 8.0;
  double get md => 12.0;
  double get lg => 16.0;
  double get xl => 24.0;
  double get xxl => 32.0;
  double get full => 9999.0;
}

class FFShadows {
  const FFShadows(this.theme);
  final FlutterFlowTheme theme;
  BoxShadow get none => const BoxShadow(
      blurRadius: 0.0,
      color: Color(0x00000000),
      offset: Offset(0.0, 0.0),
      spreadRadius: 0.0);
  BoxShadow get xs => const BoxShadow(
      blurRadius: 2.0,
      color: Color(0x0A000000),
      offset: Offset(0.0, 1.0),
      spreadRadius: 0.0);
  BoxShadow get sm => const BoxShadow(
      blurRadius: 4.0,
      color: Color(0x0D000000),
      offset: Offset(0.0, 2.0),
      spreadRadius: 0.0);
  BoxShadow get md => const BoxShadow(
      blurRadius: 8.0,
      color: Color(0x14000000),
      offset: Offset(0.0, 4.0),
      spreadRadius: 0.0);
  BoxShadow get lg => const BoxShadow(
      blurRadius: 12.0,
      color: Color(0x1A000000),
      offset: Offset(0.0, 6.0),
      spreadRadius: 0.0);
  BoxShadow get xl => const BoxShadow(
      blurRadius: 16.0,
      color: Color(0x1F000000),
      offset: Offset(0.0, 8.0),
      spreadRadius: 0.0);
  BoxShadow get xxl => const BoxShadow(
      blurRadius: 24.0,
      color: Color(0x26000000),
      offset: Offset(0.0, 12.0),
      spreadRadius: 0.0);
}

extension TextStyleHelper on TextStyle {
  TextStyle override({
    TextStyle? font,
    String? fontFamily,
    Color? color,
    double? fontSize,
    FontWeight? fontWeight,
    double? letterSpacing,
    FontStyle? fontStyle,
    bool useGoogleFonts = false,
    TextDecoration? decoration,
    double? lineHeight,
    TextOverflow? overflow,
    List<Shadow>? shadows,
    String? package,
  }) {
    if (useGoogleFonts && fontFamily != null) {
      font = GoogleFonts.getFont(fontFamily,
          fontWeight: fontWeight ?? this.fontWeight,
          fontStyle: fontStyle ?? this.fontStyle);
    }

    return font != null
        ? font.copyWith(
            color: color ?? this.color,
            fontSize: fontSize ?? this.fontSize,
            letterSpacing: letterSpacing ?? this.letterSpacing,
            fontWeight: fontWeight ?? this.fontWeight,
            fontStyle: fontStyle ?? this.fontStyle,
            decoration: decoration,
            height: lineHeight,
            overflow: overflow,
            shadows: shadows,
          )
        : copyWith(
            fontFamily: fontFamily,
            package: package,
            color: color,
            fontSize: fontSize,
            letterSpacing: letterSpacing,
            fontWeight: fontWeight,
            fontStyle: fontStyle,
            decoration: decoration,
            height: lineHeight,
            overflow: overflow,
            shadows: shadows,
          );
  }
}
