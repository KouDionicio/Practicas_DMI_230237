import 'dart:async';

import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cinemapedia/config/helpers/l10n_helpers.dart';
import 'package:cinemapedia/config/theme/app_theme.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/shared/app_logo.dart';

/// Pantalla de carga inicial.
///
/// Para entonces `main()` ya cargó el `.env` y las preferencias (el idioma
/// ya es el correcto). Aquí se aplica la región guardada, se precarga el
/// logotipo y se pide la primera página de las cuatro listas de inicio.
/// En cuanto termina pasa a Inicio; si la red falla o tarda demasiado,
/// continúa igualmente e Inicio muestra el error con opción de reintentar.
class SplashScreen extends ConsumerStatefulWidget {
  static const name = 'splash-screen';

  /// Tiempo mínimo en pantalla para que la animación no sea un parpadeo.
  static const minimumDisplay = Duration(milliseconds: 900);
  static const maximumWait = Duration(seconds: 10);

  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen> {
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _initialize();
  }

  Future<void> _initialize() async {
    final minimum = Future<void>.delayed(SplashScreen.minimumDisplay);

    // Configuración regional (ya leída de SharedPreferences en main()).
    ref.read(appRegionProvider);

    await Future.wait([
      precacheImage(const AssetImage(AppLogo.asset), context).catchError((_) {}),
      ref
          .read(initialMoviesLoadProvider.future)
          .timeout(SplashScreen.maximumWait)
          .then<void>((_) {}, onError: (_) {}),
      minimum,
    ]);

    if (!mounted) return;
    context.go('/home/0');
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Stack(
        children: [
          // Halo de color de la marca
          Center(
            child: Container(
              width: 320,
              height: 320,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(colors: [
                  AppColors.violet.withValues(alpha: .22),
                  AppColors.background.withValues(alpha: 0),
                ]),
              ),
            ),
          ),
          Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                ZoomIn(
                  duration: const Duration(milliseconds: 650),
                  child: const AppLogo(size: 132, glow: true),
                ),
                const SizedBox(height: 28),
                FadeInUp(
                  delay: const Duration(milliseconds: 200),
                  duration: const Duration(milliseconds: 500),
                  from: 14,
                  child: Text('Cinemapedia', style: textTheme.headlineMedium?.copyWith(fontWeight: FontWeight.w800)),
                ),
                const SizedBox(height: 6),
                FadeIn(
                  delay: const Duration(milliseconds: 350),
                  child: Text(
                    l10n.appTagline,
                    style: textTheme.bodyLarge?.copyWith(color: AppColors.textSecondary),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            left: 0,
            right: 0,
            bottom: 56,
            child: SafeArea(
              child: FadeIn(
                delay: const Duration(milliseconds: 450),
                child: Column(
                  children: [
                    const SizedBox(
                      width: 26,
                      height: 26,
                      child: CircularProgressIndicator(strokeWidth: 2.5),
                    ),
                    const SizedBox(height: 14),
                    Text(
                      l10n.splashLoading,
                      style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
