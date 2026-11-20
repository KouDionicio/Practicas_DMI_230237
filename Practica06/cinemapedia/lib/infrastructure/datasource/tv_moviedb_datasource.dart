import 'package:cinemapedia/config/constants/tv_timezones.dart';
import 'package:cinemapedia/domain/datasources/tv_series_datasource.dart';
import 'package:cinemapedia/domain/entities/actor.dart';
import 'package:cinemapedia/domain/entities/movie_certification.dart';
import 'package:cinemapedia/domain/entities/tv_series.dart';
import 'package:cinemapedia/infrastructure/datasource/tmdb_client.dart';
import 'package:cinemapedia/infrastructure/mappers/actor_mapper.dart';
import 'package:cinemapedia/infrastructure/mappers/tv_series_mapper.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/content_ratings_response.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/credits_response.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/tv_details.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/tv_series_moviedb.dart';

/// Datasource de series de TMDB. Comparte [TmdbClient] con las películas
/// (misma API key, `language`, tiempos de espera y manejo de errores).
///
/// * `language` localiza nombres y sinopsis.
/// * [region] define la clasificación que se consulta y, mediante
///   `timezone`, qué es "hoy" en `airing_today` y `on_the_air`.
class TvMovieDbDatasource extends TvSeriesDatasource {

  final TmdbClient client;
  final String region;

  TvMovieDbDatasource({
    required String apiKey,
    required String language,
    required this.region,
    TmdbClient? client,
  }) : client = client ?? TmdbClient(apiKey: apiKey, language: language);

  List<TvSeries> _jsonToSeries(Map<String, dynamic> json) {
    return TvSeriesResponse.fromJson(json).results
        .where((tv) => tv.posterPath != null && tv.posterPath!.isNotEmpty)
        .map(TvSeriesMapper.tvSeriesMovieDBToEntity)
        .toList();
  }

  Future<List<TvSeries>> _getList(String path, int page, {bool withTimezone = false}) async {
    final timezone = withTimezone ? TvTimezones.forRegion(region) : null;
    final json = await client.get(path, queryParameters: {
      'page': page,
      if (timezone != null) 'timezone': timezone,
    });
    return _jsonToSeries(json);
  }

  @override
  Future<List<TvSeries>> getAiringToday({int page = 1}) =>
      _getList('/tv/airing_today', page, withTimezone: true);

  @override
  Future<List<TvSeries>> getOnTheAir({int page = 1}) =>
      _getList('/tv/on_the_air', page, withTimezone: true);

  @override
  Future<List<TvSeries>> getPopular({int page = 1}) => _getList('/tv/popular', page);

  @override
  Future<List<TvSeries>> getTopRated({int page = 1}) => _getList('/tv/top_rated', page);

  @override
  Future<TvSeries> getSeriesById(String id) async {
    final json = await client.get('/tv/$id');
    return TvSeriesMapper.tvDetailsToEntity(TvDetails.fromJson(json));
  }

  @override
  Future<List<Actor>> getCast(String seriesId) async {
    final json = await client.get('/tv/$seriesId/credits');
    return CreditsResponse.fromJson(json).cast.map(ActorMapper.castToEntity).toList();
  }

  @override
  Future<MovieCertification> getContentRating(String seriesId) async {
    final json = await client.get('/tv/$seriesId/content_ratings');
    return TvSeriesMapper.contentRatingsToCertification(
      ContentRatingsResponse.fromJson(json),
      region,
    );
  }
}
