import 'package:toktik/domain/datasources/external_video_datasource.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/domain/entities/external_video_page.dart';
import 'package:toktik/domain/repositories/external_video_repository.dart';

class ExternalVideoRepositoryImpl implements PaginatedExternalVideoRepository {
  const ExternalVideoRepositoryImpl({
    required this.youtubeDatasource,
    required this.vimeoDatasource,
    required this.peerTubeDatasource,
  });

  final ExternalVideoDatasource youtubeDatasource;
  final ExternalVideoDatasource vimeoDatasource;
  final ExternalVideoDatasource peerTubeDatasource;

  @override
  Future<List<ExternalVideo>> search(VideoSource source, String query) {
    final datasource = switch (source) {
      VideoSource.local => throw const FormatException(
        'Los videos locales no se consultan como proveedores externos.',
      ),
      VideoSource.youtube => youtubeDatasource,
      VideoSource.vimeo => vimeoDatasource,
      VideoSource.peertube => peerTubeDatasource,
    };
    return datasource.search(query);
  }

  @override
  Future<ExternalVideoPage> searchPage(
    VideoSource source,
    String query, {
    String? pageToken,
  }) async {
    final datasource = switch (source) {
      VideoSource.local => throw const FormatException(
        'Los videos locales no se consultan como proveedores externos.',
      ),
      VideoSource.youtube => youtubeDatasource,
      VideoSource.vimeo => vimeoDatasource,
      VideoSource.peertube => peerTubeDatasource,
    };
    if (datasource is PaginatedExternalVideoDatasource) {
      return datasource.searchPage(query, pageToken: pageToken);
    }
    return ExternalVideoPage(await datasource.search(query));
  }
}
