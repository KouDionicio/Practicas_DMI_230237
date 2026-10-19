import 'package:flutter/foundation.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:toktik/domain/datasources/external_video_datasource.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/domain/entities/external_video_page.dart';
import 'package:toktik/domain/errors/external_video_exception.dart';
import 'package:toktik/infrastructure/datasources/external_video_http_helpers.dart';
import 'package:toktik/infrastructure/models/vimeo_video_model.dart';

class VimeoVideoDatasource implements PaginatedExternalVideoDatasource {
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
    return (await searchPage(query)).videos;
  }

  @override
  Future<ExternalVideoPage> searchPage(String query, {String? pageToken}) async {
    final normalizedQuery = normalizeExternalVideoQuery(query);
    if (normalizedQuery == null) return const ExternalVideoPage([]);

    final backendUrl = baseUrl;
    final page = int.tryParse(pageToken ?? '') ?? 1;
    if (backendUrl == null) return _searchVimeoApi(normalizedQuery, page);

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
      queryParameters: {'query': normalizedQuery, 'page': '$page', 'per_page': '25'},
    );
    final client = this.client;
    try {
      final response = await getExternalVideoResponse(
        uri,
        provider: 'Vimeo backend',
        client: client,
      );
      final videos = await _mapResults(response, provider: 'Vimeo backend');
      final hasMore = _hasNextPage(response) ?? videos.length >= 25;
      return ExternalVideoPage(
        videos,
        nextPageToken: hasMore ? '${page + 1}' : null,
      );
    } on ExternalVideoNetworkException {
      final key = token?.trim();
      if (key == null || key.isEmpty) {
        throw const ExternalVideoConfigurationException(
          'No se pudo conectar con el backend de Vimeo y VIMEO_TOKEN no está '
          'configurado para la conexión directa.',
        );
      }
      return _searchVimeoApi(normalizedQuery, page);
    }
  }

  Future<ExternalVideoPage> _searchVimeoApi(String query, int page) async {
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
      'page': '$page',
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
    final videos = await _mapResults(response, provider: 'Vimeo');
    final hasMore = _hasNextPage(response) ?? videos.length >= 25;
    return ExternalVideoPage(videos, nextPageToken: hasMore ? '${page + 1}' : null);
  }

  bool? _hasNextPage(http.Response response) {
    final decoded = jsonDecode(response.body);
    if (decoded is! Map<String, dynamic>) return null;
    final paging = decoded['paging'];
    if (paging is! Map<String, dynamic> || !paging.containsKey('next')) {
      return null;
    }
    final next = paging['next'];
    return next is String && next.isNotEmpty;
  }

  Future<List<ExternalVideo>> _mapResults(
    http.Response response, {
    required String provider,
  }) async {
    final models = collectionItems(response, provider: provider)
        .map(VimeoVideoModel.fromJson)
        .toList(growable: false);
    final validated = await Future.wait(models.map((model) async {
      try {
        final oEmbedUri = Uri.https('vimeo.com', '/api/oembed.json', {
          'url': model.toEntity().watchUrl.toString(),
        });
        final result = await getExternalVideoResponse(
          oEmbedUri,
          provider: 'Vimeo oEmbed',
          client: client,
        );
        if (result.statusCode < 200 || result.statusCode >= 300) return null;
        final decoded = jsonDecode(result.body);
        if (decoded is! Map<String, dynamic> ||
            decoded['html'] is! String ||
            (decoded['html'] as String).isEmpty) {
          return null;
        }
        final thumbnail = decoded['thumbnail_url'];
        return model.toEntity(
          oEmbedThumbnailUrl: thumbnail is String && thumbnail.isNotEmpty
              ? thumbnail
              : null,
        );
      } catch (_) {
        return null;
      }
    }));
    return validated.whereType<ExternalVideo>().toList(growable: false);
  }
}
