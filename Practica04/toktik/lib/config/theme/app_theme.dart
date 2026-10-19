import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/season.dart';
import 'package:toktik/presentation/providers/season_provider.dart';

class AppTheme {
  ThemeData getTheme(Season season) => ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,
    fontFamily: season.fontFamily,
    scaffoldBackgroundColor: season.backgroundColor,
    colorScheme: ColorScheme.fromSeed(
      seedColor: season.primaryColor,
      brightness: Brightness.dark,
      surface: season.backgroundColor,
    ),
    iconTheme: IconThemeData(color: season.primaryColor),
    iconButtonTheme: IconButtonThemeData(
      style: ButtonStyle(
        foregroundColor: WidgetStatePropertyAll(season.primaryColor),
      ),
    ),
  );
}
