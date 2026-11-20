/// Zona horaria de referencia de cada país para los endpoints de series de
/// TMDB `airing_today` y `on_the_air`, que aceptan `timezone` (no `region`):
/// define qué es "hoy" y "los próximos 7 días" en ese país.
///
/// Archivo independiente para no modificar la configuración de regiones.
abstract final class TvTimezones {
  static const _byRegion = <String, String>{
    'MX': 'America/Mexico_City',
    'US': 'America/New_York',
    'DE': 'Europe/Berlin',
    'FR': 'Europe/Paris',
    'KR': 'Asia/Seoul',
    'JP': 'Asia/Tokyo',
    'BR': 'America/Sao_Paulo',
    'EG': 'Africa/Cairo',
  };

  /// Zona horaria para [regionCode], o `null` si el país no está configurado
  /// (en ese caso TMDB usa su valor por defecto).
  static String? forRegion(String regionCode) => _byRegion[regionCode.toUpperCase()];
}
