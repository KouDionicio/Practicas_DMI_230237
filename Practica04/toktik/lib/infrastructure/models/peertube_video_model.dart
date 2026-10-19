import 'package:toktik/domain/entities/external_video.dart';

class PeerTubeVideoModel {
  const PeerTubeVideoModel({
    required this.uuid,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.durationSeconds,
    required this.watchUrl,
    required this.embedUrl,
  });

  final String uuid;
  final String title;
  final String description;
  final String thumbnailUrl;
  final int? durationSeconds;
  final Uri watchUrl;
  final Uri embedUrl;

  factory PeerTubeVideoModel.fromJson(
    Map<String, dynamic> json, {
    required Uri instanceUrl,
  }) {
    final uuid = json['uuid'];
    if (uuid is! String ||
        !RegExp(r'^[0-9a-fA-F]{8}-(?:[0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$')
            .hasMatch(uuid)) {
      throw const FormatException(
        'PeerTube no devolvió un UUID de video válido.',
      );
    }

    final duration = json['duration'];
    if (duration != null && duration is! num) {
      throw const FormatException('PeerTube devolvió una duración inválida.');
    }
    final durationSeconds = duration is num && duration >= 0
        ? duration.toInt()
        : null;
    final basePath = instanceUrl.path.replaceFirst(RegExp(r'/+$'), '');
    final canonicalWatchUrl = instanceUrl.replace(
      path: '$basePath/videos/watch/$uuid',
    );
    final shortUuid = json['shortUUID'];
    if (shortUuid != null &&
        (shortUuid is! String ||
            !RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(shortUuid))) {
      throw const FormatException(
        'PeerTube devolvió un identificador corto inválido.',
      );
    }

    return PeerTubeVideoModel(
      uuid: uuid,
      title: _optionalText(json, 'name').trim().isEmpty
          ? 'Video de PeerTube'
          : _optionalText(json, 'name'),
      description: _optionalText(json, 'description'),
      thumbnailUrl: _trustedThumbnailUrl(
        json['thumbnailPath'] ?? json['thumbnailUrl'],
        instanceUrl,
      ),
      durationSeconds: durationSeconds,
      watchUrl: _watchUrl(
        json['url'],
        canonicalWatchUrl,
        instanceUrl,
        uuid: uuid,
        shortUuid: shortUuid as String?,
      ),
      embedUrl: _embedUrl(json['embedPath'], instanceUrl, uuid),
    );
  }

  ExternalVideo toEntity({required Uri instanceUrl}) {
    return ExternalVideo(
      id: 'peertube:$uuid',
      source: VideoSource.peertube,
      title: title,
      description: description,
      thumbnailUrl: thumbnailUrl,
      watchUrl: watchUrl,
      embedUrl: embedUrl,
      durationSeconds: durationSeconds,
    );
  }

  static String _optionalText(Map<String, dynamic> json, String field) {
    final value = json[field];
    if (value == null) return '';
    if (value is String) return value;
    throw FormatException('PeerTube devolvió "$field" con formato inválido.');
  }

  static String _trustedThumbnailUrl(Object? value, Uri instanceUrl) {
    if (value is! String || value.isEmpty) return '';
    final uri = Uri.tryParse(value);
    if (uri == null) return '';
    final resolved = uri.hasScheme ? uri : instanceUrl.resolveUri(uri);
    if (resolved.scheme != 'https' ||
        resolved.host.toLowerCase() != instanceUrl.host.toLowerCase() ||
        resolved.port != instanceUrl.port ||
        resolved.userInfo.isNotEmpty) {
      return '';
    }
    return resolved.toString();
  }

  static Uri _watchUrl(
    Object? value,
    Uri canonical,
    Uri instanceUrl, {
    required String uuid,
    required String? shortUuid,
  }) {
    if (value == null) return canonical;
    if (value is! String || value.isEmpty) {
      throw const FormatException(
        'PeerTube devolvió una URL de video inválida.',
      );
    }
    final parsed = Uri.tryParse(value);
    if (parsed == null) {
      throw const FormatException(
        'PeerTube devolvió una URL de video inválida.',
      );
    }
    final resolved = parsed.hasScheme ? parsed : instanceUrl.resolveUri(parsed);
    if (resolved.scheme != 'https' ||
        resolved.host.toLowerCase() != instanceUrl.host.toLowerCase() ||
        resolved.port != instanceUrl.port ||
        resolved.userInfo.isNotEmpty ||
        resolved.hasQuery ||
        resolved.hasFragment ||
        !_isWatchPath(resolved, instanceUrl, uuid, shortUuid)) {
      throw const FormatException(
        'PeerTube devolvió una URL de video que no corresponde al UUID.',
      );
    }
    return resolved;
  }

  static Uri _embedUrl(Object? value, Uri instanceUrl, String uuid) {
    final basePath = instanceUrl.path.replaceFirst(RegExp(r'/+$'), '');
    final canonical = instanceUrl.replace(path: '$basePath/videos/embed/$uuid');
    if (value == null) return canonical;
    if (value is! String || value.isEmpty) {
      throw const FormatException('PeerTube devolvió un embedPath inválido.');
    }
    final parsed = Uri.tryParse(value);
    if (parsed == null ||
        parsed.hasScheme ||
        parsed.hasAuthority ||
        parsed.hasQuery ||
        parsed.hasFragment) {
      throw const FormatException('PeerTube devolvió un embedPath inválido.');
    }
    final resolved = instanceUrl.resolveUri(parsed);
    if (!_hasInstancePrefix(resolved, instanceUrl) ||
        !_hasTail(resolved, instanceUrl, ['videos', 'embed', uuid])) {
      throw const FormatException(
        'PeerTube devolvió un embedPath que no corresponde al UUID.',
      );
    }
    return resolved;
  }

  static bool _isWatchPath(
    Uri uri,
    Uri instanceUrl,
    String uuid,
    String? shortUuid,
  ) {
    final tail = _tail(uri, instanceUrl);
    if (tail == null) return false;
    if (tail.length == 3 &&
        tail[0] == 'videos' &&
        tail[1] == 'watch' &&
        tail[2] == uuid) {
      return true;
    }
    return tail.length == 2 &&
        tail[0] == 'w' &&
        RegExp(r'^[A-Za-z0-9_-]{1,128}$').hasMatch(tail[1]) &&
        (shortUuid == null || tail[1] == shortUuid);
  }

  static bool _hasInstancePrefix(Uri uri, Uri instanceUrl) =>
      uri.scheme == 'https' &&
      uri.host.toLowerCase() == instanceUrl.host.toLowerCase() &&
      uri.port == instanceUrl.port &&
      uri.userInfo.isEmpty;

  static bool _hasTail(Uri uri, Uri instanceUrl, List<String> expected) {
    final tail = _tail(uri, instanceUrl);
    if (tail == null || tail.length != expected.length) return false;
    for (var index = 0; index < expected.length; index++) {
      if (tail[index] != expected[index]) return false;
    }
    return true;
  }

  static List<String>? _tail(Uri uri, Uri instanceUrl) {
    if (!_hasInstancePrefix(uri, instanceUrl)) return null;
    final prefix = instanceUrl.pathSegments;
    final segments = uri.pathSegments;
    if (segments.length < prefix.length ||
        !_startsWithSegments(segments, prefix)) {
      return null;
    }
    return segments.skip(prefix.length).toList(growable: false);
  }

  static bool _startsWithSegments(List<String> value, List<String> prefix) {
    for (var index = 0; index < prefix.length; index++) {
      if (value[index] != prefix[index]) return false;
    }
    return true;
  }
}
