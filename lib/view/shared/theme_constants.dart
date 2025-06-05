import 'package:flutter/material.dart';

/// Class containing all global color codes.
abstract class Global {
  static const primary = Color(0xff4338CA);
  static const secondary = Color(0xff6D28D9);
  static const tertiary = Color(0xffffffff);
  static const background = Color(0xffffffff);
  static const error = Color(0xffEF4444);
  static const gradient = "linear-gradient(to right, #4338CA, #6D28D9)";
}

/// Object containing the light theme.
ThemeData lightTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Global.primary,
    brightness: Brightness.light,
    primary: Global.primary,
    secondary: Global.secondary,
    tertiary: Global.tertiary,
    background: Global.background,
    error: Global.error,
  ),
);

/// Object containing the dark theme.
ThemeData darkTheme = ThemeData(
  colorScheme: ColorScheme.fromSeed(
    seedColor: Global.primary,
    brightness: Brightness.dark,
    primary: Global.primary,
    secondary: Global.secondary,
    tertiary: Global.tertiary,
    background: Global.background,
    error: Global.error,
  ),
);
