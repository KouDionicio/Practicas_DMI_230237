# Práctica 04: TokTik

Aplicación Flutter de videos cortos verticales. Conserva los 13 videos locales
de `assets/videos/` y añade temas de temporada, secciones, favoritos y controles
de reproducción.

## Funcionalidades

- Feed vertical local en **Discover**, **For You** y **Favorites**. Discover
  conserva el orden local original; For You comparte la fuente local y prioriza
  publicaciones con más visualizaciones; Favorites consulta los IDs guardados.
- Un único reproductor activo: se inicializa al entrar en pantalla, se pausa
  durante interrupciones del sistema y se libera al salir del video o sección.
  Tocar el video pausa o reanuda el clip.
- El control de sonido está junto a las acciones del video. El estado se
  comparte entre páginas y secciones; los videos empiezan silenciados.
- Likes y modo/temporada manual persisten en `shared_preferences`. Los IDs de
  like son estables y se derivan de la ruta local del video.
- La descripción larga se expande en una zona desplazable y se puede contraer.
- Temas automáticos según la fecha local, o selección manual desde el icono de
  temporada: Halloween (1–31 oct.), Navidad (1 dic.–6 ene.), San Valentín
  (1–14 feb.) y Normal el resto del año.
- El selector muestra el icono **dentro de la aplicación**. No cambia el icono
  nativo de Android/iOS.

## Arquitectura y archivos

Se mantienen tres capas útiles para el alcance actual:

- `lib/presentation/`: pantalla, widgets de reproducción, `DiscoverProvider`,
  estado de likes, temporada y audio ambiental.
- `lib/domain/`: `VideoPost`, `ExternalVideo` y contratos de datasources y
  repositorios.
- `lib/infrastructure/`: datasource/modelo/mappers de videos locales,
  repositorio local y almacenamiento con `shared_preferences`.
- `lib/shared/data/local_video_posts.dart`: metadatos de las 13 publicaciones.
- `test/`: límites de calendario, persistencia, mappers y widgets.

Los tres feeds locales reutilizan el datasource y repositorio existentes. Los
proveedores externos tienen un contrato común y un mapper por proveedor; sus
datasources actuales permanecen explícitamente sin configurar.

## Assets y dependencias

`pubspec.yaml` registra directorios reales `assets/videos/`, `assets/icons/`,
`assets/audio/normal/`, `assets/audio/halloween/` y
`assets/audio/christmas/`, `assets/audio/valentines/`. También registra las fuentes Inter, Creepster,
Pacifico, Playfair Display y Nunito desde sus rutas y nombres exactos.

Hay iconos PNG para las cuatro temporadas y audio ambiental para las cuatro:
Normal, Halloween, Navidad y San Valentín.

Paquetes principales: `provider`, `video_player`, `shared_preferences`,
`audioplayers`, `animate_do`, `intl` y `cupertino_icons`.

## Proveedores externos: alcance y configuración pendiente

Las entidades, contratos, repositorio y mappers específicos de YouTube, Vimeo
y Dailymotion están preparados. La implementación conectada a la app devuelve
un error de configuración explícito: no hay claves, tokens, permisos ni
reproductores externos configurados. Los fallos de esos proveedores no afectan
al feed local. Los mappers se prueban con ejemplos de estructura JSON, no con
respuestas en vivo.

No se pasan URLs de plataforma a `video_player` ni se extraen/descargan streams:

