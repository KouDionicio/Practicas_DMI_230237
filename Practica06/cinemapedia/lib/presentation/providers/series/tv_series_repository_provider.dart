import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/config/constants/environment.dart';
import 'package:cinemapedia/domain/repositories/tv_series_repository.dart';
import 'package:cinemapedia/infrastructure/datasource/tv_moviedb_datasource.dart';
import 'package:cinemapedia/infrastructure/repositories/tv_series_repository_impl.dart';
import 'package:cinemapedia/presentation/providers/settings/app_region_provider.dart';

/// Repositorio de series configurado con el idioma y la región actuales.
/// Igual que con las películas, al cambiar de país se recrea y todos los
/// providers de series vuelven a consultar TMDB.
final tvSeriesRepositoryProvider = Provider<TvSeriesRepository>((ref) {
  final region = ref.watch(appRegionProvider);
  return TvSeriesRepositoryImpl(
    TvMovieDbDatasource(
      apiKey: Environment.theMovieDbKey,
      language: region.tmdbLanguage,
      region: region.code,
    ),
  );
});
