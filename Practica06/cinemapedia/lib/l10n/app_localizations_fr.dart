// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for French (`fr`).
class AppLocalizationsFr extends AppLocalizations {
  AppLocalizationsFr([String locale = 'fr']) : super(locale);

  @override
  String get appTagline => 'Votre encyclopédie du cinéma';

  @override
  String get splashLoading => 'Préparation de votre programme…';

  @override
  String get menuOpenTooltip => 'Ouvrir le menu';

  @override
  String get menuCloseTooltip => 'Fermer le menu';

  @override
  String get menuSectionExplore => 'Explorer';

  @override
  String get menuSectionPreferences => 'Préférences';

  @override
  String get menuCurrentRegion => 'Région actuelle';

  @override
  String get navHome => 'Accueil';

  @override
  String get navCategories => 'Catégories';

  @override
  String get navFavorites => 'Favoris';

  @override
  String get navSettings => 'Paramètres';

  @override
  String get searchTooltip => 'Rechercher';

  @override
  String get searchFieldLabel => 'Rechercher des films';

  @override
  String get searchClearTooltip => 'Effacer la recherche';

  @override
  String get searchEmptyHint => 'Saisissez le titre d’un film';

  @override
  String searchNoResults(String query) {
    return 'Aucun film trouvé pour « $query »';
  }

  @override
  String get featuredTitle => 'À la une';

  @override
  String get nowPlayingTitle => 'À l’affiche';

  @override
  String get upcomingTitle => 'Prochainement';

  @override
  String get upcomingSubtitle => 'Ce mois-ci';

  @override
  String get popularTitle => 'Populaires';

  @override
  String get topRatedTitle => 'Les mieux notés';

  @override
  String get topRatedSubtitle => 'De tous les temps';

  @override
  String get carouselPrevious => 'Film précédent';

  @override
  String get carouselNext => 'Film suivant';

  @override
  String carouselPosition(String current, String total) {
    return '$current sur $total';
  }

  @override
  String get carouselTripleTapHint =>
      'Touchez trois fois une flèche pour aller au premier ou au dernier film';

  @override
  String get carouselJumpedFirst => 'Premier film';

  @override
  String get carouselJumpedLast => 'Dernier film';

  @override
  String get localizedTitleLabel => 'Titre localisé';

  @override
  String get originalTitleLabel => 'Titre original';

  @override
  String get releaseDateLabel => 'Sortie';

  @override
  String get releaseDateUnknown => 'À confirmer';

  @override
  String votesCount(String count) {
    return '$count votes';
  }

  @override
  String ratingSemantics(String rating) {
    return 'Note : $rating sur 10';
  }

  @override
  String get certificationLabel => 'Classification';

  @override
  String get certificationUnavailable => 'Classification non disponible';

  @override
  String get certificationLoading => 'Chargement de la classification…';

  @override
  String get certificationError =>
      'Impossible de charger la classification. Touchez pour réessayer.';

  @override
  String get viewDetails => 'Voir les détails';

  @override
  String get overviewTitle => 'Synopsis';

  @override
  String get overviewUnavailable =>
      'Aucun synopsis disponible dans cette langue.';

  @override
  String get genresTitle => 'Genres';

  @override
  String get castTitle => 'Distribution';

  @override
  String get castEmpty => 'Aucune information sur la distribution.';

  @override
  String get loaderPleaseWait => 'Veuillez patienter';

  @override
  String get loaderLoading => 'Chargement…';

  @override
  String get loaderMessage1 => 'Chargement des films';

  @override
  String get loaderMessage2 => 'Achat du pop-corn';

  @override
  String get loaderMessage3 => 'Chargement des films populaires';

  @override
  String get loaderMessage4 => 'J’appelle ma copine';

  @override
  String get loaderMessage5 => 'On y est presque…';

  @override
  String get loaderMessage6 => 'Cela prend plus de temps que prévu :(';

  @override
  String get errorLoadMovies => 'Impossible de charger les films';

  @override
  String get errorLoadMovie => 'Impossible de charger ce film';

  @override
  String get errorConnection =>
      'Vérifiez votre connexion Internet et réessayez.';

  @override
  String get errorUnauthorized =>
      'La clé TMDB est absente du fichier .env ou n’est pas valide.';

  @override
  String get errorServer =>
      'Le service de films est indisponible pour le moment.';

  @override
  String get errorGeneric => 'Une erreur s’est produite. Veuillez réessayer.';

  @override
  String get retry => 'Réessayer';

  @override
  String get favoritesEmptyTitle => 'Pas encore de favoris';

  @override
  String get favoritesEmptyMessage =>
      'Les films que vous ajoutez à vos favoris apparaîtront ici.';

  @override
  String get categoriesEmptyTitle => 'Bientôt disponible';

  @override
  String get categoriesEmptyMessage =>
      'Nous préparons la navigation par catégories.';

  @override
  String get goHome => 'Aller à l’accueil';

  @override
  String get settingsHeadline => 'Votre cinéma, votre langue';

  @override
  String get settingsDescription =>
      'Choisissez un pays pour définir la langue de l’application, le programme régional TMDB et les classifications par âge.';

  @override
  String get settingsRegionSection => 'RÉGION ET LANGUE';

  @override
  String get settingsInfoNote =>
      'Le pays définit la région de recherche TMDB, la langue de toute l’application et le système de classification. Votre choix est enregistré automatiquement sur cet appareil.';

  @override
  String get settingsSelected => 'Sélectionné';

  @override
  String settingsRegionChanged(String country) {
    return 'Région mise à jour : $country';
  }

  @override
  String settingsRatingSystem(String system) {
    return 'Classification $system';
  }

  @override
  String get regionMX => 'Mexique';

  @override
  String get regionUS => 'États-Unis';

  @override
  String get regionDE => 'Allemagne';

  @override
  String get regionFR => 'France';

  @override
  String get regionKR => 'Corée du Sud';

  @override
  String get regionJP => 'Japon';

  @override
  String get regionBR => 'Brésil';

  @override
  String get regionEG => 'Égypte';
}
