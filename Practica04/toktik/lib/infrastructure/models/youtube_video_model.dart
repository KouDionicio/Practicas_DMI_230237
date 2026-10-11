import 'package:toktik/domain/entities/external_video.dart';

class YouTubeVideoModel {
  const YouTubeVideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
  });

  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;

  factory YouTubeVideoModel.fromJson(Map<String, dynamic> json) {
    final snippet = json['snippet'] as Map<String, dynamic>;
    final videoId = (json['id'] as Map<String, dynamic>)['videoId'] as String;
    final thumbnails = snippet['thumbnails'] as Map<String, dynamic>;
    final thumbnail =
        (thumbnails['high'] ?? thumbnails['medium'] ?? thumbnails['default'])
            as Map<String, dynamic>;
    return YouTubeVideoModel(
      id: videoId,
      title: snippet['title'] as String? ?? '',
      description: snippet['description'] as String? ?? '',
      thumbnailUrl: thumbnail['url'] as String? ?? '',
    );
  }

  ExternalVideo toEntity() => ExternalVideo(
    id: 'youtube:$id',
    source: VideoSource.youtube,
    title: title,
    description: description,
    thumbnailUrl: thumbnailUrl,
    watchUrl: Uri.https('www.youtube.com', '/watch', {'v': id}),
    embedUrl: Uri.https('www.youtube.com', '/embed/$id'),
  );
}
