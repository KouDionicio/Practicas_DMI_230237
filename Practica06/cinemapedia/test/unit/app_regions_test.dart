import 'package:flutter_test/flutter_test.dart';
import 'package:cinemapedia/config/constants/app_regions.dart';

void main() {
  group('AppRegions', () {
    test('contiene exactamente los 8 países solicitados en orden', () {
      expect(AppRegions.all.map((r) => r.code).toList(),
          equals(['MX', 'US', 'DE', 'FR', 'KR', 'JP', 'BR', 'EG']));
    });

    test('cada país usa su propio idioma y código TMDB', () {
      final tags = {for (final r in AppRegions.all) r.code: r.tmdbLanguage};
      expect(tags, equals({
        'MX': 'es-MX', 'US': 'en-US', 'DE': 'de-DE', 'FR': 'fr-FR',
        'KR': 'ko-KR', 'JP': 'ja-JP', 'BR': 'pt-BR', 'EG': 'ar-EG',
      }));
    });

    test('nombres de idioma nativos', () {
      expect(AppRegions.all.map((r) => r.nativeLanguageName).toList(), equals([
        'Español', 'English', 'Deutsch', 'Français', '한국어', '日本語', 'Português', 'العربية',
      ]));
    });

    test('solo el árabe es RTL', () {
      expect(AppRegions.all.where((r) => r.isRtl).map((r) => r.code).toList(), equals(['EG']));
    });

    test('Egipto no tiene sistema de clasificación inventado', () {
      expect(AppRegions.egypt.ratingSystem, isNull);
    });

    test('fromCode es tolerante a minúsculas y rechaza códigos desconocidos', () {
      expect(AppRegions.fromCode('jp'), equals(AppRegions.japan));
      expect(AppRegions.fromCode('ES'), isNull);
      expect(AppRegions.fromCode(null), isNull);
    });

    test('región inicial según el dispositivo', () {
      expect(AppRegions.resolveDeviceRegion([(languageCode: 'ko', countryCode: 'KR')]),
          equals(AppRegions.southKorea));
      // Español de España: no hay región ES, pero sí idioma español.
      expect(AppRegions.resolveDeviceRegion([(languageCode: 'es', countryCode: 'ES')]),
          equals(AppRegions.mexico));
      // Inglés de Australia → idioma inglés (Estados Unidos).
      expect(AppRegions.resolveDeviceRegion([(languageCode: 'en', countryCode: 'AU')]),
          equals(AppRegions.unitedStates));
      expect(AppRegions.resolveDeviceRegion([(languageCode: 'it', countryCode: 'IT')]),
          equals(AppRegions.fallback));
    });
  });
}
