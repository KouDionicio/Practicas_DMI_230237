import 'package:toktik/domain/entities/video_post.dart';

abstract interface class DiscoverRepository {
  Future<List<VideoPost>> getVideosByPage(int page);
}
