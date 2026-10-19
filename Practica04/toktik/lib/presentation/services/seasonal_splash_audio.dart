import 'package:audioplayers/audioplayers.dart';
import 'package:toktik/domain/entities/season.dart';
import 'package:toktik/presentation/providers/season_provider.dart';

abstract interface class StartupAudio {
  Object? get error;

  Future<void> setSeason(Season season);

  Future<void> preload();

  Future<void> playFor(Duration duration);

  Future<void> dispose();
}

class SeasonalSplashAudio implements StartupAudio {
  SeasonalSplashAudio(this._season, {AudioPlayer? player})
    : _player = player ?? AudioPlayer();

  static const _volume = 0.18;
  static const _fadeDuration = Duration(milliseconds: 400);
  static const _fadeSteps = 8;

  Season _season;
  final AudioPlayer _player;
  Object? _error;
  bool _isDisposed = false;
  bool _isPlaying = false;

  @override
  Object? get error => _error;

  @override
  Future<void> setSeason(Season season) async {
    if (_season == season || _isDisposed) return;
    _season = season;
    final asset = season.audioAsset;
    if (asset == null) {
      _error = StateError('The selected season has no splash audio asset.');
      return;
    }

    try {
      await _player.stop();
      await _player.setSource(AssetSource(asset.replaceFirst('assets/', '')));
      await _player.setVolume(_volume);
      if (_isPlaying) await _player.resume();
      _error = null;
    } catch (exception) {
      _error = exception;
      rethrow;
    }
  }

  @override
  Future<void> preload() async {
    final asset = _season.audioAsset;
    if (asset == null) {
      _error = StateError('The selected season has no splash audio asset.');
      return;
    }

    try {
      await _player.setReleaseMode(ReleaseMode.stop);
      await _player.setVolume(_volume);
      await _player.setSource(AssetSource(asset.replaceFirst('assets/', '')));
    } catch (exception) {
      _error = exception;
    }
  }

  @override
  Future<void> playFor(Duration duration) async {
    final stopwatch = Stopwatch()..start();
    try {
      if (_error == null && !_isDisposed) {
        _isPlaying = true;
        final fadeDuration = duration < _fadeDuration
            ? duration
            : _fadeDuration;
        final playbackDuration = duration - fadeDuration;
        await _player.resume();
        if (playbackDuration > Duration.zero) {
          await Future<void>.delayed(playbackDuration);
        }

        final stepDuration = Duration(
          microseconds: fadeDuration.inMicroseconds ~/ _fadeSteps,
        );
        for (var step = 1; step <= _fadeSteps; step++) {
          if (_isDisposed) return;
          await _player.setVolume(_volume * (1 - step / _fadeSteps));
          if (stepDuration > Duration.zero) {
            await Future<void>.delayed(stepDuration);
          }
        }
        await _player.stop();
        _isPlaying = false;
      }
    } catch (exception) {
      _error = exception;
      _isPlaying = false;
    } finally {
      final remaining = duration - stopwatch.elapsed;
      if (remaining > Duration.zero && !_isDisposed) {
        await Future<void>.delayed(remaining);
      }
    }
  }

  @override
  Future<void> dispose() async {
    if (_isDisposed) return;
    _isDisposed = true;
    _isPlaying = false;
    await _player.dispose();
  }
}
