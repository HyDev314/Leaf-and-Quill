import 'package:flutter/material.dart';
import 'package:leaf_and_quill_app/config/constants/constants.dart';
import 'package:leaf_and_quill_app/themes/palette.dart';

class AppTheme {
  static _border([Color color = AppPalette.borderColor]) => OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(18),
      );

  static final darkThemeMode = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppPalette.darkBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.darkBackgroundColor,
      surfaceTintColor: AppPalette.darkBackgroundColor,
    ),
    chipTheme: const ChipThemeData(
      color: MaterialStatePropertyAll(
        AppPalette.darkBackgroundColor,
      ),
      side: BorderSide.none,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      contentPadding: EdgeInsets.zero,
      border: InputBorder.none,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppPalette.whiteColor,
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w700,
      ),
      displaySmall: TextStyle(
        color: AppPalette.whiteColor,
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w300,
      ),
      labelLarge: TextStyle(
        color: AppPalette.whiteColor,
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w700,
      ),
      labelSmall: TextStyle(
        color: AppPalette.whiteColor,
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w300,
      ),
    ),
  );

  static final lightThemeMode = ThemeData.light().copyWith(
    scaffoldBackgroundColor: AppPalette.lightBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.lightBackgroundColor,
      surfaceTintColor: AppPalette.lightBackgroundColor,
    ),
    chipTheme: const ChipThemeData(
      color: MaterialStatePropertyAll(
        AppPalette.lightBackgroundColor,
      ),
      side: BorderSide.none,
    ),
    inputDecorationTheme: const InputDecorationTheme(
      contentPadding: EdgeInsets.zero,
      border: InputBorder.none,
    ),
    textTheme: const TextTheme(
      displayLarge: TextStyle(
        color: AppPalette.textColor,
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w700,
      ),
      displaySmall: TextStyle(
        color: AppPalette.textColor,
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w300,
      ),
      labelLarge: TextStyle(
        color: AppPalette.whiteColor,
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w700,
      ),
      labelSmall: TextStyle(
        color: AppPalette.whiteColor,
        fontFamily: AppConstants.fontFamily,
        fontWeight: FontWeight.w300,
      ),
    ),
  );
}
