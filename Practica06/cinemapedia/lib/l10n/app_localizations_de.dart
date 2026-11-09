// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for German (`de`).
class AppLocalizationsDe extends AppLocalizations {
  AppLocalizationsDe([String locale = 'de']) : super(locale);

  @override
  String get appTagline => 'Deine Filmenzyklopädie';

  @override
  String get splashLoading => 'Dein Kinoprogramm wird vorbereitet…';

  @override
  String get menuOpenTooltip => 'Menü öffnen';

  @override
  String get menuCloseTooltip => 'Menü schließen';

  @override
  String get menuSectionExplore => 'Entdecken';

  @override
  String get menuSectionPreferences => 'Präferenzen';

  @override
  String get menuCurrentRegion => 'Aktuelle Region';

  @override
  String get navHome => 'Start';

  @override
  String get navCategories => 'Kategorien';

  @override
  String get navFavorites => 'Favoriten';

  @override
  String get navSettings => 'Einstellungen';

  @override
  String get searchTooltip => 'Suchen';

  @override
  String get searchFieldLabel => 'Filme suchen';

  @override
  String get searchClearTooltip => 'Suche löschen';

  @override
  String get searchEmptyHint => 'Gib einen Filmtitel ein';

  @override
  String searchNoResults(String query) {
    return 'Keine Filme für „$query“ gefunden';
  }

  @override
  String get featuredTitle => 'Highlights';

  @override
  String get nowPlayingTitle => 'Im Kino';

  @override
  String get upcomingTitle => 'Demnächst';

  @override
  String get upcomingSubtitle => 'Diesen Monat';

  @override
  String get popularTitle => 'Beliebt';

  @override
  String get topRatedTitle => 'Bestbewertet';

  @override
  String get topRatedSubtitle => 'Aller Zeiten';

  @override
  String get carouselPrevious => 'Vorheriger Film';

  @override
  String get carouselNext => 'Nächster Film';

  @override
  String carouselPosition(String current, String total) {
    return '$current von $total';
  }

  @override
  String get carouselTripleTapHint =>
      'Tippe dreimal auf einen Pfeil, um zum ersten oder letzten Film zu springen';

  @override
  String get carouselJumpedFirst => 'Erster Film';

  @override
  String get carouselJumpedLast => 'Letzter Film';

  @override
  String get localizedTitleLabel => 'Lokalisierter Titel';

  @override
  String get originalTitleLabel => 'Originaltitel';

  @override
  String get releaseDateLabel => 'Kinostart';

  @override
  String get releaseDateUnknown => 'Noch offen';

  @override
  String votesCount(String count) {
    return '$count Stimmen';
  }

  @override
  String ratingSemantics(String rating) {
    return 'Bewertung: $rating von 10';
  }

  @override
  String get certificationLabel => 'Altersfreigabe';

  @override
  String get certificationUnavailable => 'Keine Altersfreigabe verfügbar';

  @override
  String get certificationLoading => 'Altersfreigabe wird geladen…';

  @override
  String get certificationError =>
      'Altersfreigabe konnte nicht geladen werden. Zum Wiederholen tippen.';

  @override
  String get viewDetails => 'Details ansehen';

  @override
  String get overviewTitle => 'Handlung';

  @override
  String get overviewUnavailable =>
      'Keine Handlung in dieser Sprache verfügbar.';

  @override
  String get genresTitle => 'Genres';

  @override
  String get castTitle => 'Besetzung';

  @override
  String get castEmpty => 'Keine Besetzungsinformationen verfügbar.';

  @override
  String get loaderPleaseWait => 'Bitte warten';

  @override
  String get loaderLoading => 'Wird geladen…';

  @override
  String get loaderMessage1 => 'Filme werden geladen';

  @override
  String get loaderMessage2 => 'Popcorn wird gekauft';

  @override
  String get loaderMessage3 => 'Beliebte Filme werden geladen';

  @override
  String get loaderMessage4 => 'Ich rufe meine Freundin an';

  @override
  String get loaderMessage5 => 'Gleich geschafft…';

  @override
  String get loaderMessage6 => 'Das dauert länger als erwartet :(';

  @override
  String get errorLoadMovies => 'Die Filme konnten nicht geladen werden';

  @override
  String get errorLoadMovie => 'Dieser Film konnte nicht geladen werden';

  @override
  String get errorConnection =>
      'Überprüfe deine Internetverbindung und versuche es erneut.';

  @override
  String get errorUnauthorized =>
      'Der TMDB-Schlüssel fehlt in der .env-Datei oder ist ungültig.';

  @override
  String get errorServer => 'Der Filmdienst ist derzeit nicht verfügbar.';

  @override
  String get errorGeneric =>
      'Etwas ist schiefgelaufen. Bitte versuche es erneut.';

  @override
  String get retry => 'Erneut versuchen';

  @override
  String get favoritesEmptyTitle => 'Noch keine Favoriten';

  @override
  String get favoritesEmptyMessage =>
      'Filme, die du als Favoriten markierst, erscheinen hier.';

  @override
  String get categoriesEmptyTitle => 'Bald verfügbar';

  @override
  String get categoriesEmptyMessage =>
      'Wir bereiten das Stöbern nach Kategorien vor.';

  @override
  String get goHome => 'Zur Startseite';

  @override
  String get settingsHeadline => 'Dein Kino, deine Sprache';

  @override
  String get settingsDescription =>
      'Wähle ein Land, um die App-Sprache, das regionale TMDB-Angebot und die Altersfreigaben festzulegen.';

  @override
  String get settingsRegionSection => 'REGION & SPRACHE';

  @override
  String get settingsInfoNote =>
      'Das Land bestimmt die TMDB-Abfrageregion, die Sprache der gesamten App und das Freigabesystem. Deine Auswahl wird automatisch auf diesem Gerät gespeichert.';

  @override
  String get settingsSelected => 'Ausgewählt';

  @override
  String settingsRegionChanged(String country) {
    return 'Region aktualisiert: $country';
  }

  @override
  String settingsRatingSystem(String system) {
    return 'Freigabe: $system';
  }

  @override
  String get regionMX => 'Mexiko';

  @override
  String get regionUS => 'Vereinigte Staaten';

  @override
  String get regionDE => 'Deutschland';

  @override
  String get regionFR => 'Frankreich';

  @override
  String get regionKR => 'Südkorea';

  @override
  String get regionJP => 'Japan';

  @override
  String get regionBR => 'Brasilien';

  @override
  String get regionEG => 'Ägypten';
}
