/// Respuesta de `GET /genre/movie/list`.
class GenresResponse {
  GenresResponse({required this.genres});

  final List<GenreItem> genres;

  factory GenresResponse.fromJson(Map<String, dynamic> json) => GenresResponse(
        genres: List<GenreItem>.from(
          (json['genres'] as List? ?? const []).map((x) => GenreItem.fromJson(x)),
        ),
      );
}

class GenreItem {
  GenreItem({required this.id, required this.name});

  final int id;
  final String name;

  factory GenreItem.fromJson(Map<String, dynamic> json) => GenreItem(
        id: json['id'] ?? 0,
        name: (json['name'] ?? '').toString(),
      );
}
