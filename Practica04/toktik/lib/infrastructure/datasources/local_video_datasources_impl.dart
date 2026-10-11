import 'package:toktik/domain/datasources/video_post_datasource.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/infrastructure/models/local_video_model.dart';
import 'package:toktik/shared/data/local_video_posts.dart';

class LocalVideoDatasource implements VideoPostDatasource {
  LocalVideoDatasource({required this.loadFavoriteIds});

  final Future<Set<String>> Function() loadFavoriteIds;

  @override
  Future<List<VideoPost>> getFavoriteVideosByUserId(String userId) async {
    final favoriteIds = await loadFavoriteIds();
    final videos = videoPosts
        .map((video) => LocalVideoModel.fromJson(video).toVideoPostEntity())
        .where((video) => favoriteIds.contains(video.id))
        .toList();
    return videos;
  }

  @override
  Future<List<VideoPost>> getTrendingVideosByPage(int page) async {
    await Future.delayed(const Duration(seconds: 2));

    final List<VideoPost> newVideos = videoPosts
        .map((video) => LocalVideoModel.fromJson(video).toVideoPostEntity())
        .toList();

    return newVideos;
  }

  @override
  Future<List<VideoPost>> getForYouVideosByPage(int page) async {
    final videos = await getTrendingVideosByPage(page);
    videos.sort((first, second) => second.views.compareTo(first.views));
    return videos;
  }
}
