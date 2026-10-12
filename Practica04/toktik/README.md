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
proveedores externos tienen un contrato común, un datasource y un mapper por
proveedor.

## Assets y dependencias

`pubspec.yaml` registra directorios reales `assets/videos/`, `assets/icons/`,
`assets/audio/normal/`, `assets/audio/halloween/` y
`assets/audio/christmas/`, `assets/audio/valentines/`. También registra las fuentes Inter, Creepster,
Pacifico, Playfair Display y Nunito desde sus rutas y nombres exactos.

Hay iconos PNG para las cuatro temporadas y audio ambiental para las cuatro:
Normal, Halloween, Navidad y San Valentín.

Paquetes principales: `provider`, `video_player`, `webview_flutter`, `web`,
`http`, `shared_preferences`, `audioplayers`, `animate_do`, `intl` y
`cupertino_icons`. `video_player` sigue reproduciendo exclusivamente los assets
locales. Los videos externos usan un iframe HTML validado en Flutter Web y
`webview_flutter` en Android e iOS.

## Proveedores externos: integración, credenciales y reproducción

Desde el botón de búsqueda externo se pueden elegir YouTube, Vimeo o
PeerTube. Cada fuente usa su datasource HTTP, mapper y repositorio común.
Los fallos de configuración, autorización, HTTP o respuesta inválida se
muestran en pantalla; no ocultan ni reemplazan el feed local.

| Proveedor | Consulta de metadatos | Reproducción (WebView Android/iOS; iframe Chrome) | Configuración |
|---|---|---|---|
| YouTube | YouTube Data API v3 `search.list`, solo videos | IFrame Player oficial en WebView | `YOUTUBE_API_KEY`; requiere habilitar la API y restringir la clave |
| Vimeo | API de videos `GET /videos`, con Bearer token desde `Practica04/vimeo_backend` | Vimeo Player oficial en WebView | `VIMEO_ACCESS_TOKEN` solo en el entorno del backend y `VIMEO_BACKEND_URL` en Flutter |
| PeerTube | API pública `GET /api/v1/search/videos?search=...&count=25&sort=-views` | Embed oficial `/videos/embed/{uuid}`, iframe en Chrome y WebView en Android/iOS | `PEERTUBE_INSTANCE_URL`, opcional; predeterminado `https://peertube.cpy.re` |

La columna WebView de la tabla describe Android e iOS; en Chrome las tres
integraciones usan el `embedUrl` oficial de cada proveedor en un iframe HTML.

### Arquitectura, búsqueda y reproducción

`ExternalVideoDatasource` define la búsqueda; los datasources de YouTube,
Vimeo y PeerTube consultan sus APIs y los modelos de infraestructura mapean
metadatos a `ExternalVideo`. `ExternalVideoRepositoryImpl` selecciona el
datasource por `VideoSource`, y `ExternalVideoSearchProvider` alimenta la
pantalla de videos externos abierta desde Discover. Al tocar un resultado, se
abre el reproductor oficial verificado del proveedor.

La búsqueda PeerTube usa la consulta de texto, pide hasta 25 resultados por
defecto y ordena por visualizaciones (`sort=-views`). El datasource limita
`count` a 1–100, codifica la consulta como parámetro URI y descarta UUIDs
duplicados. No necesita una API key para este endpoint público. Puedes cambiar
la instancia con `--dart-define=PEERTUBE_INSTANCE_URL=https://tu-instancia`,
sin incluir rutas de API, query, fragmentos ni credenciales; debe ser HTTPS.
El valor por defecto es `https://peertube.cpy.re`.

Los resultados externos conservan su propio modelo `ExternalVideo`; no se
convierten a `VideoPost`, que pertenece al feed local y a `video_player`.
PeerTube, como YouTube y Vimeo, reproduce la página oficial de embed, no la
página HTML ni una supuesta URL MP4. Chrome usa un iframe y Android/iOS usan
`webview_flutter`; la disponibilidad depende de que la instancia permita
incrustar el video y servir sus recursos. La instancia pública puede aplicar
límite de solicitudes, cambiar disponibilidad o configuración CORS y no
garantiza permanencia ni reproducción de todos los videos.

