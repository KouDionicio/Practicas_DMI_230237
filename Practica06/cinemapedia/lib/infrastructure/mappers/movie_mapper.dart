import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/domain/entities/movie_certification.dart';
import 'package:cinemapedia/infrastructure/datasource/tmdb_client.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/movie_details.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/movie_moviedb.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/release_dates_response.dart';

class MovieMapper {
  static const _noBackdrop =
      'https://sd.keepcalms.com/i-w600/keep-calm-poster-not-found.jpg';
  static const _noPoster = 'https://www.movienewz.com/img/films/poster-holder.jpg';

  static String _image(String? path, String fallback) =>
      (path != null && path.isNotEmpty) ? '${TmdbClient.imageBaseUrl}$path' : fallback;

  static Movie movieDBToEntity(MovieMovieDB moviedb) => Movie(
      adult: moviedb.adult,
      backdropPath: _image(moviedb.backdropPath, _noBackdrop),
      genreIds: moviedb.genreIds.map((e) => e.toString()).toList(),
      id: moviedb.id,
      originalLanguage: moviedb.originalLanguage,
      originalTitle: moviedb.originalTitle,
      overview: moviedb.overview,
      popularity: moviedb.popularity,
      posterPath: _image(moviedb.posterPath, _noPoster),
      releaseDate: moviedb.releaseDate,
      title: moviedb.title,
      video: moviedb.video,
      voteAverage: moviedb.voteAverage,
      voteCount: moviedb.voteCount
    );

  static Movie movieDetailsToEntity( MovieDetails moviedb ) => Movie(
      adult: moviedb.adult,
      backdropPath: _image(moviedb.backdropPath, _noBackdrop),
      genreIds: moviedb.genres.map((e) => e.name ).toList(),
      id: moviedb.id,
      originalLanguage: moviedb.originalLanguage,
      originalTitle: moviedb.originalTitle,
      overview: moviedb.overview,
      popularity: moviedb.popularity,
      posterPath: _image(moviedb.posterPath, _noBackdrop),
      releaseDate: moviedb.releaseDate,
      title: moviedb.title,
      video: moviedb.video,
      voteAverage: moviedb.voteAverage,
      voteCount: moviedb.voteCount
    );

  /// Preferencia de tipos de estreno al elegir la clasificación:
  /// cines (3), estreno limitado (2), digital (4), físico (5), TV (6), premier (1).
  static const _releaseTypePriority = [3, 2, 4, 5, 6, 1];

  /// Extrae la clasificación **exclusivamente** del país [countryCode].
  /// Si ese país no tiene clasificación, devuelve una no disponible: nunca
  /// reutiliza ni convierte la de otro país.
  static MovieCertification releaseDatesToCertification(
    ReleaseDatesResponse response,
    String countryCode,
  ) {
    final candidates = response.results
        .where((country) => country.iso31661.toUpperCase() == countryCode.toUpperCase())
        .expand((country) => country.releaseDates)
        .where((release) => release.certification.isNotEmpty)
        .toList();

    if (candidates.isEmpty) return MovieCertification.unavailable(countryCode);

    int priority(ReleaseDate release) {
      final index = _releaseTypePriority.indexOf(release.type);
      return index == -1 ? _releaseTypePriority.length : index;
    }

    candidates.sort((a, b) => priority(a).compareTo(priority(b)));
    return MovieCertification(
      countryCode: countryCode,
      rating: candidates.first.certification,
    );
  }
}
