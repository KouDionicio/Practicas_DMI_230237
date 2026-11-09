import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_de.dart';
import 'app_localizations_en.dart';
import 'app_localizations_es.dart';
import 'app_localizations_fr.dart';
import 'app_localizations_ja.dart';
import 'app_localizations_ko.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('ar'),
    Locale('de'),
    Locale('en'),
    Locale('es'),
    Locale('fr'),
    Locale('ja'),
    Locale('ko'),
    Locale('pt'),
  ];

  /// Eslogan bajo el nombre de la app
  ///
  /// In es, this message translates to:
  /// **'Tu enciclopedia de cine'**
  String get appTagline;

  /// Texto de la pantalla de carga
  ///
  /// In es, this message translates to:
  /// **'Preparando tu cartelera…'**
  String get splashLoading;

  /// Tooltip del botón hamburguesa
  ///
  /// In es, this message translates to:
  /// **'Abrir menú'**
  String get menuOpenTooltip;

  /// Tooltip para cerrar el menú
  ///
  /// In es, this message translates to:
  /// **'Cerrar menú'**
  String get menuCloseTooltip;

  /// Sección del menú lateral
  ///
  /// In es, this message translates to:
  /// **'Explorar'**
  String get menuSectionExplore;

  /// Sección del menú lateral
  ///
  /// In es, this message translates to:
  /// **'Preferencias'**
  String get menuSectionPreferences;

  /// Etiqueta de la región actual en el menú
  ///
  /// In es, this message translates to:
  /// **'Región actual'**
  String get menuCurrentRegion;

  /// Navegación: inicio
  ///
  /// In es, this message translates to:
  /// **'Inicio'**
  String get navHome;

  /// Navegación: categorías
  ///
  /// In es, this message translates to:
  /// **'Categorías'**
  String get navCategories;

  /// Navegación: favoritos
  ///
  /// In es, this message translates to:
  /// **'Favoritos'**
  String get navFavorites;

  /// Navegación: configuración
  ///
  /// In es, this message translates to:
  /// **'Configuración'**
  String get navSettings;

  /// Tooltip del botón de búsqueda
  ///
  /// In es, this message translates to:
  /// **'Buscar'**
  String get searchTooltip;

  /// Placeholder del campo de búsqueda
  ///
  /// In es, this message translates to:
  /// **'Buscar películas'**
  String get searchFieldLabel;

  /// Tooltip para limpiar la búsqueda
  ///
  /// In es, this message translates to:
  /// **'Limpiar búsqueda'**
  String get searchClearTooltip;

  /// Ayuda cuando la búsqueda está vacía
  ///
  /// In es, this message translates to:
  /// **'Escribe el título de una película'**
  String get searchEmptyHint;

  /// Sin resultados de búsqueda
  ///
  /// In es, this message translates to:
  /// **'No encontramos películas para «{query}»'**
  String searchNoResults(String query);

  /// Título del carrusel principal
  ///
  /// In es, this message translates to:
  /// **'Destacadas'**
  String get featuredTitle;

  /// Lista: en cines
  ///
  /// In es, this message translates to:
  /// **'En cines'**
  String get nowPlayingTitle;

  /// Lista: próximamente
  ///
  /// In es, this message translates to:
  /// **'Próximamente'**
  String get upcomingTitle;

  /// Subtítulo de próximamente
  ///
  /// In es, this message translates to:
  /// **'En este mes'**
  String get upcomingSubtitle;

  /// Lista: populares
  ///
  /// In es, this message translates to:
  /// **'Populares'**
  String get popularTitle;

  /// Lista: mejor calificadas
  ///
  /// In es, this message translates to:
  /// **'Mejor calificadas'**
  String get topRatedTitle;

  /// Subtítulo de mejor calificadas
  ///
  /// In es, this message translates to:
  /// **'Desde siempre'**
  String get topRatedSubtitle;

  /// Flecha < del carrusel
  ///
  /// In es, this message translates to:
  /// **'Película anterior'**
  String get carouselPrevious;

  /// Flecha > del carrusel
  ///
  /// In es, this message translates to:
  /// **'Película siguiente'**
  String get carouselNext;

  /// Posición en el carrusel
  ///
  /// In es, this message translates to:
  /// **'{current} de {total}'**
  String carouselPosition(String current, String total);

  /// Texto de ayuda del carrusel
  ///
  /// In es, this message translates to:
  /// **'Toca tres veces una flecha para ir a la primera o a la última película'**
  String get carouselTripleTapHint;

  /// Aviso al saltar a la primera película
  ///
  /// In es, this message translates to:
  /// **'Primera película'**
  String get carouselJumpedFirst;

  /// Aviso al saltar a la última película
  ///
  /// In es, this message translates to:
  /// **'Última película'**
  String get carouselJumpedLast;

  /// Etiqueta del título localizado
  ///
  /// In es, this message translates to:
  /// **'Título localizado'**
  String get localizedTitleLabel;

  /// Etiqueta del título original
  ///
  /// In es, this message translates to:
  /// **'Título original'**
  String get originalTitleLabel;

  /// Etiqueta de la fecha de estreno
  ///
  /// In es, this message translates to:
  /// **'Estreno'**
  String get releaseDateLabel;

  /// Fecha de estreno desconocida
  ///
  /// In es, this message translates to:
  /// **'Por confirmar'**
  String get releaseDateUnknown;

  /// Número de votos (ya formateado)
  ///
  /// In es, this message translates to:
  /// **'{count} votos'**
  String votesCount(String count);

  /// Lectura accesible de la calificación
  ///
  /// In es, this message translates to:
  /// **'Calificación: {rating} de 10'**
  String ratingSemantics(String rating);

  /// Etiqueta de la clasificación por edad
  ///
  /// In es, this message translates to:
  /// **'Clasificación'**
  String get certificationLabel;

  /// Sin clasificación para el país
  ///
  /// In es, this message translates to:
  /// **'Clasificación no disponible'**
  String get certificationUnavailable;

  /// Cargando la clasificación
  ///
  /// In es, this message translates to:
  /// **'Cargando clasificación…'**
  String get certificationLoading;

  /// Error al cargar la clasificación
  ///
  /// In es, this message translates to:
  /// **'No se pudo cargar la clasificación. Toca para reintentar.'**
  String get certificationError;

  /// Botón para abrir el detalle
  ///
  /// In es, this message translates to:
  /// **'Ver detalles'**
  String get viewDetails;

  /// Título de la sinopsis
  ///
  /// In es, this message translates to:
  /// **'Sinopsis'**
  String get overviewTitle;

  /// Sin sinopsis en el idioma
  ///
  /// In es, this message translates to:
  /// **'No hay sinopsis disponible en este idioma.'**
  String get overviewUnavailable;

  /// Título de géneros
  ///
  /// In es, this message translates to:
  /// **'Géneros'**
  String get genresTitle;

  /// Título del reparto
  ///
  /// In es, this message translates to:
  /// **'Reparto'**
  String get castTitle;

  /// Sin reparto
  ///
  /// In es, this message translates to:
  /// **'No hay información del reparto.'**
  String get castEmpty;

  /// Cargador
  ///
  /// In es, this message translates to:
  /// **'Espere por favor'**
  String get loaderPleaseWait;

  /// Cargador
  ///
  /// In es, this message translates to:
  /// **'Cargando…'**
  String get loaderLoading;

  /// Mensaje del cargador
  ///
  /// In es, this message translates to:
  /// **'Cargando películas'**
  String get loaderMessage1;

  /// Mensaje del cargador
  ///
  /// In es, this message translates to:
  /// **'Comprando palomitas de maíz'**
  String get loaderMessage2;

  /// Mensaje del cargador
  ///
  /// In es, this message translates to:
  /// **'Cargando populares'**
  String get loaderMessage3;

  /// Mensaje del cargador
  ///
  /// In es, this message translates to:
  /// **'Llamando a mi novia'**
  String get loaderMessage4;

  /// Mensaje del cargador
  ///
  /// In es, this message translates to:
  /// **'Ya mero…'**
  String get loaderMessage5;

  /// Mensaje del cargador
  ///
  /// In es, this message translates to:
  /// **'Esto está tardando más de lo esperado :('**
  String get loaderMessage6;

  /// Error al cargar listas
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar las películas'**
  String get errorLoadMovies;

  /// Error al cargar una película
  ///
  /// In es, this message translates to:
  /// **'No pudimos cargar esta película'**
  String get errorLoadMovie;

  /// Error de conexión
  ///
  /// In es, this message translates to:
  /// **'Revisa tu conexión a internet e inténtalo de nuevo.'**
  String get errorConnection;

  /// API key de TMDB inválida
  ///
  /// In es, this message translates to:
  /// **'La clave de TMDB no es válida o falta en el archivo .env.'**
  String get errorUnauthorized;

  /// Servicio no disponible
  ///
  /// In es, this message translates to:
  /// **'El servicio de películas no está disponible en este momento.'**
  String get errorServer;

  /// Error genérico
  ///
  /// In es, this message translates to:
  /// **'Algo salió mal. Inténtalo de nuevo.'**
  String get errorGeneric;

  /// Botón reintentar
  ///
  /// In es, this message translates to:
  /// **'Reintentar'**
  String get retry;

  /// Favoritos vacío
  ///
  /// In es, this message translates to:
  /// **'Aún no tienes favoritos'**
  String get favoritesEmptyTitle;

  /// Favoritos vacío
  ///
  /// In es, this message translates to:
  /// **'Las películas que marques como favoritas aparecerán aquí.'**
  String get favoritesEmptyMessage;

  /// Categorías vacío
  ///
  /// In es, this message translates to:
  /// **'Muy pronto'**
  String get categoriesEmptyTitle;

  /// Categorías vacío
  ///
  /// In es, this message translates to:
  /// **'Estamos preparando la exploración por categorías.'**
  String get categoriesEmptyMessage;

  /// Botón para volver al inicio
  ///
  /// In es, this message translates to:
  /// **'Ir al inicio'**
  String get goHome;

  /// Título principal de configuración
  ///
  /// In es, this message translates to:
  /// **'Tu cine, tu idioma'**
  String get settingsHeadline;

  /// Descripción de configuración
  ///
  /// In es, this message translates to:
  /// **'Elige un país para ajustar el idioma de la aplicación, la cartelera regional de TMDB y las clasificaciones por edad.'**
  String get settingsDescription;

  /// Encabezado de sección
  ///
  /// In es, this message translates to:
  /// **'REGIÓN E IDIOMA'**
  String get settingsRegionSection;

  /// Nota informativa
  ///
  /// In es, this message translates to:
  /// **'El país define la región de consulta en TMDB, el idioma de toda la aplicación y el sistema de clasificación. Tu elección se guarda automáticamente en este dispositivo.'**
  String get settingsInfoNote;

  /// Estado seleccionado (accesibilidad)
  ///
  /// In es, this message translates to:
  /// **'Seleccionado'**
  String get settingsSelected;

  /// Mensaje de éxito al cambiar de país
  ///
  /// In es, this message translates to:
  /// **'Región actualizada: {country}'**
  String settingsRegionChanged(String country);

  /// Sistema de clasificación del país
  ///
  /// In es, this message translates to:
  /// **'Clasificación {system}'**
  String settingsRatingSystem(String system);

  /// Nombre del país MX
  ///
  /// In es, this message translates to:
  /// **'México'**
  String get regionMX;

  /// Nombre del país US
  ///
  /// In es, this message translates to:
  /// **'Estados Unidos'**
  String get regionUS;

  /// Nombre del país DE
  ///
  /// In es, this message translates to:
  /// **'Alemania'**
  String get regionDE;

  /// Nombre del país FR
  ///
  /// In es, this message translates to:
  /// **'Francia'**
  String get regionFR;

  /// Nombre del país KR
  ///
  /// In es, this message translates to:
  /// **'Corea del Sur'**
  String get regionKR;

  /// Nombre del país JP
  ///
  /// In es, this message translates to:
  /// **'Japón'**
  String get regionJP;

  /// Nombre del país BR
  ///
  /// In es, this message translates to:
  /// **'Brasil'**
  String get regionBR;

  /// Nombre del país EG
  ///
  /// In es, this message translates to:
  /// **'Egipto'**
  String get regionEG;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>[
    'ar',
    'de',
    'en',
    'es',
    'fr',
    'ja',
    'ko',
    'pt',
  ].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'de':
      return AppLocalizationsDe();
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
    case 'fr':
      return AppLocalizationsFr();
    case 'ja':
      return AppLocalizationsJa();
    case 'ko':
      return AppLocalizationsKo();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
