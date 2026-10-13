import 'package:http/http.dart' as http;
import 'package:toktik/domain/datasources/external_video_datasource.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/domain/errors/external_video_exception.dart';
import 'package:toktik/infrastructure/datasources/external_video_http_helpers.dart';
import 'package:toktik/infrastructure/models/peertube_video_model.dart';

class PeerTubeVideoDatasource implements ExternalVideoDatasource {
  PeerTubeVideoDatasource({Uri? baseUrl, this.count = 25, this.client})
    : baseUrl = baseUrl ?? _defaultInstance {
    if (count < 1 || count > 100) {
      throw ArgumentError.value(count, 'count', 'Debe estar entre 1 y 100.');
    }
  }

  static final Uri _defaultInstance = Uri.https('peertube.cpy.re', '');

  final Uri baseUrl;
  final int count;
  final http.Client? client;

  @override
  Future<List<ExternalVideo>> search(String query) async {
    final normalizedQuery = normalizeExternalVideoQuery(query);
    if (normalizedQuery == null) return const [];

    if (baseUrl.scheme != 'https' ||
        baseUrl.host.isEmpty ||
        (baseUrl.hasPort && baseUrl.port != 443) ||
        baseUrl.userInfo.isNotEmpty ||
        baseUrl.hasQuery ||
        baseUrl.hasFragment) {
      throw const ExternalVideoConfigurationException(
        'Configura PEERTUBE_BASE_URL con la URL HTTPS de una instancia '
        'PeerTube válida.',
      );
    }

    final basePath = baseUrl.path.replaceFirst(RegExp(r'/+$'), '');
    final uri = baseUrl.replace(
      path: '$basePath/api/v1/search/videos',
      queryParameters: {
        'search': normalizedQuery,
        'count': '$count',
        'sort': '-views',
      },
    );
    final response = await getExternalVideoResponse(
      uri,
      provider: 'PeerTube',
      client: client,
    );
    final results = collectionItems(
      response,
      provider: 'PeerTube',
      collectionKey: 'data',
    );
    final seen = <String>{};
    final videos = <ExternalVideo>[];
    for (final result in results) {
      final video = PeerTubeVideoModel.fromJson(
        result,
        instanceUrl: baseUrl,
      ).toEntity(instanceUrl: baseUrl);
      if (seen.add(video.id)) videos.add(video);
    }
    return videos;
  }
}
