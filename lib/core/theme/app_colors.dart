import 'dart:ui';

class AppColors {
  // Light Theme Colors
  static Color primary = HexColor.fromHex("#E11D48");
  static Color black = HexColor.fromHex("#000000");
  static Color green = HexColor.fromHex("#10B981");
  static Color white = HexColor.fromHex("#FFFFFF");
  static Color container = HexColor.fromHex("#E0F2F1");
  static Color brown = HexColor.fromHex("#155724");
  static Color red = HexColor.fromHex("#E11D48");
  static Color background = HexColor.fromHex("#F8FAFC");
  static Color darkGreen = HexColor.fromHex("#0F766E");
  static Color stroke = HexColor.fromHex("#E2E8F0");
  static Color textStroke = HexColor.fromHex("#64748B");//
  static Color backgrey = HexColor.fromHex("#FFEBEE");
  static Color backslide = HexColor.fromHex("#F1F5F9");
  static Color blue = HexColor.fromHex("#0284C7");
  static Color orange = HexColor.fromHex("#FB8C00");

  // Dark Theme Colors
  static Color darkPrimary = HexColor.fromHex("#F43F5E"); // Slightly lighter primary for dark theme
  static Color darkBackground = HexColor.fromHex("#0F172A"); // Dark slate background
  static Color darkSurface = HexColor.fromHex("#1E293B"); // Dark surface color
  static Color darkContainer = HexColor.fromHex("#334155"); // Dark container
  static Color darkStroke = HexColor.fromHex("#475569"); // Dark stroke
  static Color darkTextPrimary = HexColor.fromHex("#F8FAFC"); // Light text for dark theme
  static Color darkTextSecondary = HexColor.fromHex("#CBD5E1"); // Secondary text for dark theme
  static Color darkTextStroke = HexColor.fromHex("#94A3B8"); // Muted text for dark theme
}

extension HexColor on Color {
  static Color fromHex(String hexColorString) {
    hexColorString = hexColorString.replaceAll('#', '');
    if (hexColorString.length == 6) {
      hexColorString = "FF$hexColorString"; // 8 char with opacity 100%
    }
    return Color(int.parse(hexColorString, radix: 16));
  }
}