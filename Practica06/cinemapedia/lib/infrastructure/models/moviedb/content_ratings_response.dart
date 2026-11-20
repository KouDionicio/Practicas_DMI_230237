/// Respuesta de `GET /tv/{series_id}/content_ratings`.
class ContentRatingsResponse {
  ContentRatingsResponse({required this.results});

  final List<ContentRating> results;

  factory ContentRatingsResponse.fromJson(Map<String, dynamic> json) => ContentRatingsResponse(
        results: List<ContentRating>.from(
          (json['results'] as List? ?? const []).map((x) => ContentRating.fromJson(x)),
        ),
      );
}

class ContentRating {
  ContentRating({required this.iso31661, required this.rating});

  final String iso31661;
  final String rating;

  factory ContentRating.fromJson(Map<String, dynamic> json) => ContentRating(
        iso31661: json['iso_3166_1'] ?? '',
        rating: (json['rating'] ?? '').toString().trim(),
      );
}
