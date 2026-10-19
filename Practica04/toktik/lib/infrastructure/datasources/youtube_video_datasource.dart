import 'package:http/http.dart' as http;
import 'package:toktik/domain/datasources/external_video_datasource.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/domain/entities/external_video_page.dart';
import 'package:toktik/domain/errors/external_video_exception.dart';
import 'package:toktik/infrastructure/datasources/external_video_http_helpers.dart';
import 'package:toktik/infrastructure/models/youtube_video_model.dart';

class YouTubeVideoDatasource implements PaginatedExternalVideoDatasource {
  YouTubeVideoDatasource({required this.apiKey, this.client});

  final String? apiKey;
  final http.Client? client;

  @override
  Future<List<ExternalVideo>> search(String query) async =>
      (await searchPage(query)).videos;

  @override
  Future<ExternalVideoPage> searchPage(
    String query, {
    String? pageToken,
  }) async {
    final normalizedQuery = normalizeExternalVideoQuery(query);
    if (normalizedQuery == null) return const ExternalVideoPage([]);
    final key = apiKey?.trim();
    if (key == null || key.isEmpty) {
      throw const ExternalVideoConfigurationException(
        'Configura YOUTUBE_API_KEY con una clave de YouTube Data API v3.',
      );
    }

    // No se filtran por duración ni se fuerza #shorts: ambos reducen demasiado
    // los resultados y excluyen videos que sí pueden insertarse.
    final parameters = <String, String>{
      'part': 'snippet',
      'type': 'video',
      'videoEmbeddable': 'true',
      'videoSyndicated': 'true',
      'regionCode': 'MX',
      'relevanceLanguage': 'es',
      'maxResults': '50',
      'q': normalizedQuery,
      'key': key,
      if (pageToken != null && pageToken.isNotEmpty) 'pageToken': pageToken,
    };
    final uri = Uri.https(
      'www.googleapis.com',
      '/youtube/v3/search',
      parameters,
    );
    final response = await getExternalVideoResponse(
      uri,
      provider: 'YouTube',
      client: client,
    );
    final decoded = decodeCollection(
      response,
      provider: 'YouTube',
      collectionKey: 'items',
    );
    final videos = (decoded['items'] as List<dynamic>)
        .cast<Map<String, dynamic>>()
        .map((json) => YouTubeVideoModel.fromJson(json).toEntity())
        .toList();
    final token = decoded['nextPageToken'];
    return ExternalVideoPage(
      videos,
      nextPageToken: token is String && token.isNotEmpty ? token : null,
    );
  }
}
