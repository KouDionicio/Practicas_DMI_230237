import 'package:toktik/domain/datasources/favorites_video_datasource.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/domain/repositories/favorites_repository.dart';

class FavoritesRepositoryImpl implements FavoritesRepository {
  const FavoritesRepositoryImpl({required this.datasource});

  final FavoritesVideoDatasource datasource;

  @override
  Future<List<VideoPost>> getVideosByUserId(String userId) =>
      datasource.getVideosByUserId(userId);
}
