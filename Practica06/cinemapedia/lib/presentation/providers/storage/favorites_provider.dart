import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/domain/repositories/favorites_repository.dart';
import 'package:cinemapedia/infrastructure/datasource/shared_prefs_favorites_datasource.dart';
import 'package:cinemapedia/infrastructure/repositories/favorites_repository_impl.dart';
import 'package:cinemapedia/presentation/providers/settings/app_region_provider.dart';

final favoritesRepositoryProvider = Provider<FavoritesRepository>((ref) {
  return FavoritesRepositoryImpl(
    SharedPrefsFavoritesDatasource(ref.watch(sharedPreferencesProvider)),
  );
});

/// Lista de películas favoritas (la más reciente primero), guardada en el
/// teléfono. No depende del país: los favoritos se conservan al cambiarlo.
final favoriteMoviesProvider =
    NotifierProvider<FavoriteMoviesNotifier, List<Movie>>(FavoriteMoviesNotifier.new);

/// `true` si la película está en favoritos. Solo reconstruye los widgets de
/// esa película cuando cambia su estado.
final isFavoriteProvider = Provider.family<bool, int>((ref, movieId) {
  return ref.watch(
    favoriteMoviesProvider.select((movies) => movies.any((movie) => movie.id == movieId)),
  );
});

class FavoriteMoviesNotifier extends Notifier<List<Movie>> {
  @override
  List<Movie> build() => ref.watch(favoritesRepositoryProvider).loadFavorites();

  bool isFavorite(int movieId) => state.any((movie) => movie.id == movieId);

  /// Agrega o quita la película. Devuelve `true` si quedó como favorita.
  Future<bool> toggle(Movie movie) async {
    final wasFavorite = isFavorite(movie.id);
    state = wasFavorite
        ? state.where((m) => m.id != movie.id).toList()
        : [movie, ...state];
    await ref.read(favoritesRepositoryProvider).saveFavorites(state);
    return !wasFavorite;
  }
}
