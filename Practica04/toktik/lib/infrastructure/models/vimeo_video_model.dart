import 'package:toktik/domain/entities/external_video.dart';

class VimeoVideoModel {
  const VimeoVideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
  });

  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;

  factory VimeoVideoModel.fromJson(Map<String, dynamic> json) {
    final uri = json['uri'] as String;
    final id = uri.split('/').where((part) => part.isNotEmpty).last;
    final pictureSizes =
        (json['pictures'] as Map<String, dynamic>?)?['sizes'] as List<dynamic>?;
    final picture = pictureSizes == null || pictureSizes.isEmpty
        ? null
        : pictureSizes.last as Map<String, dynamic>;
    return VimeoVideoModel(
      id: id,
      title: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      thumbnailUrl: picture?['link'] as String? ?? '',
    );
  }

  ExternalVideo toEntity() => ExternalVideo(
    id: 'vimeo:$id',
    source: VideoSource.vimeo,
    title: title,
    description: description,
    thumbnailUrl: thumbnailUrl,
    watchUrl: Uri.https('vimeo.com', '/$id'),
    embedUrl: Uri.https('player.vimeo.com', '/video/$id'),
  );
}
