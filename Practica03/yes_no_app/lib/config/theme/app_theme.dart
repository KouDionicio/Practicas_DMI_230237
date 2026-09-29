import 'package:flutter/material.dart';

const Color _customColor = Color(0xFF59477D);

const List<Color> _colorThemes = [
  _customColor,
  Color(0xFFB65D7A),
  Color(0xFF438C83),
];

const Color _canvasColor = Color(0xFFFBF8FC);
const Color _inkColor = Color(0xFF2F2935);

class AppTheme {
  final int selectedColor;

  AppTheme({this.selectedColor = 0})
    : assert(
        selectedColor >= 0 && selectedColor <= _colorThemes.length - 1,
        'selectedColor must be between 0 and ${_colorThemes.length}',
      );

  ThemeData theme() {
    final colorScheme =
        ColorScheme.fromSeed(
          seedColor: _colorThemes[selectedColor],
          brightness: Brightness.light,
        ).copyWith(
          primary: _colorThemes[selectedColor],
          secondary: const Color(0xFFD87991),
          tertiary: const Color(0xFF438C83),
          surface: const Color(0xFFFFFCFF),
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: _canvasColor,
      appBarTheme: const AppBarTheme(
        backgroundColor: Color(0xFFFFFCFF),
        foregroundColor: _inkColor,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
      ),
      textTheme: const TextTheme(
        titleLarge: TextStyle(
          fontFamily: 'LugoRockwell',
          color: _inkColor,
          fontSize: 18,
          fontWeight: FontWeight.w700,
        ),
        bodyMedium: TextStyle(color: _inkColor),
      ),
    );
  }
}
