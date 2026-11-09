/// Respuesta de `GET /movie/{movie_id}/release_dates`.
class ReleaseDatesResponse {
  ReleaseDatesResponse({required this.id, required this.results});

  final int id;
  final List<CountryReleaseDates> results;

  factory ReleaseDatesResponse.fromJson(Map<String, dynamic> json) =>
      ReleaseDatesResponse(
        id: json['id'] ?? 0,
        results: List<CountryReleaseDates>.from(
          (json['results'] as List? ?? const [])
              .map((x) => CountryReleaseDates.fromJson(x)),
        ),
      );
}

class CountryReleaseDates {
  CountryReleaseDates({required this.iso31661, required this.releaseDates});

  final String iso31661;
  final List<ReleaseDate> releaseDates;

  factory CountryReleaseDates.fromJson(Map<String, dynamic> json) =>
      CountryReleaseDates(
        iso31661: json['iso_3166_1'] ?? '',
        releaseDates: List<ReleaseDate>.from(
          (json['release_dates'] as List? ?? const [])
              .map((x) => ReleaseDate.fromJson(x)),
        ),
      );
}

class ReleaseDate {
  ReleaseDate({required this.certification, required this.type});

  final String certification;

  /// 1 Premiere, 2 Theatrical (limited), 3 Theatrical, 4 Digital,
  /// 5 Physical, 6 TV.
  final int type;

  factory ReleaseDate.fromJson(Map<String, dynamic> json) => ReleaseDate(
        certification: (json['certification'] ?? '').toString().trim(),
        type: json['type'] ?? 0,
      );
}
