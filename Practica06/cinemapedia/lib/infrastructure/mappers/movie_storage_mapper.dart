import 'package:cinemapedia/domain/entities/movie.dart';

/// Convierte películas a JSON para guardarlas en el teléfono y viceversa.
class MovieStorageMapper {
  static Map<String, dynamic> toJson(Movie movie) => {
        'adult': movie.adult,
        'backdropPath': movie.backdropPath,
        'genreIds': movie.genreIds,
        'id': movie.id,
        'originalLanguage': movie.originalLanguage,
        'originalTitle': movie.originalTitle,
        'overview': movie.overview,
        'popularity': movie.popularity,
        'posterPath': movie.posterPath,
        'releaseDate': movie.releaseDate?.toIso8601String(),
        'title': movie.title,
        'video': movie.video,
        'voteAverage': movie.voteAverage,
        'voteCount': movie.voteCount,
      };

  static Movie fromJson(Map<String, dynamic> json) => Movie(
        adult: json['adult'] ?? false,
        backdropPath: json['backdropPath'] ?? '',
        genreIds: List<String>.from(json['genreIds'] ?? const []),
        id: json['id'] ?? 0,
        originalLanguage: json['originalLanguage'] ?? '',
        originalTitle: json['originalTitle'] ?? '',
        overview: json['overview'] ?? '',
        popularity: (json['popularity'] ?? 0).toDouble(),
        posterPath: json['posterPath'] ?? '',
        releaseDate: DateTime.tryParse(json['releaseDate'] ?? ''),
        title: json['title'] ?? '',
        video: json['video'] ?? false,
        voteAverage: (json['voteAverage'] ?? 0).toDouble(),
        voteCount: json['voteCount'] ?? 0,
      );
}
