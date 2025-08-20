import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class AppColors {
  // Primary Colors
  static const accent = Color(0xFFF2F862);
  static const white = Color(0xFFFEFEFE);
  static const gray = Color(0xFFC1C1C1);
  static const black = Color(0xFF000000);
  static const dark = Color(0xFF404040);

  // Additional Colors
  static const lightGray = Color(0xFFE5E5E5);
  static const mediumGray = Color(0xFF888888);
  static const darkGray = Color(0xFF2A2A2A);
  static const surface = Color(0xFF111111);
  static const surfaceVariant = Color(0xFF1A1A1A);
  static const error = Color(0xFFFF5252);
  static const success = Color(0xFF4CAF50);
  static const warning = Color(0xFFFF9800);

  // Transparent Colors
  static const accentTransparent = Color(0x1AF2F862);
  static const whiteTransparent = Color(0x1AFEFEFE);
  static const blackTransparent = Color(0x80000000);
}

class AppTextStyles {
  // Headlines
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    color: AppColors.white,
  );

  static const TextStyle headlineMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static const TextStyle headlineSmall = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  // Body Text
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
  );

  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: AppColors.white,
  );

  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.gray,
  );

  // Labels
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w600,
    color: AppColors.white,
  );

  static const TextStyle labelSmall = TextStyle(
    fontSize: 10,
    fontWeight: FontWeight.w600,
    color: AppColors.gray,
  );

  // Button Text
  static const TextStyle buttonText = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: AppColors.black,
  );

  // Caption
  static const TextStyle caption = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: AppColors.mediumGray,
  );
}

ThemeData buildTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    // System UI
    scaffoldBackgroundColor: AppColors.black,
    useMaterial3: true,

    // Color Scheme
    colorScheme: base.colorScheme.copyWith(
      primary: AppColors.accent,
      secondary: AppColors.dark,
      surface: AppColors.surface,
      surfaceVariant: AppColors.surfaceVariant,
      onPrimary: AppColors.black,
      onSurface: AppColors.white,
      onSurfaceVariant: AppColors.gray,
      error: AppColors.error,
      onError: AppColors.white,
      outline: AppColors.dark,
      outlineVariant: AppColors.darkGray,
      background: AppColors.black,
      onBackground: AppColors.white,
    ),

    // Text Theme
    textTheme: base.textTheme.copyWith(
      headlineLarge: AppTextStyles.headlineLarge,
      headlineMedium: AppTextStyles.headlineMedium,
      headlineSmall: AppTextStyles.headlineSmall,
      bodyLarge: AppTextStyles.bodyLarge,
      bodyMedium: AppTextStyles.bodyMedium,
      bodySmall: AppTextStyles.bodySmall,
      labelLarge: AppTextStyles.labelLarge,
      labelMedium: AppTextStyles.labelMedium,
      labelSmall: AppTextStyles.labelSmall,
    ),

    // App Bar Theme
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.black,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: AppTextStyles.headlineSmall,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      iconTheme: const IconThemeData(color: AppColors.white),
      actionsIconTheme: const IconThemeData(color: AppColors.white),
    ),

    // Input Decoration Theme
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.surfaceVariant,
      hintStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.mediumGray),
      labelStyle: AppTextStyles.bodyMedium.copyWith(color: AppColors.gray),
      errorStyle: AppTextStyles.bodySmall.copyWith(color: AppColors.error),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.dark),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.dark),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.accent, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.error),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(14),
        borderSide: BorderSide(color: AppColors.error, width: 2),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
    ),

    // Button Themes
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.accent,
        foregroundColor: AppColors.black,
        disabledBackgroundColor: AppColors.darkGray,
        disabledForegroundColor: AppColors.mediumGray,
        elevation: 0,
        shadowColor: Colors.transparent,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: AppTextStyles.buttonText,
        minimumSize: const Size(88, 48),
      ),
    ),

    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: AppColors.accent,
        textStyle: AppTextStyles.labelLarge.copyWith(color: AppColors.accent),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    ),

    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: AppColors.accent,
        side: BorderSide(color: AppColors.accent),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
        textStyle: AppTextStyles.buttonText.copyWith(color: AppColors.accent),
      ),
    ),

    // Card Theme
    cardTheme: CardTheme(
      color: AppColors.surface,
      elevation: 0,
      shadowColor: Colors.transparent,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(color: AppColors.dark.withOpacity(0.3)),
      ),
      margin: const EdgeInsets.symmetric(vertical: 4),
    ),

    // List Tile Theme
    listTileTheme: const ListTileThemeData(
      iconColor: AppColors.white,
      textColor: AppColors.white,
      titleTextStyle: AppTextStyles.bodyLarge,
      subtitleTextStyle: AppTextStyles.bodySmall,
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    ),

    // Switch Theme
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.accent;
        }
        return AppColors.gray;
      }),
      trackColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.accent.withOpacity(0.3);
        }
        return AppColors.dark;
      }),
    ),

    // Divider Theme
    dividerTheme: DividerThemeData(
      color: AppColors.dark.withOpacity(0.3),
      thickness: 1,
      space: 1,
    ),

    // Dialog Theme
    dialogTheme: DialogTheme(
      backgroundColor: AppColors.surface,
      surfaceTintColor: Colors.transparent,
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      titleTextStyle: AppTextStyles.headlineSmall,
      contentTextStyle: AppTextStyles.bodyMedium.copyWith(
        color: AppColors.gray,
      ),
    ),

    // Snackbar Theme
    snackBarTheme: SnackBarThemeData(
      backgroundColor: AppColors.surfaceVariant,
      contentTextStyle: AppTextStyles.bodyMedium,
      actionTextColor: AppColors.accent,
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
    ),

    // Icon Theme
    iconTheme: const IconThemeData(color: AppColors.white, size: 24),

    // Progress Indicator Theme
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.accent,
      linearTrackColor: AppColors.dark,
      circularTrackColor: AppColors.dark,
    ),

    // Floating Action Button Theme
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.accent,
      foregroundColor: AppColors.black,
      elevation: 4,
      shape: CircleBorder(),
    ),

    // Navigation Bar Theme
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppColors.surface,
      selectedItemColor: AppColors.accent,
      unselectedItemColor: AppColors.gray,
      type: BottomNavigationBarType.fixed,
      elevation: 0,
    ),

    // Chip Theme
    chipTheme: ChipThemeData(
      backgroundColor: AppColors.dark.withOpacity(0.3),
      labelStyle: AppTextStyles.labelSmall.copyWith(color: AppColors.white),
      side: BorderSide(color: AppColors.dark.withOpacity(0.5)),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
    ),

    // Checkbox Theme
    checkboxTheme: CheckboxThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.accent;
        }
        return Colors.transparent;
      }),
      checkColor: MaterialStateProperty.all(AppColors.black),
      side: BorderSide(color: AppColors.gray),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
    ),

    // Radio Theme
    radioTheme: RadioThemeData(
      fillColor: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return AppColors.accent;
        }
        return AppColors.gray;
      }),
    ),

    // TabBar Theme
    tabBarTheme: TabBarTheme(
      labelColor: AppColors.accent,
      unselectedLabelColor: AppColors.gray,
      indicator: UnderlineTabIndicator(
        borderSide: BorderSide(color: AppColors.accent, width: 2),
      ),
      labelStyle: AppTextStyles.labelLarge.copyWith(color: AppColors.accent),
      unselectedLabelStyle: AppTextStyles.labelLarge.copyWith(
        color: AppColors.gray,
      ),
    ),
  );
}
