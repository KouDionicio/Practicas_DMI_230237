import 'dart:async';

import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/season.dart';
import 'package:toktik/domain/repositories/app_preferences_repository.dart';

extension SeasonDetails on Season {
  String get label => switch (this) {
    Season.normal => 'Normal',
    Season.halloween => 'Halloween',
    Season.christmas => 'Navidad',
    Season.valentines => 'San Valentín',
  };

  String? get audioAsset => switch (this) {
    Season.normal => 'assets/audio/normal/dejcomin-deep-electronic-trap-music-beat-chill-mix-low-toned-dejcoart-437453.mp3',
    Season.halloween =>
      'assets/audio/halloween/soulfuljamtracks-halloween-ghosts-612354.mp3',
    Season.christmas => 'assets/audio/christmas/white_records-we-wish-you-a-merry-christmas-background-xmas-music-for-video-30-sec-256123.mp3',
    Season.valentines => 'assets/audio/valentines/universfield-emotional-piano-background-30s-244335.mp3',
  };

  String get fontFamily => switch (this) {
    Season.normal => 'Inter',
    Season.halloween => 'Creepster',
    Season.christmas => 'Pacifico',
    Season.valentines => 'Playfair Display',
  };

  Color get primaryColor => switch (this) {
    Season.normal => const Color(0xFFFE2C55),
    Season.halloween => const Color(0xFFFF8A00),
    Season.christmas => const Color(0xFF23A455),
    Season.valentines => const Color(0xFFFF5B87),
  };

  Color get backgroundColor => switch (this) {
    Season.normal => const Color(0xFF101010),
    Season.halloween => const Color(0xFF160D24),
    Season.christmas => const Color(0xFF071A12),
    Season.valentines => const Color(0xFF260F1A),
  };
}

class SeasonProvider extends ChangeNotifier with WidgetsBindingObserver {
  SeasonProvider(
    this._repository, {
    DateTime Function()? now,
    Future<void> Function(Season season)? onSeasonChanged,
  }) : _now = now ?? DateTime.now {
    _onSeasonChanged = onSeasonChanged;
    WidgetsBinding.instance.addObserver(this);
  }

  final AppPreferencesRepository _repository;
  final DateTime Function() _now;
  late final Future<void> Function(Season season)? _onSeasonChanged;
  SeasonMode mode = SeasonMode.automatic;
  Season manualSeason = Season.normal;
  bool isLoaded = false;
  Object? error;

  Season get season => mode == SeasonMode.automatic
      ? SeasonCalendar.forDate(_now())
      : manualSeason;

  Future<void> load() async {
    try {
      final values = await Future.wait([
        _repository.getSeasonMode(),
        _repository.getManualSeason(),
      ]);
      mode = values[0] == SeasonMode.manual.name
          ? SeasonMode.manual
          : SeasonMode.automatic;
      manualSeason = Season.values.firstWhere(
        (season) => season.name == values[1],
        orElse: () => Season.normal,
      );
      isLoaded = true;
      error = null;
      await _syncLauncherIcon();
      notifyListeners();
    } catch (exception) {
      error = exception;
      isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> setMode(SeasonMode value) async {
    final previousSeason = season;
    mode = value;
    notifyListeners();
    try {
      await _repository.saveSeasonMode(value.name);
      error = null;
      if (season != previousSeason) await _syncLauncherIcon();
    } catch (exception) {
      error = exception;
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> setManualSeason(Season value) async {
    final previousSeason = season;
    manualSeason = value;
    notifyListeners();
    try {
      await _repository.saveManualSeason(value.name);
      error = null;
      if (season != previousSeason) await _syncLauncherIcon();
    } catch (exception) {
      error = exception;
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed && mode == SeasonMode.automatic) {
      notifyListeners();
      unawaited(_syncLauncherIcon());
    }
  }

  Future<void> _syncLauncherIcon() async {
    try {
      await _onSeasonChanged?.call(season);
    } catch (exception) {
      error = exception;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
