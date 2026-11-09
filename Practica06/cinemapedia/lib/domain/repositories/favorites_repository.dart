import 'package:cinemapedia/domain/entities/movie.dart';

abstract class FavoritesRepository {
  List<Movie> loadFavorites();

  Future<void> saveFavorites(List<Movie> movies);
}
