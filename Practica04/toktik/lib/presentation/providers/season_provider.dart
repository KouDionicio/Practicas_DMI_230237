import 'package:flutter/material.dart';
import 'package:toktik/domain/repositories/app_preferences_repository.dart';

enum SeasonMode { automatic, manual }

enum Season { normal, halloween, christmas, valentines }

extension SeasonDetails on Season {
  String get label => switch (this) {
    Season.normal => 'Normal',
    Season.halloween => 'Halloween',
    Season.christmas => 'Navidad',
    Season.valentines => 'San Valentín',
  };

  String get iconAsset => switch (this) {
    Season.normal => 'assets/icons/normal.png',
    Season.halloween => 'assets/icons/halloween.png',
    Season.christmas => 'assets/icons/navidad.png',
    Season.valentines => 'assets/icons/san_valentin.png',
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

  static Season forDate(DateTime date) {
    final day = date.day;
    final month = date.month;
    if (month == DateTime.october && day >= 1 && day <= 31) {
      return Season.halloween;
    }
    if (month == DateTime.december || (month == DateTime.january && day <= 6)) {
      return Season.christmas;
    }
    if (month == DateTime.february && day >= 1 && day <= 14) {
      return Season.valentines;
    }
    return Season.normal;
  }
}

class SeasonProvider extends ChangeNotifier with WidgetsBindingObserver {
  SeasonProvider(this._repository, {DateTime Function()? now})
    : _now = now ?? DateTime.now {
    WidgetsBinding.instance.addObserver(this);
  }

  final AppPreferencesRepository _repository;
  final DateTime Function() _now;
  SeasonMode mode = SeasonMode.automatic;
  Season manualSeason = Season.normal;
  bool isLoaded = false;
  Object? error;

  Season get season => mode == SeasonMode.automatic
      ? SeasonDetails.forDate(_now())
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
      notifyListeners();
    } catch (exception) {
      error = exception;
      isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> setMode(SeasonMode value) async {
    mode = value;
    notifyListeners();
    try {
      await _repository.saveSeasonMode(value.name);
      error = null;
    } catch (exception) {
      error = exception;
      rethrow;
    } finally {
      notifyListeners();
    }
  }

  Future<void> setManualSeason(Season value) async {
    manualSeason = value;
    notifyListeners();
    try {
      await _repository.saveManualSeason(value.name);
      error = null;
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
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
