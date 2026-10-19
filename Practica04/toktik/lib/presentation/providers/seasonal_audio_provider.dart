import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
import 'package:toktik/domain/entities/season.dart';
import 'package:toktik/presentation/providers/season_provider.dart';

class SeasonalAudioProvider extends ChangeNotifier with WidgetsBindingObserver {
  SeasonalAudioProvider(this._season) {
    WidgetsBinding.instance.addObserver(this);
  }

  final AudioPlayer _player = AudioPlayer();
  Season _season;
  bool isEnabled = false;
  bool _isForeground = true;
  bool _videoHasSound = false;
  bool _resumeAfterBackground = false;
  Object? error;

  bool get hasAudio => _season.audioAsset != null;
  bool get isAudible => isEnabled && hasAudio && !_videoHasSound;

  Future<void> setSeason(Season season) async {
    if (_season == season) return;
    _season = season;
    try {
      await _player.stop();
      if (isAudible && _isForeground) {
        await _playCurrentSeason();
      }
      error = null;
    } catch (exception) {
      error = exception;
    }
    notifyListeners();
  }

  Future<void> toggleEnabled() async {
    final wasEnabled = isEnabled;
    isEnabled = !wasEnabled;
    try {
      await _syncAudio();
      error = null;
    } catch (exception) {
      isEnabled = wasEnabled;
      error = exception;
      notifyListeners();
      rethrow;
    }
    notifyListeners();
  }

  Future<void> setVideoHasSound(bool value) async {
    if (_videoHasSound == value) return;
    final previousValue = _videoHasSound;
    _videoHasSound = value;
    try {
      await _syncAudio();
      error = null;
    } catch (exception) {
      _videoHasSound = previousValue;
      error = exception;
      notifyListeners();
      rethrow;
    }
    notifyListeners();
  }

  Future<void> _syncAudio() async {
    if (isAudible && _isForeground) {
      _resumeAfterBackground = false;
      await _playCurrentSeason();
    } else {
      _resumeAfterBackground = false;
      await _player.stop();
    }
  }

  Future<void> _playCurrentSeason() async {
    final asset = _season.audioAsset;
    if (asset == null) return;
    await _player.setReleaseMode(ReleaseMode.loop);
    await _player.setVolume(0.18);
    await _player.play(AssetSource(asset.replaceFirst('assets/', '')));
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    _isForeground = state == AppLifecycleState.resumed;
    unawaited(_syncLifecycleAudio());
  }

  Future<void> _syncLifecycleAudio() async {
    try {
      if (!_isForeground) {
        _resumeAfterBackground = isAudible;
        await _player.pause();
      } else if (_resumeAfterBackground && isAudible) {
        _resumeAfterBackground = false;
        await _player.resume();
      } else if (isAudible) {
        await _playCurrentSeason();
      }
      error = null;
    } catch (exception) {
      error = exception;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    unawaited(_player.dispose());
    super.dispose();
  }
}
