import 'package:cinemapedia/domain/entities/movie_certification.dart';
import 'package:cinemapedia/domain/entities/tv_series.dart';
import 'package:cinemapedia/infrastructure/datasource/tmdb_client.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/content_ratings_response.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/tv_details.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/tv_series_moviedb.dart';

class TvSeriesMapper {
  // Mismas imágenes de reemplazo que MovieMapper.
  static const _noBackdrop =
      'https://sd.keepcalms.com/i-w600/keep-calm-poster-not-found.jpg';
  static const _noPoster = 'https://www.movienewz.com/img/films/poster-holder.jpg';

  static String _image(String? path, String fallback) =>
      (path != null && path.isNotEmpty) ? '${TmdbClient.imageBaseUrl}$path' : fallback;

  static TvSeries tvSeriesMovieDBToEntity(TvSeriesMovieDB tv) => TvSeries(
        id: tv.id,
        name: tv.name,
        originalName: tv.originalName,
        originalLanguage: tv.originalLanguage,
        overview: tv.overview,
        posterPath: _image(tv.posterPath, _noPoster),
        backdropPath: _image(tv.backdropPath, _noBackdrop),
        genreIds: tv.genreIds.map((e) => e.toString()).toList(),
        popularity: tv.popularity,
        voteAverage: tv.voteAverage,
        voteCount: tv.voteCount,
        firstAirDate: tv.firstAirDate,
      );

  static TvSeries tvDetailsToEntity(TvDetails tv) => TvSeries(
        id: tv.id,
        name: tv.name,
        originalName: tv.originalName,
        originalLanguage: tv.originalLanguage,
        overview: tv.overview,
        posterPath: _image(tv.posterPath, _noPoster),
        backdropPath: _image(tv.backdropPath, _noBackdrop),
        genreIds: tv.genres,
        popularity: tv.popularity,
        voteAverage: tv.voteAverage,
        voteCount: tv.voteCount,
        firstAirDate: tv.firstAirDate,
        numberOfSeasons: tv.numberOfSeasons,
        numberOfEpisodes: tv.numberOfEpisodes,
        networks: tv.networks,
      );

  /// Clasificación **exclusivamente** del país [countryCode]; nunca se toma
  /// la de otro país (misma regla que las películas).
  static MovieCertification contentRatingsToCertification(
    ContentRatingsResponse response,
    String countryCode,
  ) {
    for (final rating in response.results) {
      if (rating.iso31661.toUpperCase() == countryCode.toUpperCase() && rating.rating.isNotEmpty) {
        return MovieCertification(countryCode: countryCode, rating: rating.rating);
      }
    }
    return MovieCertification.unavailable(countryCode);
  }
}
