import 'package:toktik/domain/datasources/external_video_datasource.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/domain/repositories/external_video_repository.dart';

class ExternalVideoRepositoryImpl implements ExternalVideoRepository {
  const ExternalVideoRepositoryImpl({
    required this.youtubeDatasource,
    required this.vimeoDatasource,
    required this.dailymotionDatasource,
  });

  final ExternalVideoDatasource youtubeDatasource;
  final ExternalVideoDatasource vimeoDatasource;
  final ExternalVideoDatasource dailymotionDatasource;

  @override
  Future<List<ExternalVideo>> search(VideoSource source, String query) {
    final datasource = switch (source) {
      VideoSource.youtube => youtubeDatasource,
      VideoSource.vimeo => vimeoDatasource,
      VideoSource.dailymotion => dailymotionDatasource,
    };
    return datasource.search(query);
  }
}
