/// Clasificación por edad de una película para un país concreto.
///
/// [rating] es `null` cuando TMDB no tiene una clasificación para ese país.
/// Nunca se rellena con la clasificación de otro país.
class MovieCertification {
  final String countryCode;
  final String? rating;

  const MovieCertification({required this.countryCode, required this.rating});

  const MovieCertification.unavailable(this.countryCode) : rating = null;

  bool get isAvailable => rating != null && rating!.isNotEmpty;
}
