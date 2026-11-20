/// Respuesta de `GET /tv/{series_id}`.
class TvDetails {
  TvDetails({
    required this.id,
    required this.name,
    required this.originalName,
    required this.originalLanguage,
    required this.overview,
    required this.posterPath,
    required this.backdropPath,
    required this.genres,
    required this.popularity,
    required this.voteAverage,
    required this.voteCount,
    required this.firstAirDate,
    required this.numberOfSeasons,
    required this.numberOfEpisodes,
    required this.networks,
  });

  final int id;
  final String name;
  final String originalName;
  final String originalLanguage;
  final String overview;
  final String? posterPath;
  final String? backdropPath;
  final List<String> genres;
  final double popularity;
  final double voteAverage;
  final int voteCount;
  final DateTime? firstAirDate;
  final int? numberOfSeasons;
  final int? numberOfEpisodes;
  final List<String> networks;

  static List<String> _names(Object? list) => (list as List? ?? const [])
      .map((x) => (x is Map ? x['name'] : null)?.toString() ?? '')
      .where((name) => name.isNotEmpty)
      .toList();

  factory TvDetails.fromJson(Map<String, dynamic> json) => TvDetails(
        id: json['id'] ?? 0,
        name: json['name'] ?? '',
        originalName: json['original_name'] ?? '',
        originalLanguage: json['original_language'] ?? '',
        overview: json['overview'] ?? '',
        posterPath: json['poster_path'],
        backdropPath: json['backdrop_path'],
        genres: _names(json['genres']),
        popularity: (json['popularity'] ?? 0).toDouble(),
        voteAverage: (json['vote_average'] ?? 0).toDouble(),
        voteCount: json['vote_count'] ?? 0,
        firstAirDate: DateTime.tryParse(json['first_air_date']?.toString() ?? ''),
        numberOfSeasons: json['number_of_seasons'],
        numberOfEpisodes: json['number_of_episodes'],
        networks: _names(json['networks']),
      );
}
