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
    final uri = json['uri'];

    if (uri is! String) {
      throw const FormatException('Vimeo no devolvió el URI del video.');
    }

    final parsedUri = Uri.tryParse(uri);
    final videoPath = parsedUri?.pathSegments;
    if (parsedUri == null ||
        parsedUri.hasScheme ||
        parsedUri.hasAuthority ||
        parsedUri.hasQuery ||
        parsedUri.hasFragment ||
        videoPath == null ||
        videoPath.length != 2 ||
        videoPath.first != 'videos' ||
        !RegExp(r'^[0-9]+$').hasMatch(videoPath.last)) {
      throw const FormatException('Vimeo devolvió un URI de video no válido.');
    }

    final id = videoPath.last;
    final pictures = json['pictures'];
    final pictureSizes = pictures is Map<String, dynamic>
        ? pictures['sizes']
        : null;
    final picture = pictureSizes is List<dynamic>
        ? pictureSizes.whereType<Map<String, dynamic>>().lastOrNull
        : null;

    return VimeoVideoModel(
      id: id,
      title: _optionalText(json, 'name'),
      description: _optionalText(json, 'description'),
      thumbnailUrl: _trustedThumbnailUrl(_optionalText(picture, 'link')),
    );
  }

  ExternalVideo toEntity({String? oEmbedThumbnailUrl}) => ExternalVideo(
    id: 'vimeo:$id',
    source: VideoSource.vimeo,
    title: title,
    description: description,
    thumbnailUrl: oEmbedThumbnailUrl ?? thumbnailUrl,
    watchUrl: Uri.https('vimeo.com', '/$id'),
    embedUrl: Uri.https('player.vimeo.com', '/video/$id'),
  );

  static String _optionalText(Map<String, dynamic>? json, String field) {
    final value = json?[field];
    if (value == null) return '';
    if (value is String) return value;
    throw FormatException('Vimeo devolvió "$field" con formato inválido.');
  }

  static String _trustedThumbnailUrl(String value) {
    if (value.isEmpty) return '';
    final uri = Uri.tryParse(value);
    final host = uri?.host.toLowerCase() ?? '';
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.userInfo.isNotEmpty ||
        !(host == 'vimeocdn.com' || host.endsWith('.vimeocdn.com'))) {
      return '';
    }
    return uri.toString();
  }
}
