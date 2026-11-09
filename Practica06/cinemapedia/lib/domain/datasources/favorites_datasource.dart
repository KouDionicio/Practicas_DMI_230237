import 'package:cinemapedia/domain/entities/movie.dart';

/// Almacenamiento local de las películas favoritas.
abstract class FavoritesDatasource {
  /// Favoritos guardados, del más reciente al más antiguo.
  List<Movie> loadFavorites();

  Future<void> saveFavorites(List<Movie> movies);
}
