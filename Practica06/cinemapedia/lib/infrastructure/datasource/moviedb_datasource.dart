import 'package:cinemapedia/infrastructure/models/moviedb/movie_details.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/release_dates_response.dart';
import 'package:cinemapedia/infrastructure/datasource/tmdb_client.dart';
import 'package:cinemapedia/domain/datasources/movies_datasource.dart';
import 'package:cinemapedia/domain/entities/movie_certification.dart';
import 'package:cinemapedia/domain/entities/movie_genre.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/genres_response.dart';
import 'package:cinemapedia/infrastructure/mappers/movie_mapper.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/moviedb_response.dart';
import 'package:cinemapedia/domain/entities/movie.dart';

/// Datasource de películas de TMDB.
///
/// * [TmdbClient.language] (`es-MX`, `ja-JP`, …) localiza títulos y sinopsis.
/// * [region] (`MX`, `JP`, …) filtra carteleras/estrenos por país y define
///   qué clasificación por edad se consulta. Son dimensiones independientes.
class MoviedbDatasource extends MoviesDatasource {

  final TmdbClient client;
  final String region;

  MoviedbDatasource({
    required String apiKey,
    required String language,
    required this.region,
    TmdbClient? client,
  }) : client = client ?? TmdbClient(apiKey: apiKey, language: language);

  List<Movie> _jsonToMovies( Map<String,dynamic> json ) {

    final movieDBResponse = MovieDbResponse.fromJson(json);

    final List<Movie> movies = movieDBResponse.results
    .where((moviedb) => moviedb.posterPath.isNotEmpty )
    .map(
      (moviedb) => MovieMapper.movieDBToEntity(moviedb)
    ).toList();

    return movies;

  }

  Future<List<Movie>> _getRegionalList(String path, int page) async {
    final json = await client.get(path, queryParameters: {
      'page': page,
      'region': region,
    });
    return _jsonToMovies(json);
  }

  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) =>
      _getRegionalList('/movie/now_playing', page);

  @override
  Future<List<Movie>> getPopular({int page = 1}) =>
      _getRegionalList('/movie/popular', page);

  @override
  Future<List<Movie>> getTopRated({int page = 1}) =>
      _getRegionalList('/movie/top_rated', page);

  @override
  Future<List<Movie>> getUpcoming({int page = 1}) =>
      _getRegionalList('/movie/upcoming', page);

  @override
  Future<Movie> getMovieById( String id ) async {
    final json = await client.get('/movie/$id');
    final movieDetails = MovieDetails.fromJson( json );
    return MovieMapper.movieDetailsToEntity(movieDetails);
  }

  @override
  Future<List<Movie>> searchMovies(String query) async{

    if ( query.trim().isEmpty ) return [];

    final json = await client.get('/search/movie', queryParameters: {
      'query': query,
      'region': region,
    });

    return _jsonToMovies(json);
  }

  @override
  Future<MovieCertification> getCertification(String movieId) async {
    final json = await client.get('/movie/$movieId/release_dates');
    return MovieMapper.releaseDatesToCertification(
      ReleaseDatesResponse.fromJson(json),
      region,
    );
  }

  @override
  Future<List<MovieGenre>> getGenres() async {
    final json = await client.get('/genre/movie/list');
    return GenresResponse.fromJson(json).genres
        .where((genre) => genre.name.isNotEmpty)
        .map((genre) => MovieGenre(id: genre.id, name: genre.name))
        .toList();
  }

  @override
  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) async {
    final json = await client.get('/discover/movie', queryParameters: {
      'with_genres': genreId,
      'page': page,
      'region': region,
      'sort_by': 'popularity.desc',
      'include_adult': false,
    });
    return _jsonToMovies(json);
  }
}
