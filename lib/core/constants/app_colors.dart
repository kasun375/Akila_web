import 'package:flutter/material.dart';

class AppColors {
  // Primary Palette - Rich Forest & Emerald Green
  static const Color primary = Color(0xFF047857); // Rich Emerald Green
  static const Color primaryDark = Color(0xFF064E3B); // Deep Forest Green
  static const Color primaryLight = Color(0xFF10B981); // Vibrant Emerald Accent
  
  // Secondary & Accents
  static const Color accent = Color(0xFF059669); // Lush Green Accent
  static const Color secondary = Color(0xFF0D9488); // Teal / Sage Accent
  static const Color success = Color(0xFF10B981); // Emerald Green (Paid status)
  static const Color warning = Color(0xFFF59E0B); // Amber (Pending status)
  static const Color error = Color(0xFFEF4444); // Crimson Red
  
  // Mint & Soft Green Accents
  static const Color mintSoft = Color(0xFFECFDF5); // Ultra-light Mint Pastel
  static const Color mintBorder = Color(0xFFA7F3D0); // Soft Mint Border
  static const Color mintPill = Color(0xFFC7F9CC); // Light Pastel Green Pill / Button
  
  // Backgrounds & Surface
  static const Color bgLight = Color(0xFFF8FAFC); // Crisp Light Canvas
  static const Color bgCard = Colors.white; // Pure White Card Surface
  static const Color bgDark = Color(0xFF064E3B); // Deep Forest Green Surface
  static const Color cardDark = Color(0xFF065F46); // Rich Emerald Dark Card
  
  // Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // High Contrast Charcoal Slate
  static const Color textSecondary = Color(0xFF475569); // Refined Slate Grey
  static const Color textLight = Color(0xFF94A3B8); // Muted Light Slate
  static const Color textOnPrimary = Colors.white; // Pure White on Green

  // Gradients
  static const Gradient primaryGradient = LinearGradient(
    colors: [Color(0xFF064E3B), Color(0xFF047857)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient heroGradient = LinearGradient(
    colors: [Color(0xFF064E3B), Color(0xFF047857), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const Gradient accentGradient = LinearGradient(
    colors: [Color(0xFF047857), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
