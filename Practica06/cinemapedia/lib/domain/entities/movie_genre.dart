/// Género de película de TMDB (Acción, アクション, أكشن…).
/// El nombre llega ya traducido según el idioma de la consulta.
class MovieGenre {
  final int id;
  final String name;

  const MovieGenre({required this.id, required this.name});
}
