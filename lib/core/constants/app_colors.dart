import 'package:flutter/material.dart';

/// ====================================================================
/// File: app_colors.dart
/// --------------------------------------------------------------------
/// Definisi Warna Aplikasi SmartWealth AI
///
/// Palet warna komik-pastel yang cerah, informatif, dan ramah
/// untuk semua kalangan. Terinspirasi dari Synexa App.
///
/// Warna Utama: Indigo/Blue Pastel (identitas AI Health)
/// Aksen: Coral, Mint, Lavender, Peach
///
/// Author: SmartWealth Dev Team
/// ====================================================================

class AppColors {
  const AppColors._();

  // ── Brand Primary ─────────────────────────────────────────
  static const Color primary       = Color(0xFF6C63FF); // Indigo vivid
  static const Color primaryLight  = Color(0xFFE0E7FF); // Indigo pastel
  static const Color primaryDark   = Color(0xFF4338CA); // Indigo dark
  static const Color onPrimary     = Colors.white;

  // ── Backgrounds ──────────────────────────────────────────
  static const Color backgroundLight = Color(0xFFF6F8FF); // Blue-white soft
  static const Color backgroundDark  = Color(0xFF0F1117); // Deep dark

  // ── Surface (Card backgrounds) ───────────────────────────
  static const Color surfaceLight = Colors.white;
  static const Color surfaceDark  = Color(0xFF1A1D2E);

  // ── Bento Card Pastel Colors (Komik & Cerah) ─────────────
  static const Color cardRed     = Color(0xFFFFD6D6); // Merah pastel lembut
  static const Color cardPeach   = Color(0xFFFFE5CC); // Peach/Orange pastel
  static const Color cardYellow  = Color(0xFFFFF3B0); // Kuning pastel
  static const Color cardMint    = Color(0xFFCCF5E1); // Mint/Hijau pastel
  static const Color cardBlue    = Color(0xFFD0E8FF); // Biru pastel
  static const Color cardIndigo  = Color(0xFFDDD6FE); // Indigo/Lavender pastel
  static const Color cardPink    = Color(0xFFFFD6F5); // Pink pastel
  static const Color cardCoral   = Color(0xFFFFB3B3); // Coral pastel

  // ── Legacy aliases (backward compatibility) ──────────────
  static const Color softBlue    = cardIndigo;
  static const Color softRed     = cardRed;
  static const Color softGreen   = cardMint;
  static const Color softOrange  = cardPeach;
  static const Color softCoral   = cardCoral;
  static const Color softPurple  = cardIndigo;

  // ── Text ─────────────────────────────────────────────────
  static const Color textPrimaryLight   = Color(0xFF1E1B4B); // Indigo sangat gelap
  static const Color textSecondaryLight = Color(0xFF6B7280); // Abu netral
  static const Color textPrimaryDark    = Color(0xFFF1F0FF); // Putih keunguan
  static const Color textSecondaryDark  = Color(0xFF9CA3AF);

  // ── Semantic / Status ─────────────────────────────────────
  static const Color success = Color(0xFF10B981); // Hijau emerald
  static const Color warning = Color(0xFFFBBF24); // Kuning amber
  static const Color error   = Color(0xFFEF4444); // Merah
  static const Color info    = Color(0xFF3B82F6); // Biru

  // ── Risk Level (Prediksi Pradiabetes / AI) ────────────────
  static const Color riskLow    = Color(0xFF10B981); // Hijau - aman
  static const Color riskMedium = Color(0xFFF59E0B); // Kuning - waspada
  static const Color riskHigh   = Color(0xFFEF4444); // Merah - bahaya

  // ── Gradient Presets ─────────────────────────────────────
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF6C63FF), Color(0xFF4338CA)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient mintGradient = LinearGradient(
    colors: [Color(0xFF34D399), Color(0xFF10B981)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient sunsetGradient = LinearGradient(
    colors: [Color(0xFFF97316), Color(0xFFEF4444)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient skyGradient = LinearGradient(
    colors: [Color(0xFF60A5FA), Color(0xFF6C63FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // ── Navbar & UI ──────────────────────────────────────────
  static const Color navbarBg        = Colors.white;
  static const Color navbarIconInactive = Color(0xFFBBBDC9);
  static const Color navbarActiveGradStart = Color(0xFF6C63FF);
  static const Color navbarActiveGradEnd   = Color(0xFF4338CA);
}
