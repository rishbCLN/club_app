import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'colors.dart';

class NexusText {
  NexusText._();

  // ── Display / Hero text ────────────────────────────────────────────────────
  static TextStyle heroTitle = GoogleFonts.syne(
    fontSize: 48,
    fontWeight: FontWeight.w800,
    color: NexusColors.textPrimary,
    letterSpacing: -1.5,
    height: 1.05,
  );

  static TextStyle heroSubtitle = GoogleFonts.syne(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    color: NexusColors.textPrimary,
    letterSpacing: -0.8,
    height: 1.15,
  );

  // ── Section labels (monospace, spaced) ─────────────────────────────────────
  static TextStyle sectionLabel = GoogleFonts.spaceMono(
    fontSize: 11,
    color: NexusColors.textMuted,
    letterSpacing: 2.0,
    fontWeight: FontWeight.w400,
  );

  // ── Card titles ────────────────────────────────────────────────────────────
  static TextStyle cardTitle = GoogleFonts.syne(
    fontSize: 17,
    fontWeight: FontWeight.w700,
    color: NexusColors.textPrimary,
  );

  static TextStyle cardSubtitle = GoogleFonts.syne(
    fontSize: 13,
    fontWeight: FontWeight.w600,
    color: NexusColors.textSecondary,
  );

  // ── Body / Chat ────────────────────────────────────────────────────────────
  static TextStyle body = GoogleFonts.dmSans(
    fontSize: 14,
    color: NexusColors.textSecondary,
    height: 1.65,
  );

  static TextStyle bodySmall = GoogleFonts.dmSans(
    fontSize: 12,
    color: NexusColors.textMuted,
    height: 1.5,
  );

  static TextStyle chatMessage = GoogleFonts.dmSans(
    fontSize: 14,
    color: NexusColors.textPrimary,
    height: 1.5,
  );

  // ── Tags / Chips ───────────────────────────────────────────────────────────
  static TextStyle tag = GoogleFonts.spaceMono(
    fontSize: 10,
    letterSpacing: 0.8,
    fontWeight: FontWeight.w700,
  );

  static TextStyle tagSmall = GoogleFonts.spaceMono(
    fontSize: 9,
    letterSpacing: 0.6,
    fontWeight: FontWeight.w700,
  );

  // ── Monospace / Numbers ────────────────────────────────────────────────────
  static TextStyle mono = GoogleFonts.jetBrainsMono(
    fontSize: 13,
    color: NexusColors.textSecondary,
  );

  static TextStyle monoSmall = GoogleFonts.jetBrainsMono(
    fontSize: 11,
    color: NexusColors.textMuted,
  );

  // ── Button ─────────────────────────────────────────────────────────────────
  static TextStyle button = GoogleFonts.syne(
    fontSize: 14,
    fontWeight: FontWeight.w700,
    color: NexusColors.textPrimary,
    letterSpacing: 0.5,
  );

  // ── App bar title ──────────────────────────────────────────────────────────
  static TextStyle appBarTitle = GoogleFonts.syne(
    fontSize: 18,
    fontWeight: FontWeight.w800,
    color: NexusColors.textPrimary,
    letterSpacing: -0.3,
  );
}
