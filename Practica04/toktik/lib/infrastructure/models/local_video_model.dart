import 'package:toktik/domain/entities/video_post.dart';

class LocalVideoModel {
  final String name;
  final String id;
  final String videoUrl;
  final String description;
  final int likes;
  final int views;

  LocalVideoModel({
    required this.id,
    required this.name,
    required this.videoUrl,
    required this.description,
    this.likes = 0,
    this.views = 0,
  });

  factory LocalVideoModel.fromJson(Map<String, dynamic> json) =>
      LocalVideoModel(
        id: json['id'] as String? ?? json['videoUrl'] as String,
        name: json['name'] as String? ?? 'No name',
        videoUrl: json['videoUrl'] as String,
        description: json['description'] as String? ?? '',
        likes: json['likes'] as int? ?? 0,
        views: json['views'] as int? ?? 0,
      );

  VideoPost toVideoPostEntity() => VideoPost(
    id: id,
    caption: name,
    videoUrl: videoUrl,
    description: description,
    likes: likes,
    views: views,
  );
}
