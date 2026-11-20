import 'package:cinemapedia/domain/datasources/tv_series_datasource.dart';
import 'package:cinemapedia/domain/entities/actor.dart';
import 'package:cinemapedia/domain/entities/movie_certification.dart';
import 'package:cinemapedia/domain/entities/tv_series.dart';
import 'package:cinemapedia/domain/repositories/tv_series_repository.dart';

class TvSeriesRepositoryImpl extends TvSeriesRepository {

  final TvSeriesDatasource datasource;

  TvSeriesRepositoryImpl(this.datasource);

  @override
  Future<List<TvSeries>> getAiringToday({int page = 1}) => datasource.getAiringToday(page: page);

  @override
  Future<List<TvSeries>> getOnTheAir({int page = 1}) => datasource.getOnTheAir(page: page);

  @override
  Future<List<TvSeries>> getPopular({int page = 1}) => datasource.getPopular(page: page);

  @override
  Future<List<TvSeries>> getTopRated({int page = 1}) => datasource.getTopRated(page: page);

  @override
  Future<TvSeries> getSeriesById(String id) => datasource.getSeriesById(id);

  @override
  Future<List<Actor>> getCast(String seriesId) => datasource.getCast(seriesId);

  @override
  Future<MovieCertification> getContentRating(String seriesId) => datasource.getContentRating(seriesId);
}
