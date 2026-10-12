import 'package:http/http.dart' as http;
import 'package:toktik/domain/datasources/external_video_datasource.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/domain/errors/external_video_exception.dart';
import 'package:toktik/infrastructure/datasources/external_video_http_helpers.dart';
import 'package:toktik/infrastructure/models/dailymotion_video_model.dart';

class DailymotionVideoDatasource implements ExternalVideoDatasource {
  DailymotionVideoDatasource({
    required this.apiKey,
    required this.playerId,
    this.client,
  });

  final String? apiKey;
  final String? playerId;
  final http.Client? client;

  @override
  Future<List<ExternalVideo>> search(String query) async {
    final normalizedQuery = normalizeExternalVideoQuery(query);
    if (normalizedQuery == null) return const [];

    final key = apiKey?.trim();
    if (key == null || key.isEmpty) {
      throw const ExternalVideoConfigurationException(
        'Configura DAILYMOTION_API_KEY con una Public API key de Dailymotion.',
      );
    }
    if (key.length > 512 || key.contains(RegExp(r'[\x00-\x1F\x7F]'))) {
      throw const ExternalVideoConfigurationException(
        'DAILYMOTION_API_KEY tiene un formato no válido.',
      );
    }

    final player = playerId?.trim();
    if (player == null || player.isEmpty) {
      throw const ExternalVideoConfigurationException(
        'Configura DAILYMOTION_PLAYER_ID desde un Player creado o elegido en '
        'Dailymotion Studio.',
      );
    }
    if (!RegExp(r'^[A-Za-z0-9_-]+$').hasMatch(player)) {
      throw const ExternalVideoConfigurationException(
        'DAILYMOTION_PLAYER_ID tiene un formato no válido.',
      );
    }

    final uri = Uri.https('api.dailymotion.com', '/videos', {
      'search': normalizedQuery,
      'page': '1',
      'limit': '25',
      'fields': 'id,title,description,thumbnail_720_url,duration,embed_url,url',
      'api_key': key,
    });
    final client = this.client;
    final response = await getExternalVideoResponse(
      uri,
      provider: 'Dailymotion',
      client: client,
    );

    return collectionItems(
          response,
          provider: 'Dailymotion',
          collectionKey: 'list',
        )
        .map((json) {
          return DailymotionVideoModel.fromJson(json)
              .toEntity(playerId: player);
        })
        .toList(growable: false);
  }
}
