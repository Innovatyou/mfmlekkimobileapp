import 'package:flutter/material.dart';

class MyColors {
  // ── Random avatar / card palette ───────────────────────────────────────────
  static List<Color?> randomcolors = [
    Colors.amber[900],
    Colors.lime[700],
    Colors.purple,
    Colors.teal,
    Colors.indigo[900],
    Colors.blueGrey[700],
    Colors.pink,
  ];

  // ── Brand colours (Indigo) ────────────────────────────────────────────────
  static const Color primary = Color(0xFF6366f1);
  static const Color primaryDark = Color(0xFF4f46e5);
  static const Color primaryLight = Color(0xFF818cf8);
  static const Color primaryVeryLight = Color(0xFFe0e7ff);
  static Color mainC0lor = const Color(0xFF6366f1); // alias kept for back-compat

  // ── Accent (amber/gold) ───────────────────────────────────────────────────
  static const Color accent = Color(0xFFf59e0b);
  static const Color accentDark = Color(0xFFd97706);
  static const Color accentLight = Color(0xFFfde68a);
  static const Color accentOnDark = Color(0xFF40220F);

  // ── Semantic surface / background ─────────────────────────────────────────
  static const Color surface = Color(0xFFf0f2f5);
  static const Color cardSurface = Colors.white;
  static Color backgroundColor = Colors.white; // kept for dark-theme compat

  // ── Semantic text ─────────────────────────────────────────────────────────
  static const Color textPrimary = Color(0xFF0f172a);
  static const Color textBody = Color(0xFF1e293b);
  static const Color textSecondary = Color(0xFF475569);
  static const Color textDisabled = Color(0xFF94a3b8);

  // ── Semantic border ───────────────────────────────────────────────────────
  static const Color border = Color(0xFFe2e8f0);
  static const Color borderStrong = Color(0xFFcbd5e1);

  // ── Semantic status ───────────────────────────────────────────────────────
  static const Color success = Color(0xFF10b981);
  static const Color danger = Color(0xFFef4444);
  static const Color warning = Color(0xFFf59e0b);

  // ── Navigation ────────────────────────────────────────────────────────────
  static const Color navBackground = Color(0xFF0d1117);
  static const Color navBorder = Color(0x14ffffff); // rgba(255,255,255,0.08)

  // ── Legacy named colours (kept so other screens don't break) ─────────────
  static Color kTextColor = const Color(0xFF0D1333);
  static Color kBlueColor = const Color(0xFF6366f1);
  static Color kBestSellerColor = const Color(0xFFFFD073);
  static Color kGreenColor = const Color(0xFF10b981);

  static const Color grey_3 = Color(0xFFf7f7f7);
  static const Color grey_5 = Color(0xFFf2f2f2);
  static const Color grey_10 = Color(0xFFe6e6e6);
  static const Color grey_20 = Color(0xFFcccccc);
  static const Color grey_40 = Color(0xFF999999);
  static const Color grey_60 = Color(0xFF666666);
  static const Color grey_80 = Color(0xFF37474F);
  static const Color grey_90 = Color(0xFF263238);
  static const Color grey_95 = Color(0xFF1a1a1a);
  static const Color grey_100_ = Color(0xFF0d0d0d);

  static const Color notWhite = Color(0xFFEDF0F2);
  static const Color nearlyWhite = Color(0xFFFEFEFE);
  static const Color white = Color(0xFFFFFFFF);
  static const Color nearlyBlack = Color(0xFF213333);
  static const Color grey = Color(0xFF3A5160);
  static const Color dark_grey = Color(0xFF313A44);

  static const Color darkText = Color(0xFF253840);
  static const Color darkerText = Color(0xFF17262A);
  static const Color lightText = Color(0xFF4A6572);
  static const Color deactivatedText = Color(0xFF767676);
  static const Color dismissibleBackground = Color(0xFF364A54);
  static const Color chipBackground = Color(0xFFEEF1F3);
  static const Color spacer = Color(0xFFF2F2F2);
  static const String fontName = 'WorkSans';
}
