/// Configuración regional de Cinemapedia.
///
/// Un país determina dos dimensiones independientes:
///  * **Idioma** ([languageCode] / [tmdbLanguage]): textos de la interfaz y
///    parámetro `language` de TMDB.
///  * **Región** ([code]): parámetro `region` de TMDB (cartelera, estrenos) y
///    país cuya clasificación por edad se consulta.
///
/// Este archivo es Dart puro (sin Flutter) para poder probarlo de forma aislada.
class AppRegion {
  /// Código ISO 3166-1 alfa-2 del país (parámetro `region` de TMDB).
  final String code;

  /// Bandera en emoji.
  final String flag;

  /// Código ISO 639-1 del idioma de la interfaz.
  final String languageCode;

  /// Nombre del idioma escrito en su propio idioma (no se traduce).
  final String nativeLanguageName;

  /// Sistema de clasificación cinematográfica del país, cuando existe uno
  /// reconocido. Solo es informativo: la clasificación real de cada película
  /// se obtiene de TMDB.
  final String? ratingSystem;

  /// Si el idioma se escribe de derecha a izquierda.
  final bool isRtl;

  const AppRegion({
    required this.code,
    required this.flag,
    required this.languageCode,
    required this.nativeLanguageName,
    this.ratingSystem,
    this.isRtl = false,
  });

  /// Valor del parámetro `language` de TMDB, por ejemplo `es-MX`.
  String get tmdbLanguage => '$languageCode-$code';

  @override
  bool operator ==(Object other) => other is AppRegion && other.code == code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'AppRegion($tmdbLanguage)';
}

abstract final class AppRegions {
  static const mexico = AppRegion(
    code: 'MX',
    flag: '🇲🇽',
    languageCode: 'es',
    nativeLanguageName: 'Español',
    ratingSystem: 'RTC',
  );

  static const unitedStates = AppRegion(
    code: 'US',
    flag: '🇺🇸',
    languageCode: 'en',
    nativeLanguageName: 'English',
    ratingSystem: 'MPA',
  );

  static const germany = AppRegion(
    code: 'DE',
    flag: '🇩🇪',
    languageCode: 'de',
    nativeLanguageName: 'Deutsch',
    ratingSystem: 'FSK',
  );

  static const france = AppRegion(
    code: 'FR',
    flag: '🇫🇷',
    languageCode: 'fr',
    nativeLanguageName: 'Français',
    ratingSystem: 'CNC',
  );

  static const southKorea = AppRegion(
    code: 'KR',
    flag: '🇰🇷',
    languageCode: 'ko',
    nativeLanguageName: '한국어',
    ratingSystem: 'KMRB',
  );

  static const japan = AppRegion(
    code: 'JP',
    flag: '🇯🇵',
    languageCode: 'ja',
    nativeLanguageName: '日本語',
    ratingSystem: 'Eirin',
  );

  static const brazil = AppRegion(
    code: 'BR',
    flag: '🇧🇷',
    languageCode: 'pt',
    nativeLanguageName: 'Português',
    ratingSystem: 'ClassInd',
  );

  /// Egipto no tiene un sistema de clasificación estandarizado en TMDB, por
  /// eso [AppRegion.ratingSystem] queda vacío en lugar de inventar uno.
  static const egypt = AppRegion(
    code: 'EG',
    flag: '🇪🇬',
    languageCode: 'ar',
    nativeLanguageName: 'العربية',
    isRtl: true,
  );

  /// Orden en el que se muestran en la pantalla de configuración.
  static const all = <AppRegion>[
    mexico,
    unitedStates,
    germany,
    france,
    southKorea,
    japan,
    brazil,
    egypt,
  ];

  static const fallback = mexico;

  static AppRegion? fromCode(String? code) {
    if (code == null) return null;
    final normalized = code.toUpperCase();
    for (final region in all) {
      if (region.code == normalized) return region;
    }
    return null;
  }

  /// Región inicial la primera vez que se abre la app: primero coincide el
  /// país del dispositivo, después el idioma y, si nada coincide, México.
  static AppRegion resolveDeviceRegion(
    Iterable<({String languageCode, String? countryCode})> deviceLocales,
  ) {
    for (final locale in deviceLocales) {
      final byCountry = fromCode(locale.countryCode);
      if (byCountry != null && byCountry.languageCode == locale.languageCode) {
        return byCountry;
      }
    }
    for (final locale in deviceLocales) {
      for (final region in all) {
        if (region.languageCode == locale.languageCode) return region;
      }
    }
    return fallback;
  }
}
