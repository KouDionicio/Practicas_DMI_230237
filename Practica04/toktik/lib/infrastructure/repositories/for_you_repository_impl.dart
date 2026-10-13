import 'package:toktik/domain/datasources/for_you_video_datasource.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/domain/repositories/for_you_repository.dart';

class ForYouRepositoryImpl implements ForYouRepository {
  const ForYouRepositoryImpl({required this.datasource});

  final ForYouVideoDatasource datasource;

  @override
  Future<List<VideoPost>> getVideosByPage(int page) =>
      datasource.getVideosByPage(page);
}
