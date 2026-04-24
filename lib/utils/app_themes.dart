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
  //  LIGHT (primary) theme — full Material 3 upgrade
  // ──────────────────────────────────────────────────────────────────────────
  AppTheme.White: ThemeData(
    useMaterial3: true,

    // Seed-based color scheme keeps the whole app on-brand automatically.
    colorScheme: ColorScheme.fromSeed(
      seedColor: MyColors.primary,
      brightness: Brightness.light,
    ).copyWith(
      primary: MyColors.primary,
      onPrimary: Colors.white,
      primaryContainer: MyColors.primaryVeryLight,
      onPrimaryContainer: MyColors.primaryDark,
      secondary: MyColors.accent,
      onSecondary: MyColors.accentOnDark,
      surface: MyColors.surface,
      onSurface: MyColors.textPrimary,
      surfaceContainerHighest: Colors.white,
      outline: MyColors.border,
      error: const Color(0xFFD24F45),
    ),

    scaffoldBackgroundColor: MyColors.surface,
    fontFamily: 'airbnb',
    brightness: Brightness.light,
    primaryColor: MyColors.primary,

    // ── AppBar ──────────────────────────────────────────────────────────────
    appBarTheme: AppBarTheme(
      systemOverlayStyle: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      backgroundColor: MyColors.mainC0lor,
      foregroundColor: Colors.white,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: false,
      titleTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 20,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.3,
      ),
      toolbarTextStyle: const TextStyle(
        color: Colors.white,
        fontSize: 16,
        fontWeight: FontWeight.w500,
      ),
      iconTheme: const IconThemeData(color: Colors.white),
      actionsIconTheme: const IconThemeData(color: Colors.white),
    ),

    // ── Cards ───────────────────────────────────────────────────────────────
    cardTheme: CardThemeData(
      color: Colors.white,
      elevation: 0,
      margin: EdgeInsets.zero,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(20),
        side: BorderSide(color: MyColors.border),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.08),
      surfaceTintColor: Colors.transparent,
    ),

    // ── Elevated button ─────────────────────────────────────────────────────
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: MyColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
          letterSpacing: 0.2,
        ),
      ),
    ),

    // ── Outlined button ──────────────────────────────────────────────────────
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: MyColors.primary,
        side: BorderSide(color: MyColors.primary, width: 1.5),
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
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
        minimumSize: const Size(double.infinity, 52),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(18),
        ),
        textStyle: const TextStyle(
          fontWeight: FontWeight.w700,
          fontSize: 16,
        ),
      ),
    ),

    // ── Input fields ─────────────────────────────────────────────────────────
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: Colors.white,
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: MyColors.border),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: MyColors.border),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: BorderSide(color: MyColors.primary, width: 2),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide: const BorderSide(color: Color(0xFFD24F45)),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(18),
        borderSide:
            const BorderSide(color: Color(0xFFD24F45), width: 2),
      ),
      hintStyle: TextStyle(color: MyColors.textSecondary, fontSize: 15),
      labelStyle: TextStyle(color: MyColors.textSecondary, fontSize: 15),
      prefixIconColor: MyColors.textSecondary,
      suffixIconColor: MyColors.textSecondary,
    ),

    // ── List tiles ───────────────────────────────────────────────────────────
    listTileTheme: ListTileThemeData(
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      contentPadding:
          const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      tileColor: Colors.transparent,
      titleTextStyle: TextStyle(
        color: MyColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 16,
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
    dividerTheme: DividerThemeData(
      color: MyColors.border,
      thickness: 1,
      space: 1,
    ),

    // ── Chips ────────────────────────────────────────────────────────────────
    chipTheme: ChipThemeData(
      backgroundColor: MyColors.primaryVeryLight,
      selectedColor: MyColors.primary,
      disabledColor: const Color(0xFFEDE7EA),
      labelStyle: TextStyle(
        color: MyColors.primaryDark,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      secondaryLabelStyle: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.w600,
        fontSize: 13,
      ),
      side: BorderSide.none,
      shape: const StadiumBorder(),
      padding:
          const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
    ),

    // ── Dialogs ──────────────────────────────────────────────────────────────
    dialogTheme: DialogThemeData(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(24),
      ),
      elevation: 8,
      titleTextStyle: TextStyle(
        color: MyColors.textPrimary,
        fontSize: 20,
        fontWeight: FontWeight.w800,
      ),
      contentTextStyle: TextStyle(
        color: MyColors.textSecondary,
        fontSize: 15,
        height: 1.5,
      ),
    ),

    // ── Bottom sheet ─────────────────────────────────────────────────────────
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      elevation: 0,
    ),

    // ── Snack bars ───────────────────────────────────────────────────────────
    snackBarTheme: SnackBarThemeData(
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(14),
      ),
      backgroundColor: MyColors.textPrimary,
      contentTextStyle:
          const TextStyle(color: Colors.white, fontSize: 14),
      actionTextColor: MyColors.accent,
    ),

    // ── Bottom nav ───────────────────────────────────────────────────────────
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: Colors.white,
      selectedItemColor: MyColors.primary,
      unselectedItemColor: const Color(0xFF7E7380),
      selectedLabelStyle: const TextStyle(
        fontWeight: FontWeight.w700,
        fontSize: 12,
      ),
      unselectedLabelStyle: const TextStyle(fontSize: 12),
      elevation: 0,
      type: BottomNavigationBarType.fixed,
    ),

    // ── Progress indicators ──────────────────────────────────────────────────
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: MyColors.primary,
    ),

    // ── Switches & checkboxes ────────────────────────────────────────────────
    switchTheme: SwitchThemeData(
      thumbColor:
          WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return Colors.white;
        }
        return const Color(0xFF7E7380);
      }),
      trackColor:
          WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return MyColors.primary;
        }
        return const Color(0xFFE0D4DA);
      }),
    ),

    checkboxTheme: CheckboxThemeData(
      fillColor: WidgetStateProperty.resolveWith((states) {
        if (states.contains(WidgetState.selected)) {
          return MyColors.primary;
        }
        return Colors.transparent;
      }),
      checkColor: WidgetStateProperty.all(Colors.white),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(5),
      ),
      side: BorderSide(color: MyColors.border, width: 1.5),
    ),

    // ── Icons ────────────────────────────────────────────────────────────────
    iconTheme: IconThemeData(color: MyColors.textPrimary, size: 24),

    // ── Text theme ───────────────────────────────────────────────────────────
    textTheme: TextTheme(
      // Display — hero / splash text
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
      // Headline — section / page titles
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
      // Title — card / list / dialog titles
      titleLarge: TextStyle(
        color: MyColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 22,
        letterSpacing: -0.1,
      ),
      titleMedium: TextStyle(
        color: MyColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 16,
        letterSpacing: 0.1,
      ),
      titleSmall: TextStyle(
        color: MyColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 14,
        letterSpacing: 0.1,
      ),
      // Body — paragraph / descriptions
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
      // Label — button / chip / badge text
      labelLarge: TextStyle(
        color: MyColors.textPrimary,
        fontWeight: FontWeight.w700,
        fontSize: 14,
        letterSpacing: 0.1,
      ),
      labelMedium: TextStyle(
        color: MyColors.textPrimary,
        fontWeight: FontWeight.w600,
        fontSize: 12,
        letterSpacing: 0.5,
      ),
      labelSmall: TextStyle(
        color: MyColors.textSecondary,
        fontWeight: FontWeight.w500,
        fontSize: 11,
        letterSpacing: 0.5,
      ),
    ),
  ),

  // ──────────────────────────────────────────────────────────────────────────
  //  DARK theme — preserved from existing implementation
  // ──────────────────────────────────────────────────────────────────────────
  AppTheme.Dark: ThemeData(
    scaffoldBackgroundColor: Colors.black,
    fontFamily: 'airbnb',
    primaryColor: MyColors.backgroundColor,
    canvasColor: MyColors.backgroundColor,
    brightness: Brightness.light,
    dialogTheme: const DialogThemeData(
      titleTextStyle: TextStyle(color: Colors.black),
    ),
    appBarTheme: const AppBarTheme(
      systemOverlayStyle:
          SystemUiOverlayStyle(statusBarColor: Colors.black),
      backgroundColor: Colors.black,
      iconTheme: IconThemeData(color: Colors.black),
      titleTextStyle: TextStyle(color: Colors.white),
    ),
    bottomSheetTheme: const BottomSheetThemeData(),
    bottomNavigationBarTheme: BottomNavigationBarThemeData(
      backgroundColor: MyColors.backgroundColor,
    ),
    dividerColor: Colors.grey.shade800,
    cardTheme:
        CardThemeData(color: MyColors.backgroundColor, elevation: 20),
    iconTheme: const IconThemeData(color: Colors.white),
    textTheme: const TextTheme(
      titleLarge: TextStyle(
        color: Colors.black,
        fontSize: 20.0,
        fontFamily: 'airbnb',
      ),
      titleSmall: TextStyle(
        color: Colors.black,
        fontFamily: 'airbnb',
        fontSize: 18.0,
      ),
      headlineMedium: TextStyle(color: Colors.black, fontFamily: 'airbnb'),
      displaySmall: TextStyle(color: Colors.black, fontFamily: 'airbnb'),
      displayMedium: TextStyle(color: Colors.black, fontFamily: 'airbnb'),
      displayLarge: TextStyle(color: Colors.black, fontFamily: 'airbnb'),
      titleMedium: TextStyle(color: Colors.black, fontFamily: 'airbnb'),
      bodyMedium: TextStyle(color: Colors.black, fontFamily: 'airbnb'),
      bodyLarge: TextStyle(color: Colors.black, fontFamily: 'airbnb'),
      labelSmall: TextStyle(color: Colors.black),
      bodySmall: TextStyle(color: Colors.black),
    ),
  ),
};


