// lib/core/constants/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // ── Primary Palette ──────────────────────────────────────────────
  static const Color navyDeep = Color(0xFF0A0F2E); // background base
  static const Color navyMid = Color(0xFF111638); // card backgrounds
  static const Color navyLight = Color(0xFF1C2454); // elevated surfaces

  // ── Accent ───────────────────────────────────────────────────────
  static const Color amber = Color(0xFFF5A623); // primary CTA
  static const Color amberLight = Color(0xFFFFCC6B); // highlights
  static const Color amberGlow = Color(0x33F5A623); // ambient glow

  // ── Slate / Neutral ───────────────────────────────────────────────
  static const Color slate600 = Color(0xFF4A5568);
  static const Color slate400 = Color(0xFF718096);
  static const Color slate200 = Color(0xFFCBD5E0);
  static const Color white = Color(0xFFFFFFFF);
  static const Color offWhite = Color(0xFFF7F8FC);

  // ── Semantic ─────────────────────────────────────────────────────
  static const Color success = Color(0xFF48BB78);
  static const Color error = Color(0xFFFC8181);
  static const Color info = Color(0xFF63B3ED);

  // ── Glass / Overlay ──────────────────────────────────────────────
  static const Color glassBg = Color(0x1AFFFFFF); // 10 % white
  static const Color glassBorder = Color(0x33FFFFFF); // 20 % white
  static const Color overlay30 = Color(0x4D000000);

  // ── Gradient helpers ─────────────────────────────────────────────
  static const LinearGradient navyGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [navyDeep, navyMid, Color(0xFF0D1535)],
  );

  static const LinearGradient amberGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [amber, amberLight],
  );

  static const LinearGradient cardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF1C2454), Color(0xFF111638)],
  );
}
