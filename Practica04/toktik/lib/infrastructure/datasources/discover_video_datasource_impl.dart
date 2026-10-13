import 'package:toktik/domain/datasources/discover_video_datasource.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/infrastructure/datasources/local_video_posts_mapper.dart';

class LocalDiscoverVideoDatasource implements DiscoverVideoDatasource {
  @override
  Future<List<VideoPost>> getVideosByPage(int page) async {
    await Future<void>.delayed(const Duration(seconds: 2));
    return mapLocalVideoPosts();
  }
}
