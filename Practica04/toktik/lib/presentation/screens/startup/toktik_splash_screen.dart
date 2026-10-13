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

class _TokTikSplashScreenState extends State<TokTikSplashScreen> {
  bool _showEffectiveLogo = false;
  Object? _audioError;
  Object? _logoError;
  bool _audioDisposed = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      unawaited(_prepareSplash());
    });
  }

  Future<void> _prepareSplash() async {
    final season = context.read<SeasonProvider>().season;
    try {
      await Future.wait([
        precacheImage(const AssetImage('assets/icons/normal.png'), context),
        precacheImage(AssetImage(season.splashLogoAsset), context),
      ]);
    } catch (exception) {
      _logoError = exception;
    }
    if (!mounted) return;
    (widget.removeNativeSplash ?? FlutterNativeSplash.remove)();
    setState(() => _showEffectiveLogo = true);
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
              child: Image.asset(
                _showEffectiveLogo
                    ? season.splashLogoAsset
                    : 'assets/icons/normal.png',
                key: ValueKey(_showEffectiveLogo ? season : Season.normal),
                width: 280,
                height: 280,
                fit: BoxFit.contain,
                semanticLabel: 'TokTik',
              ),
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
