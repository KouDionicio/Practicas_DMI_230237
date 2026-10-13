import 'package:flutter/material.dart';

void main() {
  runApp(const MainApp());
}

class AppTheme {
  final int selectedColor;

  const AppTheme({this.selectedColor = 0});

  ThemeData getTheme() {
    final List<Color> colors = const [
      Color(0xFF3F51B5),
      Color(0xFF009688),
      Color(0xFFE91E63),
      Color(0xFFFF9800),
      Color(0xFF4CAF50),
    ];

    final color = colors[selectedColor.clamp(0, colors.length - 1)];

    return ThemeData(
      useMaterial3: true,
      colorSchemeSeed: color,
    );
  }
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: AppTheme(selectedColor: 0).getTheme(),
    );
  }
}