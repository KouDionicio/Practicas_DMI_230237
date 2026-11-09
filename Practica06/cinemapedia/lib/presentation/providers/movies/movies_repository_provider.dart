import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/config/constants/environment.dart';
import 'package:cinemapedia/domain/repositories/movies_repository.dart';
import 'package:cinemapedia/infrastructure/datasource/moviedb_datasource.dart';
import 'package:cinemapedia/infrastructure/repositories/movie_repository_impl.dart';
import 'package:cinemapedia/presentation/providers/settings/app_region_provider.dart';

/// Repositorio de películas configurado con el idioma y la región actuales.
///
/// Al cambiar de país se crea un repositorio nuevo y todos los providers que
/// lo observan (listas, detalle, búsqueda, clasificaciones) se reinician y
/// vuelven a consultar TMDB con los parámetros correctos.
final movieRepositoryProvider = Provider<MoviesRepository>((ref) {
  final region = ref.watch(appRegionProvider);
  return MovieRepositoryImpl(
    MoviedbDatasource(
      apiKey: Environment.theMovieDbKey,
      language: region.tmdbLanguage,
      region: region.code,
    ),
  );
});
