import 'package:flutter/material.dart';

// Light Theme
ThemeData lightTheme = ThemeData(
  brightness: Brightness.light,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xff415f91), // Using primary color as seed
    brightness: Brightness.light,
    primary: const Color(0xff415f91),
    onPrimary: const Color(0xffffffff),
    primaryContainer: const Color(0xffd6e3ff),
    onPrimaryContainer: const Color(0xff001b3e),
    secondary: const Color(0xff425e91),
    onSecondary: const Color(0xffffffff),
    secondaryContainer: const Color(0xffd7e2ff),
    onSecondaryContainer: const Color(0xff001b3f),
    tertiary: const Color(0xff35618e),
    onTertiary: const Color(0xffffffff),
    tertiaryContainer: const Color(0xffd1e4ff),
    onTertiaryContainer: const Color(0xff001d35),
    error: const Color(0xff904a42),
    onError: const Color(0xffffffff),
    errorContainer: const Color(0xffffdad5),
    onErrorContainer: const Color(0xff3b0906),
    background: const Color(0xfff9f9ff),
    onBackground: const Color(0xff191c20),
    surface: const Color(0xfff5fafb),
    onSurface: const Color(0xff171d1e),
    surfaceVariant: const Color(0xffdbe4e6),
    onSurfaceVariant: const Color(0xff3f484a),
    outline: const Color(0xff6f797a),
    shadow: const Color(0xff000000),
    inverseSurface: const Color(0xff2b3133),
    onInverseSurface: const Color(0xffecf2f3),
    inversePrimary: const Color(0xffaac7ff),
  ),
  useMaterial3: true,
);

// Dark theme
ThemeData darkTheme = ThemeData(
  brightness: Brightness.dark,
  colorScheme: ColorScheme.fromSeed(
    seedColor: const Color(0xffaac7ff), // Using primary color as seed
    brightness: Brightness.dark,
    primary: const Color(0xffaac7ff),
    onPrimary: const Color(0xff0a305f),
    primaryContainer: const Color(0xff284777),
    onPrimaryContainer: const Color(0xffd6e3ff),
    secondary: const Color(0xffabc7ff),
    onSecondary: const Color(0xff0d2f5f),
    secondaryContainer: const Color(0xff294677),
    onSecondaryContainer: const Color(0xffd7e2ff),
    tertiary: const Color(0xff9fcafd),
    onTertiary: const Color(0xff003257),
    tertiaryContainer: const Color(0xff174974),
    onTertiaryContainer: const Color(0xffd1e4ff),
    error: const Color(0xffffb4aa),
    onError: const Color(0xff561e18),
    errorContainer: const Color(0xff73342c),
    onErrorContainer: const Color(0xffffdad5),
    background: const Color(0xff111318),
    onBackground: const Color(0xffe2e2e9),
    surface: const Color(0xff0e1415),
    onSurface: const Color(0xffdee3e5),
    surfaceVariant: const Color(0xff3f484a),
    onSurfaceVariant: const Color(0xffbfc8ca),
    outline: const Color(0xff899294),
    shadow: const Color(0xff000000),
    inverseSurface: const Color(0xffdee3e5),
    onInverseSurface: const Color(0xff2b3133),
    inversePrimary: const Color(0xff415f91),
  ),
  useMaterial3: true,
);
