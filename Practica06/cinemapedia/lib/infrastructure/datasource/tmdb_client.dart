import 'package:dio/dio.dart';
import 'package:cinemapedia/domain/errors/app_exception.dart';

/// Cliente HTTP compartido por los datasources de TMDB.
///
/// Centraliza la URL base, la API key, el idioma (`language`), los tiempos de
/// espera y la traducción de errores de Dio a [AppException].
/// No depende de Flutter ni de `flutter_dotenv`: la API key se inyecta desde
/// la capa de presentación.
class TmdbClient {
  static const baseUrl = 'https://api.themoviedb.org/3';
  static const imageBaseUrl = 'https://image.tmdb.org/t/p/w500';

  final String language;
  final Dio dio;

  TmdbClient({
    required String apiKey,
    required this.language,
    Dio? dio,
  }) : dio = dio ??
            Dio(BaseOptions(
              baseUrl: baseUrl,
              connectTimeout: const Duration(seconds: 10),
              receiveTimeout: const Duration(seconds: 15),
            )) {
    this.dio.options.queryParameters = {
      ...this.dio.options.queryParameters,
      'api_key': apiKey,
      'language': language,
    };
  }

  Future<Map<String, dynamic>> get(
    String path, {
    Map<String, dynamic>? queryParameters,
  }) async {
    try {
      final response = await dio.get<Map<String, dynamic>>(
        path,
        queryParameters: queryParameters,
      );
      final data = response.data;
      if (data == null) throw ServerException(response.statusCode);
      return data;
    } on DioException catch (error) {
      throw mapDioException(error);
    }
  }

  static AppException mapDioException(DioException error) {
    switch (error.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
      case DioExceptionType.connectionError:
        return const NetworkException();
      case DioExceptionType.badResponse:
        final status = error.response?.statusCode;
        if (status == 401) return const UnauthorizedException();
        if (status == 404) return const NotFoundException();
        return ServerException(status);
      default:
        // badCertificate, cancel, unknown y tipos añadidos en versiones
        // futuras de Dio (p. ej. transformTimeout).
        return error.error is AppException
            ? error.error as AppException
            : const NetworkException();
    }
  }
}
