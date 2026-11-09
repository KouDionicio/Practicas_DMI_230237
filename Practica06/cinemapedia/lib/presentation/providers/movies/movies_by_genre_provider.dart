import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';

import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/domain/entities/movie_genre.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_providers.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';

/// Géneros de TMDB en el idioma actual. Al cambiar de país se vuelven a pedir
/// (los nombres cambian de idioma; los ids son los mismos en todo el mundo).
final movieGenresProvider = FutureProvider<List<MovieGenre>>((ref) {
  return ref.watch(movieRepositoryProvider).getGenres();
}, retry: (retryCount, error) => null);

/// Películas de un género con paginación infinita. Reutiliza [MoviesNotifier],
/// el mismo de las listas de Inicio.
final moviesByGenreProvider =
    StateNotifierProvider.family<MoviesNotifier, List<Movie>, int>((ref, genreId) {
  final repository = ref.watch(movieRepositoryProvider);
  return MoviesNotifier(
    fetchMoreMovies: ({int page = 1}) => repository.getMoviesByGenre(genreId, page: page),
  );
});

/// Primera página de un género (permite mostrar carga, error y reintento).
final genreFirstPageProvider = FutureProvider.family<void, int>((ref, genreId) {
  return ref.watch(moviesByGenreProvider(genreId).notifier).loadFirstPage();
}, retry: (retryCount, error) => null);
