import 'package:flutter/material.dart';

/// Warna diambil dari identitas logo Study Mate: navy + hijau.
class SMColors {
  static const navy = Color(0xFF0B2545);
  static const green = Color(0xFF1E8E5A);
  static const greenLight = Color(0xFF2FBE7F);
  static const bg = Color(0xFFF5F7FA);
}

ThemeData buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: SMColors.bg,
    colorScheme: base.colorScheme.copyWith(
      primary: SMColors.navy,
      secondary: SMColors.green,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: SMColors.navy,
      foregroundColor: Colors.white,
      elevation: 0,
      centerTitle: false,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: SMColors.green,
      foregroundColor: Colors.white,
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: SMColors.green,
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 1.5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      margin: const EdgeInsets.symmetric(horizontal: 4, vertical: 6),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
    ),
  );
}

ThemeData buildDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    colorScheme: base.colorScheme.copyWith(
      primary: SMColors.greenLight,
      secondary: SMColors.green,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF071A33),
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: SMColors.green,
      foregroundColor: Colors.white,
    ),
  );
}
