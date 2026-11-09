import 'package:flutter/material.dart';

/// Paleta de Cinemapedia, tomada del icono oficial: fondo casi negro y un
/// degradado de gema violeta → magenta → carmesí.
abstract final class AppColors {
  static const background = Color(0xFF0A0D12);
  static const surface = Color(0xFF12151D);
  static const surfaceHigh = Color(0xFF1A1E29);
  static const surfaceHighest = Color(0xFF232838);
  static const outline = Color(0xFF2E3446);

  static const violet = Color(0xFF8B5CF6);
  static const violetLight = Color(0xFFB794FF);
  static const magenta = Color(0xFFDD52EB);
  static const crimson = Color(0xFFE0365F);
  static const crimsonDeep = Color(0xFF88163A);

  static const star = Color(0xFFFFC857);
  static const textPrimary = Color(0xFFF4F2FA);
  static const textSecondary = Color(0xFFA9A6BA);

  /// Degradado de marca (bordes seleccionados, acentos, cabecera del menú).
  static const brandGradient = LinearGradient(
    begin: AlignmentDirectional.topStart,
    end: AlignmentDirectional.bottomEnd,
    colors: [violet, magenta, crimson],
  );
}

class AppTheme {
  /// [languageCode] permite ajustar la tipografía: en árabe, japonés y
  /// coreano no se aplica espaciado negativo entre letras (en árabe rompería
  /// la unión de los caracteres).
  final String languageCode;

  const AppTheme({this.languageCode = 'es'});

  bool get _tightLetterSpacing => !const {'ar', 'ja', 'ko'}.contains(languageCode);

  ThemeData getTheme() {
    final base = Typography.material2021().white;
    final tracking = _tightLetterSpacing ? -.35 : 0.0;

    final colorScheme = ColorScheme.fromSeed(
      seedColor: AppColors.violet,
      brightness: Brightness.dark,
    ).copyWith(
      primary: AppColors.violetLight,
      onPrimary: const Color(0xFF1F0B45),
      primaryContainer: const Color(0xFF3A1F7A),
      onPrimaryContainer: const Color(0xFFEADDFF),
      secondary: AppColors.magenta,
      onSecondary: const Color(0xFF3B0A40),
      secondaryContainer: const Color(0xFF4A1A55),
      onSecondaryContainer: const Color(0xFFFAD8FF),
      tertiary: AppColors.crimson,
      surface: AppColors.surface,
      onSurface: AppColors.textPrimary,
      onSurfaceVariant: AppColors.textSecondary,
      surfaceContainerLowest: AppColors.background,
      surfaceContainerLow: const Color(0xFF0F1219),
      surfaceContainer: AppColors.surface,
      surfaceContainerHigh: AppColors.surfaceHigh,
      surfaceContainerHighest: AppColors.surfaceHighest,
      outline: AppColors.outline,
      outlineVariant: const Color(0xFF242938),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: colorScheme,
      scaffoldBackgroundColor: AppColors.background,
      splashFactory: InkSparkle.splashFactory,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.background,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        centerTitle: false,
      ),
      textTheme: base.copyWith(
        titleMedium: base.titleMedium?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: tracking,
        ),
        titleLarge: base.titleLarge?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: tracking,
        ),
        headlineSmall: base.headlineSmall?.copyWith(
          fontWeight: FontWeight.w800,
          letterSpacing: _tightLetterSpacing ? -.4 : 0,
        ),
        bodyMedium: base.bodyMedium?.copyWith(height: 1.4),
      ),
      iconTheme: const IconThemeData(color: AppColors.textPrimary),
      drawerTheme: const DrawerThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        scrimColor: Color(0xB3000000),
      ),
      navigationDrawerTheme: NavigationDrawerThemeData(
        backgroundColor: AppColors.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: AppColors.violet.withValues(alpha: .22),
        indicatorShape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        tileHeight: 52,
      ),
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: AppColors.surface,
        selectedItemColor: AppColors.violetLight,
        unselectedItemColor: AppColors.textSecondary,
        type: BottomNavigationBarType.fixed,
        elevation: 0,
        showUnselectedLabels: true,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.surfaceHighest,
        contentTextStyle: const TextStyle(color: AppColors.textPrimary),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: AppColors.violet,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(foregroundColor: AppColors.violetLight),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: AppColors.surfaceHigh,
        side: const BorderSide(color: AppColors.outline),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        labelStyle: const TextStyle(color: AppColors.textPrimary),
      ),
      progressIndicatorTheme: const ProgressIndicatorThemeData(color: AppColors.violetLight),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: AppColors.surfaceHighest,
          borderRadius: BorderRadius.circular(8),
        ),
        textStyle: const TextStyle(color: AppColors.textPrimary),
      ),
      dividerTheme: const DividerThemeData(color: AppColors.outline, space: 1),
    );
  }
}
