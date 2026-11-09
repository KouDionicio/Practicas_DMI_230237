# Cinemapedia: cambios de esta versión

## Cómo ejecutar

1. Copia el contenido de este ZIP sobre la raíz de tu proyecto (sustituye `lib/`, `android/`, `pubspec.yaml`; añade `assets/`, `test/` y `l10n.yaml`).
2. Asegúrate de que existe `.env` en la raíz con `THE_MOVIEDB_KEY=tu_api_key_de_tmdb`.
3. Ejecuta:

```
flutter clean
flutter pub get        # también regenera lib/l10n/app_localizations*.dart desde los .arb
flutter analyze
flutter test
flutter run            # o: flutter build apk --release
```

4. Para ver el icono nuevo en el teléfono, **desinstala primero la versión anterior**: algunos launchers guardan en caché el icono viejo.

Si tu carpeta `test/` contiene el `widget_test.dart` de la plantilla de Flutter (el del contador con `MyApp`), bórralo: no corresponde a esta app y no compila.

## Errores existentes corregidos

| Problema | Corrección |
|---|---|
| `config/router/app_router.dart` contenía una copia de `AppTheme`; `appRouter` no existía (el proyecto no compilaba) | Router real con splash, inicio, detalle y configuración |
| Imports a `infrastructure/datasources/` (la carpeta es `datasource/`) | Rutas corregidas |
| Riverpod 3 movió `StateNotifierProvider`/`StateProvider` a `legacy.dart` | Imports actualizados |
| `sublist(0, 6)` fallaba con menos de 6 películas | `take(10)` |
| `MovieDetails.fromJson` fallaba con campos nulos (`imdb_id`, `homepage`, `tagline`, fecha vacía…) | Modelos tolerantes a nulos |
| El filtro de películas sin póster comparaba con `'no-poster'` y nunca filtraba | Filtra pósters vacíos |
| Sin red, el cargador giraba para siempre | Errores traducidos con botón «Reintentar» |
| Uso de notifiers tras `dispose` al cambiar de país en mitad de una petición | Guardas `mounted` |
| El buscador podía añadir eventos a streams cerrados | Temporizador cancelado y comprobación `isClosed` |
| `AndroidManifest.xml` principal sin permiso `INTERNET` (el APK release no podía conectar) | Permiso añadido |
| Subtítulo fijo «Lunes 20» | Fecha real del día, localizada |
| `intl: ^0.20.3` choca con `flutter_localizations` de Flutter 3.35 (fija 0.20.2) | `intl: ^0.20.2` (admite 0.20.3+) |

## Internacionalización

- Fuente de verdad: `lib/l10n/app_*.arb` (80 textos × 8 idiomas). Plantilla: `app_es.arb`.
- Para añadir o cambiar un texto, edita los 8 `.arb` y ejecuta `flutter gen-l10n` (o compila).
- `MaterialApp.router` recibe `locale` desde `appRegionProvider`: todo cambia sin reiniciar, incluidos los textos internos de Material. El árabe activa RTL automáticamente.
- Fuentes: Android incluye Noto CJK y Noto Arabic. El widget `Text` pasa el locale al motor de texto, así que los kanji japoneses usan glifos japoneses y no chinos. No hizo falta empaquetar fuentes.

## Región y TMDB

| País | `language` | `region` | Sistema |
|---|---|---|---|
| México | es-MX | MX | RTC |
| Estados Unidos | en-US | US | MPA |
| Alemania | de-DE | DE | FSK |
| Francia | fr-FR | FR | CNC |
| Corea del Sur | ko-KR | KR | KMRB |
| Japón | ja-JP | JP | Eirin |
| Brasil | pt-BR | BR | ClassInd |
| Egipto | ar-EG | EG | (no se inventa) |

- `language` se envía en todas las peticiones; `region` en `now_playing`, `popular`, `top_rated`, `upcoming` y `search/movie`.
- Clasificaciones: `GET /movie/{id}/release_dates`. Solo se usa el país seleccionado, priorizando el estreno en cines. Si no hay dato, se muestra «Clasificación no disponible», traducido.
- La preferencia se guarda con SharedPreferences (`cinemapedia.region`) y se lee antes del primer frame.

## Icono de Android

Generado desde `icono.jfif`:

- `mipmap-*/ic_launcher.png` y `ic_launcher_round.png`
- Adaptativo: `mipmap-anydpi-v26/*.xml` con fondo `#0A0D12`, capa frontal y capa monocroma para iconos temáticos de Android 13+
- Splash nativo: `launch_background.xml` (antes de Android 12) y `values-v31/styles.xml` (API SplashScreen)
- Assets de Flutter: `assets/icono/icono.png` y `assets/icono/icono_marca.png`
