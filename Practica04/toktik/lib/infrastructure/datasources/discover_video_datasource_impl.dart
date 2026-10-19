import 'package:toktik/domain/datasources/discover_video_datasource.dart';
import 'package:toktik/domain/entities/video_post.dart';

class LocalDiscoverVideoDatasource implements DiscoverVideoDatasource {
  @override
  Future<List<VideoPost>> getVideosByPage(int page) async {
    return const [];
  }
}
