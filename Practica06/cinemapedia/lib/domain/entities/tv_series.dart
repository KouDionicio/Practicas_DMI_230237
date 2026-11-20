/// Serie de televisión de TMDB.
///
/// Equivalente a [Movie] para contenido televisivo: `name` es el título
/// localizado, `originalName` el título original y `firstAirDate` la fecha de
/// la primera emisión. Los campos de temporadas, episodios y cadenas solo
/// llegan en el detalle (`/tv/{id}`); en las listas quedan vacíos.
class TvSeries {
  final int id;
  final String name;
  final String originalName;
  final String originalLanguage;
  final String overview;
  final String posterPath;
  final String backdropPath;
  final List<String> genreIds;
  final double popularity;
  final double voteAverage;
  final int voteCount;

  /// `null` cuando TMDB no tiene fecha de primera emisión.
  final DateTime? firstAirDate;

  final int? numberOfSeasons;
  final int? numberOfEpisodes;
  final List<String> networks;

  TvSeries({
    required this.id,
    required this.name,
    required this.originalName,
    required this.originalLanguage,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.genreIds,
    required this.popularity,
    required this.voteAverage,
    required this.voteCount,
    required this.firstAirDate,
    this.numberOfSeasons,
    this.numberOfEpisodes,
    this.networks = const [],
  });
}
