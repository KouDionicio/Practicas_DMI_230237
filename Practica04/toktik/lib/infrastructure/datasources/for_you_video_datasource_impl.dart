import 'package:toktik/domain/datasources/for_you_video_datasource.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/infrastructure/datasources/local_video_posts_mapper.dart';

class LocalForYouVideoDatasource implements ForYouVideoDatasource {
  @override
  Future<List<VideoPost>> getVideosByPage(int page) async {
    final videos = mapLocalVideoPosts()
      ..sort((first, second) => second.views.compareTo(first.views));
    return videos;
  }
}
