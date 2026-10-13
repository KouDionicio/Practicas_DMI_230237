import 'package:toktik/domain/entities/video_post.dart';

abstract interface class FavoritesVideoDatasource {
  Future<List<VideoPost>> getVideosByUserId(String userId);
}
