import 'package:flutter/material.dart';

class AppTheme {
  ThemeData getTheme() => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFFE4B45C),
      brightness: Brightness.dark,
      surface: const Color(0xFF101114),
    ),
    scaffoldBackgroundColor: const Color(0xFF101114),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF101114),
      surfaceTintColor: Colors.transparent,
    ),
    textTheme: Typography.material2021().white.copyWith(
      titleMedium: Typography.material2021().white.titleMedium?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -.35,
      ),
      titleLarge: Typography.material2021().white.titleLarge?.copyWith(
        fontWeight: FontWeight.w800,
      ),
      headlineSmall: Typography.material2021().white.headlineSmall?.copyWith(
        fontWeight: FontWeight.w800,
        letterSpacing: -.4,
      ),
    ),
  );
}
