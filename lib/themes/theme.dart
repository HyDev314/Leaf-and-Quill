import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:leaf_and_quill_app/config/constants/constants.dart';
import 'package:leaf_and_quill_app/themes/palette.dart';
import 'package:shared_preferences/shared_preferences.dart';

final themeNotifierProvider =
    StateNotifierProvider<ThemeNotifier, ThemeData>((ref) {
  return ThemeNotifier();
});

class AppTheme {
  static _border([Color color = AppPalette.borderColor]) => OutlineInputBorder(
        borderSide: BorderSide(
          color: color,
          width: 1,
        ),
        borderRadius: BorderRadius.circular(18),
      );

  static var lightThemeMode = ThemeData.light().copyWith(
    scaffoldBackgroundColor: AppPalette.lightBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.lightCardColor,
      iconTheme: IconThemeData(
        color: AppPalette.darkBackgroundColor,
      ),
    ),
    cardTheme: CardTheme(
      color: AppPalette.lightCardColor,
      surfaceTintColor: AppPalette.lightCardColor,
      shadowColor: AppPalette.greyColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppPalette.lightDrawerColor,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppPalette.lightCardColor,
      selectedItemColor: AppPalette.mainColor,
      unselectedItemColor: AppPalette.greyColor,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppPalette.mainColor,
      foregroundColor: AppPalette.lightDrawerColor,
      shape: CircleBorder(),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.lightDrawerColor,
          foregroundColor: AppPalette.darkDrawerColor,
          shadowColor: AppPalette.darkDrawerColor,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          )),
    ),
    primaryColor: AppPalette.redColor,
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

  static var darkThemeMode = ThemeData.dark().copyWith(
    scaffoldBackgroundColor: AppPalette.darkBackgroundColor,
    appBarTheme: const AppBarTheme(
      backgroundColor: AppPalette.darkCardColor,
      iconTheme: IconThemeData(
        color: AppPalette.lightBackgroundColor,
      ),
    ),
    cardTheme: CardTheme(
      color: AppPalette.darkCardColor,
      surfaceTintColor: AppPalette.darkCardColor,
      shadowColor: AppPalette.greyColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(18),
      ),
    ),
    drawerTheme: const DrawerThemeData(
      backgroundColor: AppPalette.darkDrawerColor,
    ),
    bottomNavigationBarTheme: const BottomNavigationBarThemeData(
      backgroundColor: AppPalette.darkCardColor,
      selectedItemColor: AppPalette.mainColor,
      unselectedItemColor: AppPalette.greyColor,
      type: BottomNavigationBarType.fixed,
      showSelectedLabels: false,
      showUnselectedLabels: false,
    ),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppPalette.mainColor,
      foregroundColor: AppPalette.lightDrawerColor,
      shape: CircleBorder(),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
          backgroundColor: AppPalette.darkCardColor,
          foregroundColor: AppPalette.lightDrawerColor,
          shadowColor: AppPalette.lightDrawerColor,
          minimumSize: const Size(double.infinity, 50),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(18),
          )),
    ),
    primaryColor: AppPalette.redColor,
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
}

class ThemeNotifier extends StateNotifier<ThemeData> {
  ThemeMode _mode;
  ThemeNotifier({ThemeMode mode = ThemeMode.dark})
      : _mode = mode,
        super(
          AppTheme.darkThemeMode,
        ) {
    getTheme();
  }

  ThemeMode get mode => _mode;

  void getTheme() async {
    SharedPreferences pref = await SharedPreferences.getInstance();
    final theme = pref.getString('theme');

    if (theme == 'light') {
      _mode = ThemeMode.light;
      state = AppTheme.lightThemeMode;
    } else {
      _mode = ThemeMode.dark;
      state = AppTheme.darkThemeMode;
    }
  }

  void toggleTheme() async {
    SharedPreferences pref = await SharedPreferences.getInstance();

    if (_mode == ThemeMode.dark) {
      _mode = ThemeMode.light;
      state = AppTheme.lightThemeMode;
      pref.setString('theme', 'light');
    } else {
      _mode = ThemeMode.dark;
      state = AppTheme.darkThemeMode;
      pref.setString('theme', 'dark');
    }
  }
}
