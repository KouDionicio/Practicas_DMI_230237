import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:toktik/domain/entities/season.dart';
import 'package:toktik/presentation/providers/season_provider.dart';
import 'package:toktik/presentation/screens/discover/discover_screen.dart';
import 'package:toktik/presentation/services/seasonal_splash_audio.dart';

class TokTikSplashScreen extends StatefulWidget {
  const TokTikSplashScreen({
    super.key,
    required this.startupAudio,
    this.splashDuration = const Duration(seconds: 3),
    this.removeNativeSplash,
    this.destinationBuilder,
  });

  final StartupAudio startupAudio;
  final Duration splashDuration;
  final VoidCallback? removeNativeSplash;
  final WidgetBuilder? destinationBuilder;

  @override
  State<TokTikSplashScreen> createState() => _TokTikSplashScreenState();
}

class _TokTikSplashScreenState extends State<TokTikSplashScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _logoAnimationController;
  Season? _audioSeason;
  Object? _audioError;
  Object? _logoError;
  bool _audioDisposed = false;

  @override
  void initState() {
    super.initState();
    _logoAnimationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
      lowerBound: 0.97,
      upperBound: 1.03,
    )..repeat(reverse: true);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_prepareSplash());
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final season = context.read<SeasonProvider>().season;
    if (_audioSeason == season) return;
    _audioSeason = season;
    unawaited(_syncSplashAudioSeason(season));
  }

  Future<void> _syncSplashAudioSeason(Season season) async {
    try {
      await widget.startupAudio.setSeason(season);
      if (mounted) setState(() => _audioError = null);
    } catch (exception) {
      if (mounted) setState(() => _audioError = exception);
    }
  }

  Future<void> _prepareSplash() async {
    final season = context.read<SeasonProvider>().season;
    try {
      await precacheImage(AssetImage(season.splashLogoAsset), context);
    } catch (exception) {
      _logoError = exception;
    }
    if (!mounted) return;
    (widget.removeNativeSplash ?? FlutterNativeSplash.remove)();
    setState(() {});
    unawaited(_playIntroAndOpenHome());
  }

  Future<void> _playIntroAndOpenHome() async {
    final stopwatch = Stopwatch()..start();
    try {
      await widget.startupAudio.playFor(widget.splashDuration);
    } catch (exception) {
      _audioError = exception;
    }
    _audioError ??= widget.startupAudio.error;
    if (mounted && _audioError != null) setState(() {});

    final remaining = widget.splashDuration - stopwatch.elapsed;
    if (remaining > Duration.zero) {
      await Future<void>.delayed(remaining);
    }
    try {
      await widget.startupAudio.dispose();
      _audioDisposed = true;
    } catch (exception) {
      _audioError ??= exception;
    }
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: widget.destinationBuilder ?? (_) => const DiscoverScreen(),
      ),
    );
  }

  @override
  void dispose() {
    _logoAnimationController.dispose();
    if (!_audioDisposed) unawaited(widget.startupAudio.dispose());
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final season = context.watch<SeasonProvider>().season;
    final audioError = _audioError ?? widget.startupAudio.error;
    final logoError = _logoError;
    return Scaffold(
      backgroundColor: const Color(0xFF101020),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            AnimatedSwitcher(
              duration: const Duration(milliseconds: 350),
              transitionBuilder: (child, animation) =>
                  FadeTransition(opacity: animation, child: child),
              child: ScaleTransition(
                key: ValueKey(season),
                scale: _logoAnimationController,
                child: Image.asset(
                  season.splashLogoAsset,
                  width: 280,
                  height: 280,
                  fit: BoxFit.contain,
                  semanticLabel: 'TokTik',
                ),
              ),
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: 144,
              child: LinearProgressIndicator(
                minHeight: 3,
                color: season.primaryColor,
                backgroundColor: Colors.white24,
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Preparando tu feed',
              style: TextStyle(color: Colors.white70, fontSize: 12),
            ),
            if (audioError != null || logoError != null) ...[
              const SizedBox(height: 16),
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 24),
                child: Text(
                  logoError != null
                      ? 'No se pudo precargar el logo de temporada: $logoError'
                      : 'No se pudo reproducir el audio de introducción: '
                            '$audioError',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
