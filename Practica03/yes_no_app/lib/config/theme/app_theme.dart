import 'package:flutter/material.dart';

const Color _customColor = Color(0xFF6200EE);

const List<Color> _colorThemes = [
  _customColor,
  Colors.blue,
  Colors.green,
  Colors.orange,
  Colors.red,
  Colors.purple,
  Colors.teal,
  Colors.yellow,
  Colors.pink,
  Colors.cyan,
];

class AppTheme {
  final int selectedColor;

  AppTheme({
    this.selectedColor = 0,
  }) : assert(
          selectedColor >= 0 &&
              selectedColor <= _colorThemes.length - 1,
          'selectedColor must be between 0 and ${_colorThemes.length - 1}',
        );

  ThemeData theme() {
    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: _colorThemes[selectedColor],
      brightness: Brightness.light,
    );
  }
}