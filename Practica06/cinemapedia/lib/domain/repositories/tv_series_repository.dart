import 'package:cinemapedia/domain/entities/actor.dart';
import 'package:cinemapedia/domain/entities/movie_certification.dart';
import 'package:cinemapedia/domain/entities/tv_series.dart';

abstract class TvSeriesRepository {

  Future<List<TvSeries>> getAiringToday({ int page = 1 });

  Future<List<TvSeries>> getOnTheAir({ int page = 1 });

  Future<List<TvSeries>> getPopular({ int page = 1 });

  Future<List<TvSeries>> getTopRated({ int page = 1 });

  Future<TvSeries> getSeriesById( String id );

  Future<List<Actor>> getCast( String seriesId );

  Future<MovieCertification> getContentRating( String seriesId );
}
