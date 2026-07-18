import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors - Royal Purple & Slate (Sophisticated & Modern)
  static const Color primary = Color(0xFF312E81); // Deep Royal Indigo/Purple
  static const Color primaryDark = Color(0xFF1E1B4B);
  static const Color primaryLight = Color(0xFF4338CA);
  
  static const Color secondary = Color(0xFF64748B); // Professional Slate
  static const Color secondaryDark = Color(0xFF334155);
  static const Color secondaryLight = Color(0xFF94A3B8);

  static const Color tertiary = Color(0xFF8B5CF6); // Modern Violet Accent

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
