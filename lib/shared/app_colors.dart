import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors
  static const Color primary = Color(0xFF1E88E5);
  static const Color primaryDark = Color(0xFF1565C0);
  static const Color primaryLight = Color(0xFFBBDEFB);
  
  static const Color secondary = Color(0xFFFF9800);
  static const Color secondaryDark = Color(0xFFF57C00);
  static const Color secondaryLight = Color(0xFFFFE0B2);

  static const Color tertiary = Color(0xFF00ACC1);

  // Status Colors
  static const Color success = Color(0xFF34A853);
  static const Color warning = Color(0xFFFBBC05);
  static const Color error = Color(0xFFEA4335);
  static const Color info = Color(0xFF4285F4);
  
  // Neutral Colors
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF202124);
  static const Color textSecondary = Color(0xFF5F6368);
  static const Color outline = Color(0xFFDADCE0);

  // Opacity variations
  static Color successLight = success.withAlpha((0.1 * 255).toInt());
  static Color warningLight = warning.withAlpha((0.1 * 255).toInt());
  static Color errorLight = error.withAlpha((0.1 * 255).toInt());
  static Color infoLight = info.withAlpha((0.1 * 255).toInt());
  static Color primaryLightAlpha = primary.withAlpha((0.1 * 255).toInt());
}
