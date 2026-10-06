import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette - Deep Royal Indigo & Mathematics Accent Blue
  static const Color primary = Color(0xFF1E3A8A); // Royal Indigo Blue
  static const Color primaryDark = Color(0xFF0F172A); // Midnight Navy
  static const Color primaryLight = Color(0xFF3B82F6); // Electric Blue Accent
  
  // Secondary & Accents
  static const Color accent = Color(0xFF0EA5E9); // Bright Cyan
  static const Color secondary = Color(0xFF6366F1); // Iris Violet
  static const Color success = Color(0xFF10B981); // Emerald Green (Paid status)
  static const Color warning = Color(0xFFF59E0B); // Amber (Pending status)
  static const Color error = Color(0xFFEF4444); // Crimson Red
  
  // Backgrounds & Surface
  static const Color bgLight = Color(0xFFF8FAFC);
  static const Color bgCard = Colors.white;
  static const Color bgDark = Color(0xFF0F172A);
  static const Color cardDark = Color(0xFF1E293B);
  
  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A);
  static const Color textSecondary = Color(0xFF64748B);
  static const Color textLight = Color(0xFF94A3B8);
  static const Color textOnPrimary = Colors.white;

  // Glassmorphism & Gradients
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF1E3A8A), Color(0xFF2563EB)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient heroGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E3A8A), Color(0xFF3B82F6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient accentGradient = LinearGradient(
    colors: [Color(0xFF0EA5E9), Color(0xFF6366F1)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
