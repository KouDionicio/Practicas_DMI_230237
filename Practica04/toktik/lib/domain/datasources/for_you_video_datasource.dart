import 'package:toktik/domain/entities/video_post.dart';

abstract interface class ForYouVideoDatasource {
  Future<List<VideoPost>> getVideosByPage(int page);
}
