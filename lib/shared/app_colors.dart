import 'package:flutter/material.dart';

class AppColors {
  // Brand Colors (ERP Blue / Professional)
  static const Color primary = Color(0xFF1A73E8); // Google-like blue
  static const Color primaryDark = Color(0xFF1557B0);
  static const Color accent = Color(0xFF1A73E8);
  
  static const Color secondary = Color(0xFF5F6368); // Medium grey
  static const Color tertiary = Color(0xFFE8EAED); // Light grey

  // Status Colors
  static const Color success = Color(0xFF1E8E3E); // Green
  static const Color warning = Color(0xFFF9AB00); // Amber
  static const Color error = Color(0xFFD93025); // Red
  static const Color info = Color(0xFF1A73E8); // Blue
  
  // Neutral Colors (ERP Surfaces)
  static const Color background = Color(0xFFF8F9FA); // Very light grey surface
  static const Color surface = Colors.white;
  static const Color textPrimary = Color(0xFF202124); // Near black
  static const Color textSecondary = Color(0xFF5F6368); // Grey
  static const Color textTertiary = Color(0xFF9AA0A6); // Light grey
  static const Color outline = Color(0xFFDADCE0); // Border color

  // Opacity variations
  static Color get primary10 => primary.withValues(alpha: 0.1);
  static Color get success10 => success.withValues(alpha: 0.1);
  static Color get warning10 => warning.withValues(alpha: 0.1);
  static Color get error10 => error.withValues(alpha: 0.1);
}
