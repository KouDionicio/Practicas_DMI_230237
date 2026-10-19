import 'package:toktik/domain/datasources/favorites_video_datasource.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/infrastructure/datasources/local_video_posts_mapper.dart';

class LocalFavoritesVideoDatasource implements FavoritesVideoDatasource {
  LocalFavoritesVideoDatasource({required this.loadFavoriteIds});

  final Future<Set<String>> Function() loadFavoriteIds;

  @override
  Future<List<VideoPost>> getVideosByUserId(String userId) async {
    final favoriteIds = await loadFavoriteIds();
    return mapLocalVideoPosts()
        .where((video) => favoriteIds.contains(video.id))
        .toList();
  }
}
