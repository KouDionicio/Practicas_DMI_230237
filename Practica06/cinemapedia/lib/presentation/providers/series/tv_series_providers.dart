import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:cinemapedia/domain/entities/actor.dart';
import 'package:cinemapedia/domain/entities/movie_certification.dart';
import 'package:cinemapedia/domain/entities/tv_series.dart';
import 'package:cinemapedia/presentation/providers/series/tv_series_repository_provider.dart';

/// Número máximo de series del carrusel (igual que el de películas).
const seriesSlideshowMaxItems = 10;

final airingTodaySeriesProvider = StateNotifierProvider<SeriesNotifier, List<TvSeries>>((ref) {
  return SeriesNotifier(fetchMoreSeries: ref.watch(tvSeriesRepositoryProvider).getAiringToday);
});

final onTheAirSeriesProvider = StateNotifierProvider<SeriesNotifier, List<TvSeries>>((ref) {
  return SeriesNotifier(fetchMoreSeries: ref.watch(tvSeriesRepositoryProvider).getOnTheAir);
});

final popularSeriesProvider = StateNotifierProvider<SeriesNotifier, List<TvSeries>>((ref) {
  return SeriesNotifier(fetchMoreSeries: ref.watch(tvSeriesRepositoryProvider).getPopular);
});

final topRatedSeriesProvider = StateNotifierProvider<SeriesNotifier, List<TvSeries>>((ref) {
  return SeriesNotifier(fetchMoreSeries: ref.watch(tvSeriesRepositoryProvider).getTopRated);
});

/// Carrusel de series: las más populares.
final seriesSlideshowProvider = Provider<List<TvSeries>>((ref) {
  return ref.watch(popularSeriesProvider).take(seriesSlideshowMaxItems).toList();
});

/// Primera página de las cuatro listas. Se repite sola al cambiar de país.
final initialSeriesLoadProvider = FutureProvider<void>((ref) async {
  final notifiers = [
    ref.watch(airingTodaySeriesProvider.notifier),
    ref.watch(onTheAirSeriesProvider.notifier),
    ref.watch(popularSeriesProvider.notifier),
    ref.watch(topRatedSeriesProvider.notifier),
  ];
  await Future.wait(notifiers.map((notifier) => notifier.loadFirstPage()));
}, retry: (retryCount, error) => null);

/// Detalle de una serie en el idioma actual.
final seriesInfoProvider = FutureProvider.family<TvSeries, int>((ref, seriesId) {
  return ref.watch(tvSeriesRepositoryProvider).getSeriesById(seriesId.toString());
}, retry: (retryCount, error) => null);

/// Reparto de una serie.
final seriesCastProvider = FutureProvider.family<List<Actor>, int>((ref, seriesId) {
  return ref.watch(tvSeriesRepositoryProvider).getCast(seriesId.toString());
}, retry: (retryCount, error) => null);

/// Clasificación de contenido de una serie en la región seleccionada.
final seriesCertificationProvider = FutureProvider.family<MovieCertification, int>((ref, seriesId) {
  return ref.watch(tvSeriesRepositoryProvider).getContentRating(seriesId.toString());
}, retry: (retryCount, error) => null);


typedef SeriesCallback = Future<List<TvSeries>> Function({ int page });

/// Lista paginada de series (mismo comportamiento que `MoviesNotifier`).
class SeriesNotifier extends StateNotifier<List<TvSeries>> {

  int currentPage = 0;
  bool isLoading = false;
  SeriesCallback fetchMoreSeries;
  Future<void>? _currentRequest;

  SeriesNotifier({ required this.fetchMoreSeries }) : super([]);

  /// Carga la primera página si todavía no existe. Lanza la excepción si
  /// falla para que la vista muestre el error con reintento.
  Future<void> loadFirstPage() async {
    if ( currentPage > 0 ) return;
    if ( _currentRequest != null ) return _currentRequest;
    await _fetchNextPage();
  }

  /// Paginación infinita: los errores se registran sin interrumpir la UI.
  Future<void> loadNextPage() async {
    if ( isLoading ) return;
    try {
      await _fetchNextPage();
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (error) {
      debugPrint('SeriesNotifier.loadNextPage: $error');
    }
  }

  Future<void> _fetchNextPage() {
    isLoading = true;
    final request = () async {
      try {
        final nextPage = currentPage + 1;
        final series = await fetchMoreSeries( page: nextPage );
        if ( !mounted ) return;
        currentPage = nextPage;
        final knownIds = state.map((tv) => tv.id).toSet();
        state = [...state, ...series.where((tv) => !knownIds.contains(tv.id))];
      } finally {
        isLoading = false;
        _currentRequest = null;
      }
    }();
    _currentRequest = request;
    return request;
  }
}
