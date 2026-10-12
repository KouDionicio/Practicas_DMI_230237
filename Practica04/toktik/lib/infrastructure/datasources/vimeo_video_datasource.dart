import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:toktik/domain/datasources/external_video_datasource.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/domain/errors/external_video_exception.dart';
import 'package:toktik/infrastructure/datasources/external_video_http_helpers.dart';
import 'package:toktik/infrastructure/models/vimeo_video_model.dart';

class VimeoVideoDatasource implements ExternalVideoDatasource {
  VimeoVideoDatasource({required this.baseUrl, this.client});

  final Uri? baseUrl;
  final http.Client? client;

  @override
  Future<List<ExternalVideo>> search(String query) async {
    final normalizedQuery = normalizeExternalVideoQuery(query);
    if (normalizedQuery == null) return const [];

    final backendUrl = baseUrl;
    if (backendUrl == null ||
        (backendUrl.scheme != 'https' &&
            !(kDebugMode && backendUrl.scheme == 'http')) ||
        backendUrl.host.isEmpty ||
        backendUrl.userInfo.isNotEmpty ||
        backendUrl.hasQuery ||
        backendUrl.hasFragment) {
      throw const ExternalVideoConfigurationException(
        'Configura VIMEO_BACKEND_URL con una URL HTTPS; HTTP se permite '
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
    final response = await getExternalVideoResponse(
      uri,
      provider: 'Vimeo backend',
      client: client,
    );
    return collectionItems(
      response,
      provider: 'Vimeo backend',
    ).map((json) => VimeoVideoModel.fromJson(json).toEntity()).toList();
  }
}