### Configurar metadatos

1. En [Google Cloud Console](https://console.cloud.google.com/), crea o elige un
   proyecto, habilita **YouTube Data API v3** y crea una API key. Restringe la
   clave a la API y a las aplicaciones/cuotas previstas para el despliegue.
   La clave de API que se compile en Flutter es extraíble: no es un secreto y
   no debe tener permisos amplios.
2. PeerTube no necesita credenciales para la búsqueda pública. Si deseas usar
   otra instancia, configura `PEERTUBE_INSTANCE_URL` con su URL HTTPS.
3. Ejecuta desde `Practica04/toktik/` (reemplaza los valores localmente, sin
   guardarlos en Git):

   ```sh
   flutter run --dart-define=YOUTUBE_API_KEY=TU_API_KEY_RESTRINGIDA --dart-define=PEERTUBE_INSTANCE_URL=https://peertube.cpy.re
   ```

4. En Discover, abre el botón de búsqueda externa, selecciona PeerTube,
   escribe una consulta y toca un resultado.

Vimeo requiere una aplicación registrada en
[Vimeo Developer](https://developer.vimeo.com/), permisos de lectura aprobados
y un access token con el alcance mínimo permitido por la cuenta (por ejemplo,
`public` para buscar videos públicos). El backend independiente de
`Practica04/vimeo_backend` lee el token solo de `process.env.VIMEO_ACCESS_TOKEN`
y hace proxy de `GET /videos`; Flutter llama a `/api/vimeo/search` y nunca
recibe ni envía el token de Vimeo.

#### Ejecutar Vimeo localmente

1. En Vimeo Developer crea/selecciona una aplicación, habilita el acceso de
   lectura correspondiente y genera un Personal Access Token. No compartas el
   token en el chat ni lo pongas en un comando, código o archivo versionado.
2. Configura `VIMEO_ACCESS_TOKEN` en el entorno del proceso/servicio del
   backend, no en Flutter. En desarrollo local de Windows, puedes agregar esa
   variable mediante **Editar las variables de entorno de la cuenta** y luego
   reiniciar VS Code para que su terminal la herede. En despliegue, usa el
   almacén de secretos del proveedor de hosting. No la guardes en archivos,
   comandos, `package.json`, `launch.json` ni el repositorio.
3. Desde `Practica04/vimeo_backend/`, inicia el backend:

   ```sh
   npm start
   ```

   En otra terminal ejecuta las pruebas:

   ```sh
   npm test
   ```

   `/health` debe responder `{"status":"ok"}`. El backend escucha en el puerto
   8787 y por defecto solo en `127.0.0.1`. Para que Android Emulator acceda al
   host, establece además `HOST=0.0.0.0` en el entorno del backend; el manifest
   de cleartext está limitado al build Android debug.
   No expongas ese endpoint de desarrollo a Internet.
   En producción, define `CORS_ALLOWED_ORIGINS` como una lista separada por
   comas de orígenes HTTPS exactos autorizados. Los orígenes HTTP locales solo
   se aceptan fuera de `NODE_ENV=production`; CORS no sustituye autenticación
   ni límites de uso. Configura `HOST` según la plataforma de despliegue y
   limita el acceso de red; `0.0.0.0` puede ser necesario dentro de un
   contenedor, pero no debe usarse para exponer el backend local a Internet.
4. El URL local predeterminado de Flutter es `http://10.0.2.2:8787` en Android
   Emulator, `http://localhost:8787` en web, iOS Simulator y escritorio. Un
   dispositivo físico necesita una URL que pueda alcanzar: configura
   `VIMEO_BACKEND_URL` con una URL HTTPS del backend (recomendado) o una IP
   accesible en una red de desarrollo confiable. Para apuntar Flutter a ese
   backend:

   ```sh
   flutter run --dart-define=VIMEO_BACKEND_URL=https://tu-host-de-desarrollo
   ```

   No pongas una URL HTTP remota en builds release: Flutter permite HTTP solo
   en debug y las políticas de plataforma restringen el tráfico sin cifrar.
5. En Videos externos elige Vimeo y busca. El token no aparece en respuestas
   de error ni se registra. El backend reduce la respuesta de Vimeo a los
   campos que consume el mapper.

El backend de muestra no implementa autenticación de usuario ni despliegue
productivo. Mantén el servicio local; antes de publicarlo, protégelo con una
pasarela de autenticación/rate-limit y HTTPS, limita el uso de Vimeo y no
confíes en CORS como control de acceso. La URL puede ir en
`--dart-define=VIMEO_BACKEND_URL=...`; **el token nunca**. En Vimeo revisa
[API authentication](https://developer.vimeo.com/api/authentication).

La pantalla de reproducción solo navega a HTTPS y a los hosts/rutas oficiales
de embed (`youtube.com/embed`, `player.vimeo.com/video` y
`{instancia}/videos/embed/{UUID}`). No se envían páginas web de proveedor a
`video_player`, ni se extraen o descargan streams. Se aplican los controles,
restricciones, disponibilidad regional, anuncios y permisos definidos por cada
servicio. Chrome inserta el embed HTTPS oficial del proveedor en un iframe
HTML y ofrece un enlace alternativo a la página del video si el proveedor
bloquea la inserción. Android e iOS conservan `webview_flutter` y muestran un
botón para abrir la página original del proveedor.

Referencias oficiales: [YouTube search.list](https://developers.google.com/youtube/v3/docs/search/list),
[YouTube IFrame API](https://developers.google.com/youtube/iframe_api_reference),
[políticas de YouTube API](https://developers.google.com/youtube/terms/developer-policies),
[Vimeo API](https://developer.vimeo.com/api/reference/videos),
[Vimeo Player SDK](https://developer.vimeo.com/player/sdk),
[PeerTube REST API: búsqueda de videos](https://docs.joinpeertube.org/api-rest-reference.html#tag/Videos/operation/getApiV1SearchVideos),
y [inserción de videos PeerTube](https://docs.joinpeertube.org/use-embed).

## Ejecutar y probar

Desde `Practica04/toktik/`:

```sh
flutter pub get
flutter run
dart format lib test
flutter analyze
flutter test
flutter test --platform chrome test/external_video_player_test.dart
```
El test de Chrome comprueba que el reproductor inserta un `HtmlElementView`
sin inicializar `webview_flutter`; ejecútalo con Chrome instalado.

En Windows, si `flutter pub get` termina con el mensaje de que los plugins
requieren symlinks, habilitar **Developer Mode** en la configuración del sistema
y volver a ejecutar el comando.

Las pruebas de `test/external_video_datasources_test.dart` usan HTTP simulado
para respuestas válidas, errores HTTP/autenticación, respuestas incompletas y
enrutamiento del repositorio; no contactan servicios reales. Las pruebas de
`test/domain_and_state_test.dart` cubren mappers, calendario y persistencia.
No se requieren credenciales ni Internet para el feed local. Las consultas
reales requieren la configuración indicada arriba; no se han ejecutado APIs
reales ni se afirma validada la reproducción en dispositivo.

Validación de esta entrega: `flutter analyze` terminó sin problemas y
`flutter test --reporter compact` pasó con 26 pruebas. También se ejecuta
`npm test` en `Practica04/vimeo_backend/` para verificar salud, consulta,
credencial ausente, entrada inválida, errores de autorización y respuesta
malformada sin llamar a Vimeo real. `dart format` se ejecuta sobre los Dart
modificados. En Windows, Flutter puede mostrar el aviso de soporte de symlinks
al resolver plugins; si ocurre, habilita **Developer Mode** y vuelve a correr
`flutter pub get`. Una prueba de proxy/backend simulada no equivale a validar
el token, la cuota ni la reproducción Vimeo real; estos necesitan credencial
válida y dispositivo/emulador.

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
