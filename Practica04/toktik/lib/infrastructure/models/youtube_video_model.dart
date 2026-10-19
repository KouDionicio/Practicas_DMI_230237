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
    final snippet = json['snippet'];
    final id = json['id'];
    if (snippet is! Map<String, dynamic> || id is! Map<String, dynamic>) {
      throw const FormatException('YouTube devolvió metadatos incompletos.');
    }
    final videoId = id['videoId'];
    if (videoId is! String ||
        !RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(videoId)) {
      throw const FormatException('YouTube no devolvió un ID de video.');
    }
    final thumbnails = snippet['thumbnails'];
    final choices = thumbnails is Map<String, dynamic>
        ? [thumbnails['high'], thumbnails['medium'], thumbnails['default']]
        : const [];
    final thumbnail = choices.whereType<Map<String, dynamic>>().firstOrNull;
    final thumbnailUrl = _optionalText(thumbnail, 'url');
    return YouTubeVideoModel(
      id: videoId,
      title: _optionalText(snippet, 'title'),
      description: _optionalText(snippet, 'description'),
      thumbnailUrl: _trustedThumbnailUrl(thumbnailUrl),
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

  static String _optionalText(Map<String, dynamic>? json, String field) {
    final value = json?[field];
    if (value == null) return '';
    if (value is String) return value;
    throw FormatException('YouTube devolvió "$field" con formato inválido.');
  }

  static String _trustedThumbnailUrl(String value) {
    if (value.isEmpty) return '';
    final uri = Uri.tryParse(value);
    final host = uri?.host.toLowerCase() ?? '';
    final isTrustedHost =
        host == 'ytimg.com' ||
        host.endsWith('.ytimg.com') ||
        host == 'ggpht.com' ||
        host.endsWith('.ggpht.com');
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.userInfo.isNotEmpty ||
        !isTrustedHost) {
      return '';
    }
    return uri.toString();
  }
}
