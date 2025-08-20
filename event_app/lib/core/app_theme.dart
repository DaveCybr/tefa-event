import 'package:flutter/material.dart';

class AppColors {
  static const accent = Color(0xFFF2F862);
  static const white = Color(0xFFFEFEFE);
  static const gray = Color(0xFFC1C1C1);
  static const black = Color(0xFF000000);
  static const dark = Color(0xFF404040);
}

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: AppColors.black,
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.accent,
      secondary: AppColors.dark,
      surface: const Color(0xFF111111),
      onPrimary: AppColors.black,
      onSurface: AppColors.white,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFF1A1A1A),
      hintStyle: const TextStyle(color: AppColors.gray),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.dark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.dark),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: const TextStyle(fontWeight: FontWeight.w700),
      ),
    ),
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.white,
      textColor: AppColors.white,
    ),
  );
}
