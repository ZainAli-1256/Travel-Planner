// lib/core/constants/app_theme.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'app_colors.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get dark {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.navyDeep,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.amber,
        secondary: AppColors.amberLight,
        surface: AppColors.navyMid,
        background: AppColors.navyDeep,
        error: AppColors.error,
        onPrimary: AppColors.navyDeep,
        onSecondary: AppColors.navyDeep,
        onSurface: AppColors.white,
        onBackground: AppColors.white,
      ),
      textTheme: _buildTextTheme(),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        systemOverlayStyle: SystemUiOverlayStyle.light,
        titleTextStyle: GoogleFonts.sora(
          color: AppColors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        iconTheme: const IconThemeData(color: AppColors.white),
      ),
      inputDecorationTheme: _buildInputTheme(),
      elevatedButtonTheme: _buildElevatedButtonTheme(),
      cardTheme: const CardThemeData(
        color: AppColors.navyMid,
        elevation: 0,
        margin: EdgeInsets.zero,
      ),
      dividerTheme: const DividerThemeData(
        color: AppColors.glassBorder,
        thickness: 1,
      ),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: CupertinoPageTransitionsBuilder(),
          TargetPlatform.iOS: CupertinoPageTransitionsBuilder(),
        },
      ),
      useMaterial3: true,
    );
  }

  static TextTheme _buildTextTheme() {
    return TextTheme(
      displayLarge: GoogleFonts.sora(
        fontSize: 40,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        letterSpacing: -1.5,
      ),
      displayMedium: GoogleFonts.sora(
        fontSize: 32,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        letterSpacing: -1.0,
      ),
      headlineLarge: GoogleFonts.sora(
        fontSize: 26,
        fontWeight: FontWeight.w700,
        color: AppColors.white,
        letterSpacing: -0.5,
      ),
      headlineMedium: GoogleFonts.sora(
        fontSize: 22,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      headlineSmall: GoogleFonts.sora(
        fontSize: 18,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      titleLarge: GoogleFonts.sora(
        fontSize: 16,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      titleMedium: GoogleFonts.sora(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.white,
      ),
      titleSmall: GoogleFonts.sora(
        fontSize: 12,
        fontWeight: FontWeight.w600,
        color: AppColors.slate200,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        fontWeight: FontWeight.w400,
        color: AppColors.slate200,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        fontWeight: FontWeight.w400,
        color: AppColors.slate200,
      ),
      bodySmall: GoogleFonts.inter(
        fontSize: 12,
        fontWeight: FontWeight.w400,
        color: AppColors.slate400,
      ),
      labelLarge: GoogleFonts.sora(
        fontSize: 14,
        fontWeight: FontWeight.w600,
        color: AppColors.navyDeep,
        letterSpacing: 0.5,
      ),
    );
  }

  static InputDecorationTheme _buildInputTheme() {
    return InputDecorationTheme(
      filled: true,
      fillColor: AppColors.glassBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.glassBorder, width: 1),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.glassBorder, width: 1),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.amber, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error, width: 1),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(16),
        borderSide: const BorderSide(color: AppColors.error, width: 1.5),
      ),
      labelStyle: GoogleFonts.inter(color: AppColors.slate400, fontSize: 14),
      hintStyle: GoogleFonts.inter(color: AppColors.slate600, fontSize: 14),
      errorStyle: GoogleFonts.inter(color: AppColors.error, fontSize: 12),
      prefixIconColor: AppColors.slate400,
      suffixIconColor: AppColors.slate400,
    );
  }

  static ElevatedButtonThemeData _buildElevatedButtonTheme() {
    return ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.amber,
        foregroundColor: AppColors.navyDeep,
        elevation: 0,
        minimumSize: const Size(double.infinity, 56),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        textStyle: GoogleFonts.sora(
          fontSize: 15,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.3,
        ),
      ),
    );
  }
}
