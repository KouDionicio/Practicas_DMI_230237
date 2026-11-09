// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for es.
class AppLocalizationsEs extends AppLocalizations {
  AppLocalizationsEs([String locale = 'es']) : super(locale);

  @override
  String get appTagline => 'Tu enciclopedia de cine';

  @override
  String get splashLoading => 'Preparando tu cartelera…';

  @override
  String get menuOpenTooltip => 'Abrir menú';

  @override
  String get menuCloseTooltip => 'Cerrar menú';

  @override
  String get menuSectionExplore => 'Explorar';

  @override
  String get menuSectionPreferences => 'Preferencias';

  @override
  String get menuCurrentRegion => 'Región actual';

  @override
  String get navHome => 'Inicio';

  @override
  String get navCategories => 'Categorías';

  @override
  String get navFavorites => 'Favoritos';

  @override
  String get navSettings => 'Configuración';

  @override
  String get searchTooltip => 'Buscar';

  @override
  String get searchFieldLabel => 'Buscar películas';

  @override
  String get searchClearTooltip => 'Limpiar búsqueda';

  @override
  String get searchEmptyHint => 'Escribe el título de una película';

  @override
  String searchNoResults(String query) {
    return 'No encontramos películas para «${query}»';
  }

  @override
  String get featuredTitle => 'Destacadas';

  @override
  String get nowPlayingTitle => 'En cines';

  @override
  String get upcomingTitle => 'Próximamente';

  @override
  String get upcomingSubtitle => 'En este mes';

  @override
  String get popularTitle => 'Populares';

  @override
  String get topRatedTitle => 'Mejor calificadas';

  @override
  String get topRatedSubtitle => 'Desde siempre';

  @override
  String get carouselPrevious => 'Película anterior';

  @override
  String get carouselNext => 'Película siguiente';

  @override
  String carouselPosition(String current, String total) {
    return '${current} de ${total}';
  }

  @override
  String get carouselTripleTapHint => 'Toca tres veces una flecha para ir a la primera o a la última película';

  @override
  String get carouselJumpedFirst => 'Primera película';

  @override
  String get carouselJumpedLast => 'Última película';

  @override
  String get localizedTitleLabel => 'Título localizado';

  @override
  String get originalTitleLabel => 'Título original';

  @override
  String get releaseDateLabel => 'Estreno';

  @override
  String get releaseDateUnknown => 'Por confirmar';

  @override
  String votesCount(String count) {
    return '${count} votos';
  }

  @override
  String ratingSemantics(String rating) {
    return 'Calificación: ${rating} de 10';
  }

  @override
  String get certificationLabel => 'Clasificación';

  @override
  String get certificationUnavailable => 'Clasificación no disponible';

  @override
  String get certificationLoading => 'Cargando clasificación…';

  @override
  String get certificationError => 'No se pudo cargar la clasificación. Toca para reintentar.';

  @override
  String get viewDetails => 'Ver detalles';

  @override
  String get overviewTitle => 'Sinopsis';

  @override
  String get overviewUnavailable => 'No hay sinopsis disponible en este idioma.';

  @override
  String get genresTitle => 'Géneros';

  @override
  String get castTitle => 'Reparto';

  @override
  String get castEmpty => 'No hay información del reparto.';

  @override
  String get loaderPleaseWait => 'Espere por favor';

  @override
  String get loaderLoading => 'Cargando…';

  @override
  String get loaderMessage1 => 'Cargando películas';

  @override
  String get loaderMessage2 => 'Comprando palomitas de maíz';

  @override
  String get loaderMessage3 => 'Cargando populares';

  @override
  String get loaderMessage4 => 'Llamando a mi novia';

  @override
  String get loaderMessage5 => 'Ya mero…';

  @override
  String get loaderMessage6 => 'Esto está tardando más de lo esperado :(';

  @override
  String get errorLoadMovies => 'No pudimos cargar las películas';

  @override
  String get errorLoadMovie => 'No pudimos cargar esta película';

  @override
  String get errorConnection => 'Revisa tu conexión a internet e inténtalo de nuevo.';

  @override
  String get errorUnauthorized => 'La clave de TMDB no es válida o falta en el archivo .env.';

  @override
  String get errorServer => 'El servicio de películas no está disponible en este momento.';

  @override
  String get errorGeneric => 'Algo salió mal. Inténtalo de nuevo.';

  @override
  String get retry => 'Reintentar';

  @override
  String get favoritesEmptyTitle => 'Aún no tienes favoritos';

  @override
  String get favoritesEmptyMessage => 'Las películas que marques como favoritas aparecerán aquí.';

  @override
  String get goHome => 'Ir al inicio';

  @override
  String get favoriteAdd => 'Agregar a favoritos';

  @override
  String get favoriteRemove => 'Quitar de favoritos';

  @override
  String favoriteAdded(String title) {
    return '«${title}» se agregó a favoritos';
  }

  @override
  String favoriteRemoved(String title) {
    return '«${title}» se quitó de favoritos';
  }

  @override
  String get undo => 'Deshacer';

  @override
  String favoritesCount(String count) {
    return '${count} películas';
  }

  @override
  String get categoriesHint => 'Elige un género';

  @override
  String get categoryEmpty => 'No hay películas de este género en tu región.';

  @override
  String get errorLoadGenres => 'No pudimos cargar las categorías';

  @override
  String get settingsHeadline => 'Tu cine, tu idioma';

  @override
  String get settingsDescription => 'Elige un país para ajustar el idioma de la aplicación, la cartelera regional de TMDB y las clasificaciones por edad.';

  @override
  String get settingsRegionSection => 'REGIÓN E IDIOMA';

  @override
  String get settingsInfoNote => 'El país define la región de consulta en TMDB, el idioma de toda la aplicación y el sistema de clasificación. Tu elección se guarda automáticamente en este dispositivo.';

  @override
  String get settingsSelected => 'Seleccionado';

  @override
  String settingsRegionChanged(String country) {
    return 'Región actualizada: ${country}';
  }

  @override
  String settingsRatingSystem(String system) {
    return 'Clasificación ${system}';
  }

  @override
  String get regionMX => 'México';

  @override
  String get regionUS => 'Estados Unidos';

  @override
  String get regionDE => 'Alemania';

  @override
  String get regionFR => 'Francia';

  @override
  String get regionKR => 'Corea del Sur';

  @override
  String get regionJP => 'Japón';

  @override
  String get regionBR => 'Brasil';

  @override
  String get regionEG => 'Egipto';
}
