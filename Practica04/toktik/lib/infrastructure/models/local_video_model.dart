import 'package:toktik/domain/entities/video_post.dart';


class LocalVideoModel {
   
  final String name;
  final String videoUrl;
  final String description;
  final int likes;
  final int views;

  LocalVideoModel({
    required this.name,
    required this.videoUrl,
    required this.description,
    this.likes = 0,
    this.views = 0
  });

  factory LocalVideoModel.fromJson(Map<String, dynamic> json) => LocalVideoModel(
      name: json['name'] ?? 'No name',
      videoUrl: json['videoUrl'],
      description: json['description'] ?? '',
      likes: json['likes'] ?? 0,
      views: json['views'] ?? 0,
    );

  VideoPost toVideoPostEntity() => VideoPost(
    caption: name,
    videoUrl: videoUrl,
    description: description,
    likes: likes,
    views: views
  );

}