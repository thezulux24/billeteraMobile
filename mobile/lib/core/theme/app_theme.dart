import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  const AppTheme._();

  static ThemeData get light {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: AppColors.seed,
          brightness: Brightness.light,
        ).copyWith(
          secondary: AppColors.accent,
          surface: Colors.white,
          onSurface: const Color(0xff1e1b4b),
          onSurfaceVariant: const Color(0xff475569),
        );

    final textTheme = GoogleFonts.manropeTextTheme().copyWith(
      displaySmall: GoogleFonts.manrope(
        fontSize: 36,
        fontWeight: FontWeight.w700,
        color: const Color(0xff1e1b4b),
      ),
      headlineSmall: GoogleFonts.manrope(
        fontSize: 25,
        fontWeight: FontWeight.w700,
        color: const Color(0xff1e1b4b),
      ),
      bodyLarge: GoogleFonts.manrope(
        fontSize: 16,
        color: const Color(0xff1e1b4b),
      ),
      bodyMedium: GoogleFonts.manrope(
        fontSize: 14,
        color: const Color(0xff475569),
      ),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: textTheme,
      iconTheme: const IconThemeData(color: Color(0xff1e1b4b)),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: Color(0xff1e1b4b),
        iconTheme: IconThemeData(color: Color(0xff1e1b4b)),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: const Color(0xff4f46e5),
          textStyle: GoogleFonts.manrope(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: GoogleFonts.manrope(fontWeight: FontWeight.w500),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.black.withValues(alpha: 0.05),
      ),
    );
  }

  static ThemeData get dark {
    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.seed,
      brightness: Brightness.dark,
    ).copyWith(secondary: AppColors.accent, surface: const Color(0xFF112A35));

    final textTheme =
        GoogleFonts.plusJakartaSansTextTheme(
          ThemeData(brightness: Brightness.dark).textTheme,
        ).copyWith(
          displaySmall: GoogleFonts.sora(
            fontSize: 36,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.8,
            height: 1.1,
          ),
          headlineSmall: GoogleFonts.sora(
            fontSize: 25,
            fontWeight: FontWeight.w700,
            letterSpacing: -0.4,
          ),
          titleMedium: GoogleFonts.plusJakartaSans(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
          bodyLarge: GoogleFonts.plusJakartaSans(fontSize: 16, height: 1.35),
          bodyMedium: GoogleFonts.plusJakartaSans(fontSize: 14, height: 1.35),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      scaffoldBackgroundColor: Colors.transparent,
      textTheme: textTheme,
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          textStyle: GoogleFonts.plusJakartaSans(
            fontWeight: FontWeight.w600,
            letterSpacing: 0.1,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        labelStyle: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.w600),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(16),
          borderSide: BorderSide.none,
        ),
        filled: true,
        fillColor: Colors.white.withValues(alpha: 0.14),
      ),
    );
  }
}
