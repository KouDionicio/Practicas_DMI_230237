import 'dart:ui' show PlatformDispatcher;

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cinemapedia/config/constants/app_regions.dart';

/// Instancia de [SharedPreferences] cargada en `main()` antes del primer frame,
/// para que la app arranque directamente en el idioma guardado.
final sharedPreferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError(
    'sharedPreferencesProvider debe sobrescribirse en ProviderScope (ver main.dart).',
  );
});

/// Fuente única de verdad de la región / idioma de toda la aplicación.
///
/// La interfaz (MaterialApp.locale), las peticiones a TMDB (`language` y
/// `region`) y las clasificaciones dependen de este provider: al cambiarlo,
/// todo lo que lo observa se reconstruye sin reiniciar la app.
final appRegionProvider =
    NotifierProvider<AppRegionNotifier, AppRegion>(AppRegionNotifier.new);

class AppRegionNotifier extends Notifier<AppRegion> {
  static const storageKey = 'cinemapedia.region';

  @override
  AppRegion build() {
    final prefs = ref.watch(sharedPreferencesProvider);
    final saved = AppRegions.fromCode(prefs.getString(storageKey));
    if (saved != null) return saved;

    final deviceLocales = PlatformDispatcher.instance.locales.map(
      (locale) => (languageCode: locale.languageCode, countryCode: locale.countryCode),
    );
    return AppRegions.resolveDeviceRegion(deviceLocales);
  }

  /// Selecciona una región y la guarda para futuras sesiones.
  Future<void> select(AppRegion region) async {
    if (region == state) return;
    state = region;
    await ref.read(sharedPreferencesProvider).setString(storageKey, region.code);
  }
}
