import 'package:toktik/domain/entities/external_video.dart';

class DailymotionVideoModel {
  const DailymotionVideoModel({
    required this.id,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.durationSeconds,
  });

  final String id;
  final String title;
  final String description;
  final String thumbnailUrl;
  final int? durationSeconds;

  factory DailymotionVideoModel.fromJson(Map<String, dynamic> json) {
    final id = json['id'] ?? json['video_id'];
    if (id is! String || id.isEmpty) {
      throw const FormatException('Dailymotion no devolvió un ID de video.');
    }
    if (!RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(id)) {
      throw const FormatException(
        'Dailymotion devolvió un ID de video no válido.',
      );
    }

    final thumbnail = json['thumbnail'];
    final thumbnailUrl = _httpsUrl(
      json['thumbnail_720_url'] ??
          json['thumbnail_url'] ??
          (thumbnail is Map<String, dynamic> ? thumbnail['h720_url'] : null),
    );
    final duration = json['duration'];
    final durationSeconds = duration is int && duration >= 0 ? duration : null;

    return DailymotionVideoModel(
      id: id,
      title: _optionalText(json, 'title'),
      description: _optionalText(json, 'description'),
      thumbnailUrl: thumbnailUrl,
      durationSeconds: durationSeconds,
    );
  }

  ExternalVideo toEntity({required String playerId}) {
    if (!RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(playerId)) {
      throw const FormatException(
        'Dailymotion requiere un Player ID válido para el embed.',
      );
    }
    return ExternalVideo(
      id: 'dailymotion:$id',
      source: VideoSource.dailymotion,
      title: title,
      description: description,
      thumbnailUrl: thumbnailUrl,
      watchUrl: Uri.https('www.dailymotion.com', '/video/$id'),
      embedUrl: Uri.https('geo.dailymotion.com', '/player/$playerId.html', {
        'video': id,
      }),
      durationSeconds: durationSeconds,
    );
  }

  static String _optionalText(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value == null) return '';
    if (value is String) return value;
    throw FormatException(
      'Dailymotion devolvió "$field" con formato inválido.',
    );
  }

  static String _httpsUrl(Object? value) {
    if (value is! String || value.isEmpty) return '';
    final uri = Uri.tryParse(value);
    if (uri == null ||
        uri.scheme != 'https' ||
        uri.host.toLowerCase().isEmpty ||
        uri.userInfo.isNotEmpty ||
        !(uri.host.toLowerCase() == 'dmcdn.net' ||
            uri.host.toLowerCase().endsWith('.dmcdn.net'))) {
      return '';
    }
    return uri.toString();
  }
}
