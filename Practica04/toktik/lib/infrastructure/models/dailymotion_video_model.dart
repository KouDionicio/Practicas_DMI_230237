import 'package:toktik/domain/entities/external_video.dart';

class DailymotionVideoModel {
  const DailymotionVideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
  });

  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;

  factory DailymotionVideoModel.fromJson(Map<String, dynamic> json) =>
      DailymotionVideoModel(
        id: (json['id'] ?? json['video_id']) as String,
        title: json['title'] as String? ?? '',
        description: json['description'] as String? ?? '',
        thumbnailUrl:
            (json['thumbnail_720_url'] ?? json['thumbnail_url']) as String? ??
            '',
      );

  ExternalVideo toEntity() => ExternalVideo(
    id: 'dailymotion:$id',
    source: VideoSource.dailymotion,
    title: title,
    description: description,
    thumbnailUrl: thumbnailUrl,
    watchUrl: Uri.https('www.dailymotion.com', '/video/$id'),
    embedUrl: Uri.https('www.dailymotion.com', '/embed/video/$id'),
  );
}
