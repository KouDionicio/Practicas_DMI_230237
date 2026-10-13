import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/infrastructure/models/local_video_model.dart';
import 'package:toktik/shared/data/local_video_posts.dart';

List<VideoPost> mapLocalVideoPosts() => videoPosts
    .map((video) => LocalVideoModel.fromJson(video).toVideoPostEntity())
    .toList();
