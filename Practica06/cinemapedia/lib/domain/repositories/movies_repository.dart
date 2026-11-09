import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/domain/entities/movie_certification.dart';


abstract class MoviesRepository {

  Future<List<Movie>> getNowPlaying({ int page = 1 });

  Future<List<Movie>> getPopular({ int page = 1 });
  
  Future<List<Movie>> getUpcoming({ int page = 1 });

  Future<List<Movie>> getTopRated({ int page = 1 });

  Future<Movie> getMovieById( String id );

  Future<List<Movie>> searchMovies( String query );

  /// Clasificación por edad de la película en la región configurada.
  Future<MovieCertification> getCertification( String movieId );
}
