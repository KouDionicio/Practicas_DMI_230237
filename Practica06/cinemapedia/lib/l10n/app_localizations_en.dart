// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for en.
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTagline => 'Your movie encyclopedia';

  @override
  String get splashLoading => 'Getting your movies ready…';

  @override
  String get menuOpenTooltip => 'Open menu';

  @override
  String get menuCloseTooltip => 'Close menu';

  @override
  String get menuSectionExplore => 'Explore';

  @override
  String get menuSectionPreferences => 'Preferences';

  @override
  String get menuCurrentRegion => 'Current region';

  @override
  String get navHome => 'Home';

  @override
  String get navCategories => 'Categories';

  @override
  String get navFavorites => 'Favorites';

  @override
  String get navSettings => 'Settings';

  @override
  String get searchTooltip => 'Search';

  @override
  String get searchFieldLabel => 'Search movies';

  @override
  String get searchClearTooltip => 'Clear search';

  @override
  String get searchEmptyHint => 'Type a movie title';

  @override
  String searchNoResults(String query) {
    return 'No movies found for “${query}”';
  }

  @override
  String get featuredTitle => 'Featured';

  @override
  String get nowPlayingTitle => 'Now playing';

  @override
  String get upcomingTitle => 'Coming soon';

  @override
  String get upcomingSubtitle => 'This month';

  @override
  String get popularTitle => 'Popular';

  @override
  String get topRatedTitle => 'Top rated';

  @override
  String get topRatedSubtitle => 'Of all time';

  @override
  String get carouselPrevious => 'Previous movie';

  @override
  String get carouselNext => 'Next movie';

  @override
  String carouselPosition(String current, String total) {
    return '${current} of ${total}';
  }

  @override
  String get carouselTripleTapHint => 'Tap an arrow three times to jump to the first or last movie';

  @override
  String get carouselJumpedFirst => 'First movie';

  @override
  String get carouselJumpedLast => 'Last movie';

  @override
  String get localizedTitleLabel => 'Localized title';

  @override
  String get originalTitleLabel => 'Original title';

  @override
  String get releaseDateLabel => 'Release';

  @override
  String get releaseDateUnknown => 'TBA';

  @override
  String votesCount(String count) {
    return '${count} votes';
  }

  @override
  String ratingSemantics(String rating) {
    return 'Rating: ${rating} out of 10';
  }

  @override
  String get certificationLabel => 'Age rating';

  @override
  String get certificationUnavailable => 'Age rating not available';

  @override
  String get certificationLoading => 'Loading age rating…';

  @override
  String get certificationError => 'Couldn’t load the age rating. Tap to retry.';

  @override
  String get viewDetails => 'View details';

  @override
  String get overviewTitle => 'Overview';

  @override
  String get overviewUnavailable => 'No overview available in this language.';

  @override
  String get genresTitle => 'Genres';

  @override
  String get castTitle => 'Cast';

  @override
  String get castEmpty => 'No cast information available.';

  @override
  String get loaderPleaseWait => 'Please wait';

  @override
  String get loaderLoading => 'Loading…';

  @override
  String get loaderMessage1 => 'Loading movies';

  @override
  String get loaderMessage2 => 'Buying popcorn';

  @override
  String get loaderMessage3 => 'Loading popular movies';

  @override
  String get loaderMessage4 => 'Calling my girlfriend';

  @override
  String get loaderMessage5 => 'Almost there…';

  @override
  String get loaderMessage6 => 'This is taking longer than expected :(';

  @override
  String get errorLoadMovies => 'We couldn’t load the movies';

  @override
  String get errorLoadMovie => 'We couldn’t load this movie';

  @override
  String get errorConnection => 'Check your internet connection and try again.';

  @override
  String get errorUnauthorized => 'The TMDB key is missing from .env or is invalid.';

  @override
  String get errorServer => 'The movie service is unavailable right now.';

  @override
  String get errorGeneric => 'Something went wrong. Please try again.';

  @override
  String get retry => 'Retry';

  @override
  String get favoritesEmptyTitle => 'No favorites yet';

  @override
  String get favoritesEmptyMessage => 'Movies you mark as favorites will appear here.';

  @override
  String get goHome => 'Go to home';

  @override
  String get favoriteAdd => 'Add to favorites';

  @override
  String get favoriteRemove => 'Remove from favorites';

  @override
  String favoriteAdded(String title) {
    return '“${title}” added to favorites';
  }

  @override
  String favoriteRemoved(String title) {
    return '“${title}” removed from favorites';
  }

  @override
  String get undo => 'Undo';

  @override
  String favoritesCount(String count) {
    return '${count} movies';
  }

  @override
  String get categoriesHint => 'Choose a genre';

  @override
  String get categoryEmpty => 'No movies in this genre for your region.';

  @override
  String get errorLoadGenres => 'We couldn’t load the categories';

  @override
  String get settingsHeadline => 'Your cinema, your language';

  @override
  String get settingsDescription => 'Choose a country to set the app language, the regional TMDB listings and age ratings.';

  @override
  String get settingsRegionSection => 'REGION & LANGUAGE';

  @override
  String get settingsInfoNote => 'The country sets the TMDB query region, the language of the whole app and the rating system. Your choice is saved automatically on this device.';

  @override
  String get settingsSelected => 'Selected';

  @override
  String settingsRegionChanged(String country) {
    return 'Region updated: ${country}';
  }

  @override
  String settingsRatingSystem(String system) {
    return 'Ratings: ${system}';
  }

  @override
  String get regionMX => 'Mexico';

  @override
  String get regionUS => 'United States';

  @override
  String get regionDE => 'Germany';

  @override
  String get regionFR => 'France';

  @override
  String get regionKR => 'South Korea';

  @override
  String get regionJP => 'Japan';

  @override
  String get regionBR => 'Brazil';

  @override
  String get regionEG => 'Egypt';
}
