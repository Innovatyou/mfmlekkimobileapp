import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:higherground/utils/my_colors.dart';

enum AppTheme { White, Dark }

/// Returns enum value name without enum class name.
String enumName(AppTheme anyEnum) {
  return anyEnum.toString().split('.')[1];
}

final appThemeData = {
  // ──────────────────────────────────────────────────────────────────────────
  //  LIGHT (primary) theme — indigo design system
  // ──────────────────────────────────────────────────────────────────────────
  AppTheme.White: ThemeData(
    useMaterial3: true,

    colorScheme: ColorScheme.fromSeed(
      seedColor: MyColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: MyColors.primary,
      onPrimary: Colors.white,
      primaryContainer: MyColors.primaryVeryLight,
      onPrimaryContainer: MyColors.primaryDark,
      secondary: MyColors.accent,
      onSecondary: Colors.white,
      surface: MyColors.surface,
      onSurface: MyColors.textPrimary,
      surfaceContainerHighest: Colors.white,
      outline: MyColors.border,
      error: MyColors.danger,
    ),

    scaffoldBackgroundColor: MyColors.surface,
    // null = system sans-serif (Roboto on Android, SF Pro on iOS)
    fontFamily: null,
    brightness: Brightness.light,
    primaryColor: MyColors.primary,

    // ── AppBar ──────────────────────────────────────────────────────────────
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      backgroundColor: Color(0xFF0d1117),
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      toolbarTextStyle: TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      iconTheme: IconThemeData(color: Colors.white),
      actionsIconTheme: IconThemeData(color: Colors.white),
    ),

    // ── Cards ───────────────────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(color: MyColors.border, width: 1.5),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.06),
      surfaceTintColor: Colors.transparent,
    ),

    // ── Elevated button ─────────────────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MyColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),

    // ── Outlined button ──────────────────────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: MyColors.primary,
        side: const BorderSide(color: MyColors.primary, width: 1.5),
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),

    // ── Text button ──────────────────────────────────────────────────────────
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: MyColors.primary,
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),

    // ── Filled button ────────────────────────────────────────────────────────
    filledButtonTheme: FilledButtonThemeData(
      style: FilledButton.styleFrom(
        backgroundColor: MyColors.primary,
        foregroundColor: Colors.white,
        minimumSize: const Size(double.infinity, 48),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 15,
        ),
      ),
    ),

    // ── Input fields ─────────────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: MyColors.border, width: 1.5),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: MyColors.border, width: 1.5),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: MyColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: MyColors.danger),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: const BorderSide(color: MyColors.danger, width: 2),
      ),
      hintStyle: const TextStyle(color: MyColors.textDisabled, fontSize: 14),
      labelStyle: const TextStyle(color: MyColors.textSecondary, fontSize: 14),
      prefixIconColor: MyColors.textSecondary,
      suffixIconColor: MyColors.textSecondary,
    ),

    // ── List tiles ───────────────────────────────────────────────────────────
    listTileTheme: const ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
      ),
      contentPadding: EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      tileColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: MyColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 15,
      ),
      subtitleTextStyle: TextStyle(
        color: MyColors.textSecondary,
        fontSize: 13,
        height: 1.4,
      ),
      leadingAndTrailingTextStyle: TextStyle(
        color: MyColors.textSecondary,
        fontSize: 13,
      ),
      iconColor: MyColors.primary,
    ),

    // ── Dividers ─────────────────────────────────────────────────────────────
    dividerTheme: const DividerThemeData(
      color: MyColors.border,
      thickness: 1,
      space: 1,
    ),

    // ── Chips ────────────────────────────────────────────────────────────────
    chipTheme: const ChipThemeData(
      backgroundColor: MyColors.primaryVeryLight,
      selectedColor: MyColors.primary,
      disabledColor: Color(0xFFf1f5f9),
      labelStyle: TextStyle(
        color: MyColors.primaryDark,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      secondaryLabelStyle: TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      side: BorderSide.none,
      shape: StadiumBorder(),
      padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
    ),

    // ── Dialogs ──────────────────────────────────────────────────────────────
    dialogTheme: const DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
      elevation: 8,
      titleTextStyle: TextStyle(
        color: MyColors.textPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w700,
      ),
      contentTextStyle: TextStyle(
        color: MyColors.textSecondary,
        fontSize: 14,
        height: 1.5,
      ),
    ),

    // ── Bottom sheet ─────────────────────────────────────────────────────────
    bottomSheetTheme: const BottomSheetThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      elevation: 0,
    ),

    // ── Snack bars ───────────────────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8),
      ),
      backgroundColor: MyColors.textPrimary,
      contentTextStyle: const TextStyle(color: Colors.white, fontSize: 14),
      actionTextColor: MyColors.accent,
    ),

    // ── Bottom nav ───────────────────────────────────────────────────────────
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: Color(0xFF0d1117),
      selectedItemColor: MyColors.primary,
      unselectedItemColor: Color(0xFF6b7280),
      selectedLabelStyle: TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      unselectedLabelStyle: TextStyle(fontSize: 12),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),

    // ── Progress indicators ──────────────────────────────────────────────────
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: MyColors.primary,
    ),

    // ── Switches & checkboxes ────────────────────────────────────────────────
    switchTheme: SwitchThemeData(
      thumbColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return Colors.white;
        return const Color(0xFF94a3b8);
      }),
      trackColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return MyColors.primary;
        return const Color(0xFFe2e8f0);
      }),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) return MyColors.primary;
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(4),
      ),
      side: const BorderSide(color: MyColors.border, width: 1.5),
    ),

    // ── Icons ────────────────────────────────────────────────────────────────
    iconTheme: const IconThemeData(color: MyColors.textPrimary, size: 24),

    // ── Text theme ───────────────────────────────────────────────────────────
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: MyColors.textPrimary,
        fontWeight: FontWeight.w900,
        fontSize: 57,
        letterSpacing: -1.0,
      ),
      displayMedium: TextStyle(
        color: MyColors.textPrimary,
        fontWeight: FontWeight.w800,
        fontSize: 45,
        letterSpacing: -0.5,
      ),
      displaySmall: TextStyle(
        color: MyColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 36,
        letterSpacing: -0.3,
      ),
      headlineLarge: TextStyle(
        color: MyColors.textPrimary,
        fontWeight: FontWeight.w800,
        fontSize: 32,
        letterSpacing: -0.3,
      ),
      headlineMedium: TextStyle(
        color: MyColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 28,
        letterSpacing: -0.2,
      ),
      headlineSmall: TextStyle(
        color: MyColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 24,
      ),
      titleLarge: TextStyle(
        color: MyColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 20,
        letterSpacing: -0.1,
      ),
      titleMedium: TextStyle(
        color: MyColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 16,
      ),
      titleSmall: TextStyle(
        color: MyColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      bodyLarge: TextStyle(
        color: MyColors.textPrimary,
        fontSize: 16,
        height: 1.55,
      ),
      bodyMedium: TextStyle(
        color: MyColors.textBody,
        fontSize: 14,
        height: 1.5,
      ),
      bodySmall: TextStyle(
        color: MyColors.textSecondary,
        fontSize: 12,
        height: 1.4,
      ),
      labelLarge: TextStyle(
        color: MyColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 14,
      ),
      labelMedium: TextStyle(
        color: MyColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 12,
        letterSpacing: 0.4,
      ),
      labelSmall: TextStyle(
        color: MyColors.textSecondary,
        fontWeight: FontWeight.w500,
        fontSize: 11,
        letterSpacing: 0.4,
      ),
    ),
  ),

  // ──────────────────────────────────────────────────────────────────────────
  //  DARK theme — preserved from existing implementation
  // ──────────────────────────────────────────────────────────────────────────
  AppTheme.Dark: ThemeData(
    scaffoldBackgroundColor: Colors.black,
    fontFamily: null,
    primaryColor: MyColors.backgroundColor,
    canvasColor: MyColors.backgroundColor,
    brightness: Brightness.light,
    dialogTheme: const DialogThemeData(
      titleTextStyle: TextStyle(color: Colors.black),
    ),
    appBarTheme: const AppBarTheme(
      systemOverlayStyle: SystemUiOverlayStyle(statusBarColor: Colors.black),
      backgroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(color: Colors.white),
    ),
    bottomSheetTheme: const BottomSheetThemeData(),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: MyColors.backgroundColor,
    ),
    dividerColor: Colors.grey.shade800,
    cardTheme: CardThemeData(color: MyColors.backgroundColor, elevation: 20),
    iconTheme: const IconThemeData(color: Colors.white),
    textTheme: const TextTheme(
      titleLarge: TextStyle(color: Colors.black, fontSize: 20.0),
      titleSmall: TextStyle(color: Colors.black, fontSize: 18.0),
      headlineMedium: TextStyle(color: Colors.black),
      displaySmall: TextStyle(color: Colors.black),
      displayMedium: TextStyle(color: Colors.black),
      displayLarge: TextStyle(color: Colors.black),
      titleMedium: TextStyle(color: Colors.black),
      bodyMedium: TextStyle(color: Colors.black),
      bodyLarge: TextStyle(color: Colors.black),
      labelSmall: TextStyle(color: Colors.black),
      bodySmall: TextStyle(color: Colors.black),
    ),
  ),
};
