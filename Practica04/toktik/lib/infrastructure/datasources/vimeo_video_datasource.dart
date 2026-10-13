import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:toktik/domain/datasources/external_video_datasource.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/domain/errors/external_video_exception.dart';
import 'package:toktik/infrastructure/datasources/external_video_http_helpers.dart';
import 'package:toktik/infrastructure/models/vimeo_video_model.dart';

class VimeoVideoDatasource implements ExternalVideoDatasource {
  VimeoVideoDatasource({
    required this.baseUrl,
    this.token,
    this.client,
  });

  final Uri? baseUrl;
  final String? token;
  final http.Client? client;

  @override
  Future<List<ExternalVideo>> search(String query) async {
    final normalizedQuery = normalizeExternalVideoQuery(query);
    if (normalizedQuery == null) return const [];

    final backendUrl = baseUrl;
    if (backendUrl == null) return _searchVimeoApi(normalizedQuery);

    if ((backendUrl.scheme != 'https' &&
            !(kDebugMode && backendUrl.scheme == 'http')) ||
        backendUrl.host.isEmpty ||
        backendUrl.userInfo.isNotEmpty ||
        backendUrl.hasQuery ||
        backendUrl.hasFragment) {
      throw const ExternalVideoConfigurationException(
        'Configura BACKEND_BASE_URL con una URL HTTPS; HTTP se permite '
        'solo en modo debug local.',
      );
    }

    final uri = backendUrl.replace(
      path:
          '${backendUrl.path.replaceFirst(RegExp(r'/$'), '')}'
          '/api/vimeo/search',
      queryParameters: {'query': normalizedQuery},
    );
    final client = this.client;
    try {
      final response = await getExternalVideoResponse(
        uri,
        provider: 'Vimeo backend',
        client: client,
      );
      return _mapResults(response, provider: 'Vimeo backend');
    } on ExternalVideoNetworkException {
      final key = token?.trim();
      if (key == null || key.isEmpty) {
        throw const ExternalVideoConfigurationException(
          'No se pudo conectar con el backend de Vimeo y VIMEO_TOKEN no está '
          'configurado para la conexión directa.',
        );
      }
      return _searchVimeoApi(normalizedQuery);
    }
  }

  Future<List<ExternalVideo>> _searchVimeoApi(String query) async {
    final key = token?.trim();
    if (key == null || key.isEmpty) {
      throw const ExternalVideoConfigurationException(
        'Configura VIMEO_TOKEN con un token de solo lectura para usar Vimeo '
        'directamente, o configura BACKEND_BASE_URL.',
      );
    }

    final uri = Uri.https('api.vimeo.com', '/videos', {
      'query': query,
      'per_page': '25',
      'fields': 'uri,name,description,pictures.sizes.link',
    });
    final response = await getExternalVideoResponse(
      uri,
      provider: 'Vimeo',
      client: client,
      headers: {
        'Accept': 'application/vnd.vimeo.*+json;version=3.4',
        'Authorization': 'Bearer $key',
      },
    );
    return _mapResults(response, provider: 'Vimeo');
  }

  List<ExternalVideo> _mapResults(
    http.Response response, {
    required String provider,
  }) {
    return collectionItems(response, provider: provider)
        .map((json) => VimeoVideoModel.fromJson(json).toEntity())
        .toList();
  }
}
