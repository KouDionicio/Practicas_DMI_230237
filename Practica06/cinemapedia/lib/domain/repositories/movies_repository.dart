import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/domain/entities/movie_certification.dart';
import 'package:cinemapedia/domain/entities/movie_genre.dart';


abstract class MoviesRepository {

  Future<List<Movie>> getNowPlaying({ int page = 1 });

  Future<List<Movie>> getPopular({ int page = 1 });
  
  Future<List<Movie>> getUpcoming({ int page = 1 });

  Future<List<Movie>> getTopRated({ int page = 1 });

  Future<Movie> getMovieById( String id );

  Future<List<Movie>> searchMovies( String query );

  /// Clasificación por edad de la película en la región configurada.
  Future<MovieCertification> getCertification( String movieId );

  /// Géneros disponibles, traducidos al idioma configurado.
  Future<List<MovieGenre>> getGenres();

  /// Películas de un género en la región configurada (más populares primero).
  Future<List<Movie>> getMoviesByGenre( int genreId, { int page = 1 } );
}
