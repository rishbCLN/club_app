import 'package:flutter/material.dart';

class NexusColors {
  NexusColors._();

  // ── Backgrounds ────────────────────────────────────────────────────────────
  static const bg               = Color(0xFF070A0F);
  static const surface          = Color(0xFF0D1117);
  static const surfaceElevated  = Color(0xFF131A22);
  static const border           = Color(0xFF1E293B);

  // ── Text ───────────────────────────────────────────────────────────────────
  static const textPrimary   = Color(0xFFF1F5F9);
  static const textSecondary = Color(0xFF94A3B8);
  static const textMuted     = Color(0xFF475569);

  // ── Club accent palette ────────────────────────────────────────────────────
  static const cyan    = Color(0xFF00FFCC);
  static const rose    = Color(0xFFFF6B9D);
  static const violet  = Color(0xFFA78BFA);
  static const amber   = Color(0xFFFBBF24);
  static const emerald = Color(0xFF34D399);
  static const orange  = Color(0xFFF97316);
  static const blue    = Color(0xFF60A5FA);

  // ── Convenience list for iterating over accent colors ─────────────────────
  static const List<Color> accents = [
    cyan, rose, violet, amber, emerald, orange, blue,
  ];

  // ── Shimmer shades ─────────────────────────────────────────────────────────
  static const shimmerBase      = surface;
  static const shimmerHighlight = border;

  // ── Glow helpers ──────────────────────────────────────────────────────────
  static Color glowOf(Color color, {double opacity = 0.35}) =>
      color.withOpacity(opacity);

  static List<BoxShadow> glowShadow(Color color, {
    double blur = 24,
    double spread = 0,
    double opacity = 0.45,
  }) => [
    BoxShadow(
      color: color.withOpacity(opacity),
      blurRadius: blur,
      spreadRadius: spread,
    ),
  ];

  // ── Gradient presets ──────────────────────────────────────────────────────
  static const LinearGradient darkSurface = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [surfaceElevated, surface],
  );

  static LinearGradient clubGradient(Color color) => LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [
      color.withOpacity(0.25),
      color.withOpacity(0.05),
    ],
  );
}
