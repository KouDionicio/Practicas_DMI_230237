import 'package:toktik/domain/entities/video_post.dart';

abstract interface class FavoritesRepository {
  Future<List<VideoPost>> getVideosByUserId(String userId);
}
