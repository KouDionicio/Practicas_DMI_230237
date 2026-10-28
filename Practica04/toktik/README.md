# Práctica 04: TokTik

<div align="center">
  <table>
    <tr>
      <td align="center" valign="middle">
        <img src="../../LOGOS/LOGO%20UTXJ%20PNG.png" alt="Logotipo de la UTXJ" height="90">
      </td>
      <td align="center" valign="middle">
        <img src="../../LOGOS/LOGO%20TIC%20(4).png" alt="Logotipo de Tecnologías de la Información y Comunicación" height="90">
      </td>
    </tr>
  </table>

  ### Desarrollo Móvil Integral

  **Aplicación móvil de videos verticales con Flutter**

  [![Flutter](https://img.shields.io/badge/Flutter-Framework-02569B?logo=flutter&logoColor=white)](https://flutter.dev/)
  [![Dart](https://img.shields.io/badge/Dart-Lenguaje-0175C2?logo=dart&logoColor=white)](https://dart.dev/)
  [![Android](https://img.shields.io/badge/Android-Plataforma-3DDC84?logo=android&logoColor=white)](https://developer.android.com/)
  [![YouTube](https://img.shields.io/badge/YouTube-API-FF0000?logo=youtube&logoColor=white)](https://developers.google.com/youtube/v3)
  [![Vimeo](https://img.shields.io/badge/Vimeo-Video-1AB7EA?logo=vimeo&logoColor=white)](https://developer.vimeo.com/)
  [![GitHub](https://img.shields.io/badge/GitHub-Código%20fuente-181717?logo=github&logoColor=white)](https://github.com/)

  **[Ver repositorio en GitHub](https://github.com/KouDionicio/Practicas_DMI_230237)**

  **[Probar TokTik en Appetize](https://appetize.io/app/b_yw4zidsh4wkzeww7mkpnrzsxki)**

  **[Ver diagramas de arquitectura](https://koudionicio.github.io/Practicas_DMI_230237/practica04/toktik/)**
</div>

---

## Descripción

TokTik es una aplicación desarrollada con Flutter y Dart que reproduce videos en formato vertical mediante una experiencia de navegación inspirada en las plataformas de videos cortos.

Integra videos locales y contenido remoto de YouTube, Vimeo y PeerTube. Su arquitectura sigue el enfoque **Clean Architecture**, separando la presentación, las reglas de negocio y el acceso a datos.

La interfaz también incorpora temas por temporada, reproducción de video, favoritos persistentes, controles de sonido y una experiencia visual adaptable.

## Objetivo

Desarrollar una aplicación móvil que integre reproducción multimedia, consumo de servicios externos, administración del estado y persistencia local, aplicando principios de arquitectura limpia y buenas prácticas de desarrollo con Flutter.

## Tecnologías utilizadas

| Tecnología | Icono | Aplicación |
|---|---|---|
| **Flutter** | <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/flutter/flutter-original.svg" width="28" alt="Flutter"> | Construcción de interfaces móviles. |
| **Dart** | <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/dart/dart-original.svg" width="28" alt="Dart"> | Lenguaje de programación. |
| **Android** | <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/android/android-original.svg" width="28" alt="Android"> | Plataforma de ejecución y pruebas. |
| **YouTube Data API** | <img src="https://cdn.simpleicons.org/youtube/FF0000" width="28" alt="YouTube"> | Búsqueda y consulta de videos. |
| **Vimeo** | <img src="https://cdn.simpleicons.org/vimeo/1AB7EA" width="28" alt="Vimeo"> | Integración con videos y reproductor oficial. |
| **PeerTube** | <img src="https://cdn.simpleicons.org/peertube/F1680D" width="28" alt="PeerTube"> | Consulta de contenido desde instancias compatibles. |
| **Shared Preferences** | <img src="https://cdn.simpleicons.org/flutter/02569B" width="28" alt="Persistencia local"> | Persistencia local de preferencias y favoritos. |
| **Git y GitHub** | <img src="https://cdn.jsdelivr.net/gh/devicons/devicon/icons/github/github-original.svg" width="28" alt="GitHub"> | Control de versiones y alojamiento del código. |

## Funcionalidades

- **For You:** feed vertical de videos locales desde `assets/videos/`.
- **Discover:** contenido remoto de YouTube, Vimeo y PeerTube, mezclado e intercalado. Si una fuente falla, las demás pueden seguir proporcionando contenido.
- **Paginación:** carga progresiva de videos al aproximarse al final de la lista y reorganización del contenido visto.
- **Favorites:** sección de videos marcados con «Me gusta», persistidos mediante `shared_preferences`.
- **Likes persistentes:** el contador aumenta o disminuye al marcar o desmarcar el corazón y conserva el estado en el dispositivo.
- **Mute global:** control de sonido compartido entre videos y secciones.
- **Descripciones extensas:** texto contraíble mediante «... más», con una zona expandible de desplazamiento vertical.
- **Temas por temporada:** Halloween, Navidad, San Valentín y Normal, con cambios de tipografía, audio, iconografía y paleta de colores.
- **Selección manual de temporada:** permite probar los distintos temas y conservar la preferencia localmente.
- **Splash animado:** pantalla inicial de tres segundos con audio asociado a la temporada activa.

## Arquitectura: Clean Architecture

| Capa | Responsabilidad |
|---|---|
| `lib/presentation/` | Pantallas, widgets de reproducción y providers, incluidos `DiscoverProvider`, favoritos, temporada y audio. |
| `lib/domain/` | Entidades como `VideoPost` y `ExternalVideo`, reglas de temporada y contratos de datasources y repositorios. |
| `lib/infrastructure/` | Datasources locales y remotos, modelos, mappers, repositorios y persistencia mediante `shared_preferences`. |

Los providers se comunican con los repositorios y no acceden directamente a los datasources, manteniendo separadas las responsabilidades de cada capa.

## Diagramas de arquitectura

La documentación visual del proyecto está disponible en GitHub Pages.

- [Abrir diagramas de TokTik](https://koudionicio.github.io/Practicas_DMI_230237/practica04/toktik/)
- [Consultar el repositorio completo](https://github.com/KouDionicio/Practicas_DMI_230237)

## Fuentes de video

| Fuente | Método de reproducción |
|---|---|
| Local | `video_player` con archivos de `assets/videos/`. |
| YouTube | Reproductor IFrame integrado en `WebView`, con subtítulos desactivados. |
| Vimeo | Reproductor oficial embebido y metadatos mediante `vimeo_backend`. |
| PeerTube | `video_player` con archivos MP4 o flujos HLS proporcionados por la API de la instancia. |

### Configuración de servicios

Crea un archivo `.env` a partir de `.env.example` y configura las variables necesarias para el entorno:

```dotenv
YOUTUBE_API_KEY=tu_api_key
VIMEO_TOKEN=tu_token
BACKEND_BASE_URL=http://localhost:3000
PEERTUBE_BASE_URL=https://tu-instancia-peertube
```

Los valores anteriores son ejemplos de configuración; utiliza las direcciones y credenciales correspondientes al entorno real. No publiques claves ni tokens en el repositorio.

Para Vimeo, inicia el backend desde `Practica04/vimeo_backend/` cuando sea necesario.

## Iconografía y temas por temporada

### Iconos de temporada

| Temporada | Icono | Archivo |
|---|---|---|
| Normal | <img src="assets/icons/normal.png" alt="Icono Normal" width="44"> | `assets/icons/normal.png` |
| Halloween | <img src="assets/icons/halloween.png" alt="Icono Halloween" width="44"> | `assets/icons/halloween.png` |
| Navidad | <img src="assets/icons/navidad.png" alt="Icono Navidad" width="44"> | `assets/icons/navidad.png` |
| San Valentín | <img src="assets/icons/san_valentin.png" alt="Icono San Valentín" width="44"> | `assets/icons/san_valentin.png` |

### Acciones de la interfaz

| Acción | Iconos utilizados |
|---|---|
| Me gusta | `favorite` / `favorite_border` |
| Sonido | `volume_up` / `volume_off` |
| Reproducir o pausar | `play_arrow` / `pause` |
| Búsqueda externa | `search` |
| Ajustes de temporada | PNG correspondiente a la temporada activa |

### Calendario de temporadas

| Temporada | Periodo |
|---|---|
| Halloween | Del 1 al 31 de octubre. |
| Navidad | Del 1 de diciembre al 6 de enero. |
| San Valentín | Del 1 al 14 de febrero. |
| Normal | El resto del año. |

La temporada automática depende de la fecha del dispositivo. La selección manual permite validar la interfaz y sus recursos visuales durante las pruebas.

## Demostración en video

Los siguientes videos documentan las principales funcionalidades. Las dimensiones se limitan para evitar que los archivos ocupen demasiado espacio en el README.

<table>
  <tr>
    <td align="center" width="50%">
      <strong>Temas por temporada</strong><br><br>
      <video src="assets/video/temas.mp4" controls muted width="260"></video><br>
      <a href="assets/video/temas.mp4">Abrir video</a>
    </td>
    <td align="center" width="50%">
      <strong>For You, Discover y Favorites</strong><br><br>
      <video src="assets/video/secciones.mp4" controls muted width="260"></video><br>
      <a href="assets/video/secciones.mp4">Abrir video</a>
    </td>
  </tr>
  <tr>
    <td align="center" width="50%">
      <strong>Likes y control de sonido</strong><br><br>
      <video src="assets/video/likes_mute.mp4" controls muted width="260"></video><br>
      <a href="assets/video/likes_mute.mp4">Abrir video</a>
    </td>
    <td align="center" width="50%">
      <strong>YouTube, Vimeo y PeerTube</strong><br><br>
      <video src="assets/video/proveedores.mp4" controls muted width="260"></video><br>
      <a href="assets/video/proveedores.mp4">Abrir video</a>
    </td>
  </tr>
</table>

> Nota: la reproducción de videos incrustados depende de la plataforma donde se visualice el README. Si GitHub no muestra el reproductor, utiliza el enlace «Abrir video» debajo de cada demostración.

## Ejecución local

Desde la carpeta `Practica04/toktik/`, ejecuta:

```bash
flutter pub get
flutter analyze
flutter run
```

Para utilizar la integración de Vimeo, inicia el backend desde `Practica04/vimeo_backend/`:

```bash
npm install
npm start
```

Comprueba que las variables de entorno y las direcciones de los servicios coincidan con tu entorno de ejecución.

## Publicación en Appetize

[![Appetize](https://img.shields.io/badge/Appetize-Demo%20Android-6C5CE7)](https://appetize.io/app/b_yw4zidsh4wkzeww7mkpnrzsxki)

**[Abrir TokTik en Appetize.io](https://appetize.io/app/b_yw4zidsh4wkzeww7mkpnrzsxki)**

Appetize permite ejecutar aplicaciones Android desde el navegador sin instalarlas directamente en un teléfono ni publicarlas en Google Play.

### Preparación

- Permiso `INTERNET` declarado en `android/app/src/main/AndroidManifest.xml`.
- Archivo `.env` excluido del control de versiones.
- API key de YouTube restringida a YouTube Data API v3.
- Token de Vimeo con permisos de solo lectura.
- Para una aplicación que se ejecuta en la nube, el backend local de la computadora no es accesible mediante `localhost` desde el dispositivo virtual. Configura una URL accesible desde el entorno de Appetize o utiliza la alternativa implementada por la aplicación.

### Compilación para Android

Desde la carpeta del proyecto:

```bash
flutter pub get
flutter analyze
flutter build apk --release
```

El APK se genera en:

```text
build/app/outputs/flutter-apk/app-release.apk
```

### Datos de la publicación documentada

| Dato | Valor |
|---|---|
| Archivo | `app-release.apk` |
| Tamaño reportado | 155.9 MB |
| Versión reportada | 1.0.0 (build 1) |
| Identificador | `com.example.toktik` |

### Dispositivo de prueba

| Dispositivo | Sistema operativo | Escala |
|---|---|---|
| Pixel 7 virtual | Android 13.0 | Automática |

### Resultados de pruebas registrados

| Prueba | Resultado | Observaciones |
|---|---|---|
| Instalación y apertura | ✅ | La aplicación aparece en el launcher y abre correctamente. |
| For You: videos locales | ✅ | Reproduce videos locales con iconografía de la temporada. |
| Discover: YouTube | ✅ | El reproductor carga y permite pausar. |
| Discover: Vimeo | ⚠️ | Se reportó un error del reproductor con opciones para abrir Vimeo o reintentar. |
| Discover: PeerTube | ⏳ | Pendiente de validar. |
| Favorites y likes | ✅ | Los videos marcados aparecen en Favorites. |
| Control de sonido | ✅ | El icono refleja el estado de silencio. |
| Descripción «... más» | ⏳ | Pendiente de validar. |
| Cambio de temporada | ⏳ | Pendiente de validar. |
| Adaptación de interfaz | ✅ | Se reportó una visualización correcta en el Pixel 7. |

**Leyenda:** ✅ funciona según la prueba registrada · ⚠️ funciona con limitaciones · ⏳ pendiente de validar.

Los resultados corresponden a las pruebas documentadas y deben actualizarse si se realizan nuevas validaciones.

## Evidencias de compilación y ejecución

### Compilación y publicación

<table>
  <tr>
    <td align="center" width="33%">
      <strong>APK generado</strong><br><br>
      <img src="assets/evidencia/01_build.png" alt="Evidencia de compilación" width="200">
    </td>
    <td align="center" width="33%">
      <strong>Archivo APK</strong><br><br>
      <img src="assets/evidencia/02_apk.png" alt="Evidencia del archivo APK" width="200">
    </td>
    <td align="center" width="33%">
      <strong>Aplicación subida</strong><br><br>
      <img src="assets/evidencia/03_subida.png" alt="Evidencia de la subida a Appetize" width="200">
    </td>
  </tr>
</table>

### Ejecución en Pixel 7 (Android 13.0)

<table>
  <tr>
    <td align="center" width="33%">
      <strong>Dispositivo y launcher</strong><br><br>
      <img src="assets/evidencia/04_pixel7_inicio.png" alt="Evidencia del dispositivo y launcher" width="200">
    </td>
    <td align="center" width="33%">
      <strong>For You</strong><br><br>
      <img src="assets/evidencia/05_foryou.png" alt="Evidencia del feed For You" width="200">
    </td>
    <td align="center" width="33%">
      <strong>Favorites con YouTube</strong><br><br>
      <img src="assets/evidencia/06_favorites_youtube.png" alt="Evidencia de favoritos con YouTube" width="200">
    </td>
  </tr>
</table>

### Evidencias adicionales

<table>
  <tr>
    <td align="center" width="33%">
      <img src="images/1.png" alt="Evidencia adicional 1" width="160">
    </td>
    <td align="center" width="33%">
      <img src="images/2.png" alt="Evidencia adicional 2" width="160">
    </td>
    <td align="center" width="33%">
      <img src="images/3.png" alt="Evidencia adicional 3" width="160">
    </td>
  </tr>
</table>

Las imágenes deben existir en las rutas indicadas. Si alguna evidencia se movió o cambió de nombre, actualiza su ruta para evitar imágenes rotas.

## Incidencias conocidas

| Incidencia | Causa registrada | Comportamiento o alternativa |
|---|---|---|
| Vimeo muestra un error al abrir el reproductor en Appetize | Se reportó una respuesta HTTP 403 asociada a la verificación de Cloudflare. | La interfaz ofrece abrir Vimeo o reintentar. El comportamiento puede variar según la red y el entorno de ejecución. |
| APK de aproximadamente 155.9 MB | Incluye videos locales y binarios para varias arquitecturas. | Puede reducirse con compilaciones separadas por ABI y optimizando los videos locales. |

## Ventajas y limitaciones

**Ventajas**
- No requiere un dispositivo físico para realizar una demostración en Appetize.
- Permite compartir la aplicación mediante un enlace.
- Integra videos locales y varias fuentes externas.
- Mantiene favoritos y preferencias mediante almacenamiento local.
- Organiza el código mediante Clean Architecture.

**Limitaciones**
- La cuenta gratuita de Appetize puede tener límites de uso.
- La reproducción multimedia puede rendir de manera distinta a la de un dispositivo físico.
- Algunos servicios externos pueden bloquear solicitudes desde entornos virtuales.
- Los servicios locales de la computadora no son accesibles automáticamente desde una aplicación ejecutada en la nube.

## Conclusión

TokTik integra reproducción de videos verticales, consumo de servicios externos, favoritos persistentes y personalización visual por temporadas en una aplicación Flutter organizada mediante Clean Architecture.

La documentación, las demostraciones y las evidencias complementan el código fuente y facilitan la revisión de las funcionalidades y del proceso de publicación.

---

<div align="center">

**Práctica 04 · Desarrollo Móvil Integral**

*Flutter · Dart · Clean Architecture*

[Ver repositorio en GitHub](https://github.com/KouDionicio/Practicas_DMI_230237) · [Probar en Appetize](https://appetize.io/app/b_yw4zidsh4wkzeww7mkpnrzsxki)

</div>