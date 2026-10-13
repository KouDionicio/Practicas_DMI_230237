import 'package:toktik/domain/datasources/discover_video_datasource.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/domain/repositories/discover_repository.dart';

class DiscoverRepositoryImpl implements DiscoverRepository {
  const DiscoverRepositoryImpl({required this.datasource});

  final DiscoverVideoDatasource datasource;

  @override
  Future<List<VideoPost>> getVideosByPage(int page) =>
      datasource.getVideosByPage(page);
}
