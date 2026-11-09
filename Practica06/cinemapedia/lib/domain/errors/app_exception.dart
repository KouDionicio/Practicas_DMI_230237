/// Errores de dominio que la capa de presentación sabe traducir a mensajes
/// localizados, sin depender de la librería HTTP utilizada.
sealed class AppException implements Exception {
  const AppException();
}

/// Sin conexión, tiempo de espera agotado o servidor inalcanzable.
class NetworkException extends AppException {
  const NetworkException();
}

/// La API key de TMDB falta o no es válida (HTTP 401).
class UnauthorizedException extends AppException {
  const UnauthorizedException();
}

/// El recurso solicitado no existe (HTTP 404).
class NotFoundException extends AppException {
  const NotFoundException();
}

/// Cualquier otra respuesta inesperada del servidor.
class ServerException extends AppException {
  final int? statusCode;
  const ServerException([this.statusCode]);
}
