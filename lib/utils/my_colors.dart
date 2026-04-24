import 'package:flutter/material.dart';
import 'package:higherground/utils/Utility.dart';

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

  // ── Brand colours ─────────────────────────────────────────────────────────
  static Color primary = Utility.hexToColor('#980c5d');
  static Color primaryDark = Utility.hexToColor('#6b083f');
  static Color primaryLight = Utility.hexToColor('#c84b85');
  static Color primaryVeryLight = Utility.hexToColor('#f2d7e6');
  static Color mainC0lor = Utility.hexToColor('#980c5d'); // alias kept for back-compat

  // ── Accent (warm gold) ───────────────────────────────────────────────────
  static const Color accent = Color(0xFFFFC857);
  static const Color accentDark = Color(0xFFE6B04A);
  static const Color accentLight = Color(0xFFFFE1A8);
  /// Foreground colour to use on top of the accent (gold) background.
  static const Color accentOnDark = Color(0xFF40220F);

  // ── Semantic surface / background ─────────────────────────────────────────
  /// Light pinkish-neutral page background — used as scaffoldBackgroundColor.
  static const Color surface = Color(0xFFF7F1F4);
  /// Pure white — used for card surfaces, inputs, dialogs.
  static const Color cardSurface = Colors.white;
  static Color backgroundColor = Colors.white; // kept for dark-theme compat

  // ── Semantic text ─────────────────────────────────────────────────────────
  /// Near-black primary text — headings, titles, body copy.
  static const Color textPrimary = Color(0xFF23141D);
  /// Slightly lighter dark text — secondary body copy.
  static const Color textBody = Color(0xFF3D2533);
  /// Mid-tone muted text — subtitles, hints, captions.
  static const Color textSecondary = Color(0xFF7A6B75);
  /// Light disabled / placeholder text.
  static const Color textDisabled = Color(0xFFB09EAA);

  // ── Semantic border ───────────────────────────────────────────────────────
  /// Default card / input border colour.
  static const Color border = Color(0xFFE8DDE4);
  /// Slightly stronger border for focused states.
  static const Color borderStrong = Color(0xFFC8B4BE);

  // ── Legacy named colours (kept so other screens don't break) ─────────────
  static Color kTextColor = const Color(0xFF0D1333);
  static Color kBlueColor = const Color(0xFF6E8AFA);
  static Color kBestSellerColor = const Color(0xFFFFD073);
  static Color kGreenColor = const Color(0xFF49CC96);

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