- YouTube: `search.list` devuelve metadatos; la reproducción debe integrarse
  con [YouTube Data API `search.list`](https://developers.google.com/youtube/v3/docs/search/list) y
  con el [IFrame Player API](https://developers.google.com/youtube/iframe_api_reference)
  y respetar las [políticas de YouTube API](https://developers.google.com/youtube/terms/developer-policies).
- Vimeo: requiere acceso permitido a la [API de videos](https://developer.vimeo.com/api/reference/videos)
  y reproductor embebido, que se
  controla mediante el [Vimeo Player SDK](https://developer.vimeo.com/player/sdk).
- Dailymotion: su documentación ofrece [reproductores verticales](https://developers.dailymotion.com/docs/vertical-player).
  Las URLs directas de stream requieren el permiso/plan correspondiente; son
  efímeras y no deben guardarse ([documentación](https://developers.dailymotion.com/docs/generate-stream-urls)).

Para habilitar búsquedas y reproducción reales hay que implementar cada
datasource con sus permisos aprobados y una integración de player apropiada.
No incluir secretos en Dart, `--dart-define` ni en el APK: los valores que se
compilan dentro de Flutter se pueden extraer. Mantener secretos de servidor
(por ejemplo, secretos OAuth de Vimeo/Dailymotion) detrás de un backend propio;
restringir cualquier clave pública de YouTube a la aplicación/cuotas necesarias.
Estas integraciones no se validaron contra servicios externos.

## Ejecutar y probar

Desde `Practica04/toktik/`:

```sh
flutter pub get
flutter run
dart format lib test
flutter analyze
flutter test
```

En Windows, si `flutter pub get` termina con el mensaje de que los plugins
requieren symlinks, habilitar **Developer Mode** en la configuración del sistema
y volver a ejecutar el comando.

Pruebas de calendario cubren los dos extremos de Halloween, Navidad entre
diciembre y enero y San Valentín. Las pruebas de preferencias comprueban modo
por defecto, modo manual, likes persistentes y taps seguidos; las pruebas de
mappers incluyen datos locales y las tres plataformas. No se requieren
credenciales ni Internet para el feed local.

## Compilar APK y probar en Appetize.io

1. Instalar Android Studio y Android SDK, configurar `ANDROID_HOME` o el SDK en
   Flutter, instalar las herramientas de plataforma requeridas y aceptar las
   licencias con `flutter doctor --android-licenses`.
2. Desde esta carpeta, ejecutar:

   ```sh
   flutter pub get
   flutter build apk --debug
   ```

3. Verificar `build/app/outputs/flutter-apk/app-debug.apk` y cargar ese archivo
   en Appetize.io para una sesión de prueba Android.
4. Probar las cuatro temporadas desde el botón del icono. Para probar reglas
   automáticas, cambiar la fecha local del dispositivo y reanudar la app; para
   pruebas deterministas, usar el modo manual.
5. Comprobar mute/unmute al cambiar de video y sección, likes tras reiniciar,
   Favorites vacío/lleno y expandir/contraer descripciones.

La compilación de APK requiere Android SDK local; no basta con tener Flutter.

## Evidencia de la práctica

Capturas incluidas con la práctica original:

| Publicación | Evidencia |
|---|---|
| 1 | <img src="images/1.png" alt="Feed, publicación 1" width="160"> |
| 2 | <img src="images/2.png" alt="Feed, publicación 2" width="160"> |
| 3 | <img src="images/3.png" alt="Feed, publicación 3" width="160"> |
| 4 | <img src="images/4.png" alt="Feed, publicación 4" width="160"> |
| 5 | <img src="images/5.png" alt="Feed, publicación 5" width="160"> |
| 6 | <img src="images/6.png" alt="Feed, publicación 6" width="160"> |
| 7 | <img src="images/7.png" alt="Feed, publicación 7" width="160"> |
| 8 | <img src="images/8.png" alt="Feed, publicación 8" width="160"> |
| 9 | <img src="images/9.png" alt="Feed, publicación 9" width="160"> |
| 10 | <img src="images/10.png" alt="Feed, publicación 10" width="160"> |
| 11 | <img src="images/11.png" alt="Feed, publicación 11" width="160"> |
| 12 | <img src="images/12.png" alt="Feed, publicación 12" width="160"> |
| 13 | <img src="images/13.png" alt="Feed, publicación 13" width="160"> |
