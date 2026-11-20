import 'package:cinemapedia/domain/entities/actor.dart';
import 'package:cinemapedia/domain/entities/movie_certification.dart';
import 'package:cinemapedia/domain/entities/tv_series.dart';

/// Origen de datos de series de televisión.
abstract class TvSeriesDatasource {

  /// Series que emiten un episodio hoy (según la zona horaria del país).
  Future<List<TvSeries>> getAiringToday({ int page = 1 });

  /// Series con episodios en los próximos 7 días.
  Future<List<TvSeries>> getOnTheAir({ int page = 1 });

  Future<List<TvSeries>> getPopular({ int page = 1 });

  Future<List<TvSeries>> getTopRated({ int page = 1 });

  Future<TvSeries> getSeriesById( String id );

  /// Reparto principal de la serie.
  Future<List<Actor>> getCast( String seriesId );

  /// Clasificación de contenido en el país configurado. Reutiliza
  /// [MovieCertification]: mismo concepto (país + clasificación o ninguna).
  Future<MovieCertification> getContentRating( String seriesId );
}
