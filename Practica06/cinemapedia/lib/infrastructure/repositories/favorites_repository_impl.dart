import 'package:cinemapedia/domain/datasources/favorites_datasource.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl extends FavoritesRepository {
  final FavoritesDatasource datasource;

  FavoritesRepositoryImpl(this.datasource);

  @override
  List<Movie> loadFavorites() => datasource.loadFavorites();

  @override
  Future<void> saveFavorites(List<Movie> movies) => datasource.saveFavorites(movies);
}
