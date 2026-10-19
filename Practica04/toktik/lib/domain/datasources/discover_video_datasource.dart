import 'package:toktik/domain/entities/video_post.dart';

abstract interface class DiscoverVideoDatasource {
  Future<List<VideoPost>> getVideosByPage(int page);
}
