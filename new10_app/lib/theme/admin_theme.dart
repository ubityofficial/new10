import 'package:flutter/material.dart';

class AdminTheme {
  // Primary Colors - Modern Blue
  static const Color primary = Color(0xFF0F62FE);
  static const Color primaryLight = Color(0xFF0043CE);
  static const Color primaryDark = Color(0xFF0043CE);

  // Secondary Colors
  static const Color success = Color(0xFF24A148);
  static const Color warning = Color(0xFFF1C21B);
  static const Color error = Color(0xFFDA1E28);
  static const Color info = Color(0xFF0043CE);

  // Status Colors
  static const Color statusActive = Color(0xFF24A148);
  static const Color statusPending = Color(0xFFF1C21B);
  static const Color statusApproved = Color(0xFF24A148);
  static const Color statusSuspended = Color(0xFFF1C21B);
  static const Color statusBlocked = Color(0xFFDA1E28);
  static const Color statusRejected = Color(0xFFDA1E28);

  // Neutral Colors
  static const Color background = Color(0xFFFAFBFC);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF4F4F4);
  static const Color border = Color(0xFFE0E0E0);
  static const Color divider = Color(0xFFE8E8E8);
  static const Color textPrimary = Color(0xFF161616);
  static const Color textSecondary = Color(0xFF525252);
  static const Color textTertiary = Color(0xFF8D8D8D);
  static const Color textDisabled = Color(0xFFCCCCCC);

  // Shadows
  static const List<BoxShadow> shadowXS = [
    BoxShadow(
      color: Color(0x0A000000),
      blurRadius: 4,
      offset: Offset(0, 1),
    )
  ];

  static const List<BoxShadow> shadowSM = [
    BoxShadow(
      color: Color(0x0D000000),
      blurRadius: 8,
      offset: Offset(0, 1),
    )
  ];

  static const List<BoxShadow> shadowMD = [
    BoxShadow(
      color: Color(0x1A000000),
      blurRadius: 12,
      offset: Offset(0, 4),
    )
  ];

  static const List<BoxShadow> shadowLG = [
    BoxShadow(
      color: Color(0x19000000),
      blurRadius: 24,
      offset: Offset(0, 12),
    )
  ];

  // Border Radius
  static const double radiusXS = 4;
  static const double radiusSM = 6;
  static const double radiusMD = 8;
  static const double radiusLG = 12;
  static const double radiusXL = 16;
  static const double radius2XL = 20;

  // Spacing
  static const double spacing2XS = 4;
  static const double spacingXS = 8;
  static const double spacingSM = 12;
  static const double spacingMD = 16;
  static const double spacingLG = 24;
  static const double spacingXL = 32;
  static const double spacing2XL = 40;
  static const double spacing3XL = 48;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primary,
        secondary: Color(0xFF0F62FE),
        surface: surface,
        background: background,
        error: error,
      ),
      fontFamily: 'Segoe UI',
      scaffoldBackgroundColor: background,
      appBarTheme: const AppBarTheme(
        backgroundColor: surface,
        foregroundColor: textPrimary,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: surfaceVariant,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: spacingMD,
          vertical: spacingSM,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: divider),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: divider),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(radiusMD),
          borderSide: const BorderSide(color: primary, width: 2),
        ),
        hintStyle: const TextStyle(color: textTertiary),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primary,
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingMD,
            vertical: spacingSM,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(radiusMD),
          ),
          elevation: 0,
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: primary,
          padding: const EdgeInsets.symmetric(
            horizontal: spacingMD,
            vertical: spacingSM,
          ),
        ),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: surfaceVariant,
        selectedColor: primary,
        labelStyle: const TextStyle(color: textPrimary),
        padding: const EdgeInsets.symmetric(
          horizontal: spacingSM,
          vertical: spacingXS,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusMD),
        ),
      ),
    );
  }
}
