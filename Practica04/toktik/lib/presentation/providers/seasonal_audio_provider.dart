import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/widgets.dart';
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
    isEnabled = !isEnabled;
    if (isAudible && _isForeground) {
      await _playCurrentSeason();
    } else {
      await _player.stop();
    }
    notifyListeners();
  }

  Future<void> setVideoHasSound(bool value) async {
    if (_videoHasSound == value) return;
    _videoHasSound = value;
    if (isAudible && _isForeground) {
      await _playCurrentSeason();
    } else {
      await _player.stop();
    }
    notifyListeners();
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
        await _player.pause();
      } else if (isAudible) {
        await _playCurrentSeason();
      }
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
