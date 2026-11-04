import 'package:flutter/material.dart';

class AppTheme {
  static const Color sfondo = Color(0xFFFAFAF7);
  static const Color superficie = Color(0xFFFFFFFF);
  static const Color testo = Color(0xFF1E293B);
  static const Color testoSecondario = Color(0xFF64748B);
  static const Color principale = Color(0xFF2563EB);
  static const Color accento = Color(0xFFF59E0B);
  static const Color bordo = Color(0xFFE2E8F0);

  static ThemeData get chiaro {
    final schemaColori = ColorScheme.fromSeed(
      seedColor: principale,
      brightness: Brightness.light,
    ).copyWith(
      primary: principale,
      secondary: accento,
      surface: superficie,
      onSurface: testo,
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: schemaColori,
      scaffoldBackgroundColor: sfondo,

      appBarTheme: const AppBarTheme(
        backgroundColor: sfondo,
        foregroundColor: testo,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          color: testo,
          fontSize: 22,
          fontWeight: FontWeight.w700,
          letterSpacing: 0.2,
        ),
      ),

      textTheme: const TextTheme(
        headlineSmall: TextStyle(
          color: testo,
          fontSize: 25,
          fontWeight: FontWeight.w700,
        ),
        titleLarge: TextStyle(
          color: testo,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        titleMedium: TextStyle(
          color: testo,
          fontSize: 17,
          fontWeight: FontWeight.w600,
        ),
        bodyLarge: TextStyle(
          color: testo,
          fontSize: 16,
        ),
        bodyMedium: TextStyle(
          color: testo,
          fontSize: 14,
        ),
        bodySmall: TextStyle(
          color: testoSecondario,
          fontSize: 13,
        ),
      ),

      cardTheme: CardThemeData(
        color: superficie,
        elevation: 0,
        margin: EdgeInsets.zero,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
          side: const BorderSide(color: bordo),
        ),
      ),

      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: principale,
          foregroundColor: Colors.white,
          minimumSize: const Size.fromHeight(52),
          textStyle: const TextStyle(
            fontSize: 15,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.4,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: principale,
          minimumSize: const Size.fromHeight(48),
          side: const BorderSide(color: principale),
          textStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),

      sliderTheme: const SliderThemeData(
        activeTrackColor: principale,
        inactiveTrackColor: bordo,
        thumbColor: principale,
        overlayColor: Color(0x1F2563EB),
        trackHeight: 4,
      ),

      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: superficie,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: bordo),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: bordo),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(
            color: principale,
            width: 2,
          ),
        ),
      ),

      dividerTheme: const DividerThemeData(
        color: bordo,
        thickness: 1,
      ),
    );
  }
}