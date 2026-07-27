import 'package:flutter/material.dart';

class AppColors {
  // Primary Emerald Spectrum
  static const Color primary = Color(0xFF10B981); // Emerald 500
  static const Color primaryDark = Color(0xFF059669); // Emerald 600
  static const Color primaryLight = Color(0xFFD1FAE5); // Emerald 100
  static const Color primaryGlow = Color(0x3310B981); // Soft 20% glow

  // Secondary & Dark Spectrum (Tesla / Apple Charcoal)
  static const Color secondary = Color(0xFF0F172A); // Slate 900
  static const Color secondaryLight = Color(0xFF1E293B); // Slate 800
  static const Color secondaryMuted = Color(0xFF64748B); // Slate 500

  // Accent Spectrum
  static const Color accent = Color(0xFFF59E0B); // Amber 500
  static const Color accentGlow = Color(0x33F59E0B);

  // Surface & Background (Light Mode - Linear / Apple Inspired)
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Colors.white;
  static const Color surfaceSubtle = Color(0xFFF1F5F9); // Slate 100
  static const Color glassSurface = Color(0xCCFFFFFF); // Glassmorphism white (80%)
  static const Color glassBorder = Color(0x40FFFFFF);

  // Status & Feedback Colors
  static const Color error = Color(0xFFEF4444); // Red 500
  static const Color success = Color(0xFF10B981); // Emerald 500
  static const Color warning = Color(0xFFF59E0B); // Amber 500
  static const Color info = Color(0xFF3B82F6); // Blue 500

  // Text Hierarchy
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF64748B); // Slate 500
  static const Color textMuted = Color(0xFF94A3B8); // Slate 400
  static const Color textOnPrimary = Colors.white;

  // Modern Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF10B981), Color(0xFF059669)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient heroGradient = LinearGradient(
    colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient glassGradient = LinearGradient(
    colors: [Color(0xB3FFFFFF), Color(0x80FFFFFF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
