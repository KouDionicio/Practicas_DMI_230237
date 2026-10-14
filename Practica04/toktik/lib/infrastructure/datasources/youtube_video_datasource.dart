import 'package:http/http.dart' as http;
import 'package:toktik/domain/datasources/external_video_datasource.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/domain/errors/external_video_exception.dart';
import 'package:toktik/infrastructure/datasources/external_video_http_helpers.dart';
import 'package:toktik/infrastructure/models/youtube_video_model.dart';

class YouTubeVideoDatasource implements ExternalVideoDatasource {
  YouTubeVideoDatasource({required this.apiKey, this.client});

  final String? apiKey;
  final http.Client? client;

  @override
  Future<List<ExternalVideo>> search(String query) async {
    final normalizedQuery = normalizeExternalVideoQuery(query);
    if (normalizedQuery == null) return const [];

    final key = apiKey?.trim();
    if (key == null || key.isEmpty) {
      throw const ExternalVideoConfigurationException(
        'Configura YOUTUBE_API_KEY con una clave de YouTube Data API v3 '
        'restringida a esta aplicación.',
      );
    }
    final uri = Uri.https('www.googleapis.com', '/youtube/v3/search', {
      'part': 'snippet',
      'type': 'video',
      'videoEmbeddable': 'true',
      'videoSyndicated': 'true',
      'maxResults': '25',
      'q': normalizedQuery,
      'key': key,
    });
    final client = this.client;
    final response = await getExternalVideoResponse(
      uri,
      provider: 'YouTube',
      client: client,
    );
    return collectionItems(
      response,
      provider: 'YouTube',
      collectionKey: 'items',
    ).map((json) => YouTubeVideoModel.fromJson(json).toEntity()).toList();
  }
}
