/// Serie en las listas de TMDB (`/tv/popular`, `/tv/top_rated`, …).
class TvSeriesMovieDB {
  TvSeriesMovieDB({
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
  });

  final int id;
  final String name;
  final String originalName;
  final String originalLanguage;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final List<int> genreIds;
  final double popularity;
  final double voteAverage;
  final int voteCount;
  final DateTime? firstAirDate;

  factory TvSeriesMovieDB.fromJson(Map<String, dynamic> json) => TvSeriesMovieDB(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        originalName: json['original_name'] ?? '',
        originalLanguage: json['original_language'] ?? '',
        overview: json['overview'] ?? '',
        posterPath: json['poster_path'],
        backdropPath: json['backdrop_path'],
        genreIds: List<int>.from((json['genre_ids'] as List? ?? const []).map((x) => x)),
        popularity: (json['popularity'] ?? 0).toDouble(),
        voteAverage: (json['vote_average'] ?? 0).toDouble(),
        voteCount: json['vote_count'] ?? 0,
        firstAirDate: DateTime.tryParse(json['first_air_date']?.toString() ?? ''),
      );
}

/// Respuesta paginada de las listas de series.
class TvSeriesResponse {
  TvSeriesResponse({required this.page, required this.totalPages, required this.results});

  final int page;
  final int totalPages;
  final List<TvSeriesMovieDB> results;

  factory TvSeriesResponse.fromJson(Map<String, dynamic> json) => TvSeriesResponse(
        page: json['page'] ?? 1,
        totalPages: json['total_pages'] ?? 1,
        results: List<TvSeriesMovieDB>.from(
          (json['results'] as List? ?? const []).map((x) => TvSeriesMovieDB.fromJson(x)),
        ),
      );
}
