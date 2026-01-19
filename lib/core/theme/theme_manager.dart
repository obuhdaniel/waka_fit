import 'package:flutter/material.dart';
import 'package:waka_fit/core/theme/app_colors.dart';

ThemeData getLightTheme() {
  return ThemeData(
    fontFamily: "Georgia",
    brightness: Brightness.light,
    primaryColor: AppColors.primary,
    colorScheme: ColorScheme.light(
      primary: AppColors.primary,
      secondary: AppColors.green,
      surface: AppColors.white,
      error: AppColors.red,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.black,
      onError: AppColors.white,
    ),
    useMaterial3: true,
    textTheme: ThemeData.light().textTheme.apply(
      bodyColor: AppColors.black,
      displayColor: AppColors.black,
    ),
    listTileTheme: ListTileThemeData(
      textColor: AppColors.black,
      iconColor: AppColors.textStroke,
    ),
    scaffoldBackgroundColor: AppColors.background,
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.primary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.white,
      foregroundColor: AppColors.black,
      elevation: 0,
      shadowColor: AppColors.white,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: AppColors.black),
      titleTextStyle: TextStyle(
        fontFamily: "Georgia",
        color: AppColors.black,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.white,
      elevation: 2,
      shadowColor: AppColors.stroke,
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.stroke,
      thickness: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.white,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.stroke),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.stroke),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.primary, width: 2),
      ),
    ),
  );
}

ThemeData getDarkTheme() {
  return ThemeData(
     fontFamily: "Georgia",
    brightness: Brightness.dark,
    primaryColor: AppColors.darkPrimary,
    colorScheme: ColorScheme.dark(
      primary: AppColors.darkPrimary,
      secondary: AppColors.green,
      surface: AppColors.darkSurface,
      error: AppColors.red,
      onPrimary: AppColors.white,
      onSecondary: AppColors.white,
      onSurface: AppColors.darkTextPrimary,
      onError: AppColors.white,
    ),
    useMaterial3: true,
    textTheme: ThemeData.dark().textTheme.apply(
      bodyColor: AppColors.darkTextPrimary,
      displayColor: AppColors.darkTextPrimary,
    ),
    listTileTheme: ListTileThemeData(
      textColor: AppColors.darkTextPrimary,
      iconColor: AppColors.darkTextSecondary,
    ),
    scaffoldBackgroundColor: AppColors.darkBackground,
    progressIndicatorTheme: ProgressIndicatorThemeData(
      color: AppColors.darkPrimary,
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: AppColors.darkSurface,
      foregroundColor: AppColors.darkTextPrimary,
      elevation: 0,
      shadowColor: AppColors.darkBackground,
      surfaceTintColor: Colors.transparent,
      iconTheme: IconThemeData(color: AppColors.darkTextPrimary),
      titleTextStyle: TextStyle(
        fontFamily: "Georgia",
        color: AppColors.darkTextPrimary,
        fontSize: 18,
        fontWeight: FontWeight.w600,
      ),
    ),
    cardTheme: CardThemeData(
      color: AppColors.darkSurface,
      elevation: 2,
      shadowColor: AppColors.darkStroke,
    ),
    dividerTheme: DividerThemeData(
      color: AppColors.darkStroke,
      thickness: 1,
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: AppColors.darkSurface,
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.darkStroke),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.darkStroke),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(8),
        borderSide: BorderSide(color: AppColors.darkPrimary, width: 2),
      ),
    ),
  );
}

// Backward compatibility
ThemeData getApplicationTheme() {
  return getLightTheme();
}
