import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

class PeerTubeMediaResolver {
  PeerTubeMediaResolver({this.client});

  final http.Client? client;

  Future<Uri> resolve(Uri embedUrl, String videoId) async {
    final embedPath = RegExp(r'/videos/embed/[0-9a-fA-F-]{36}/?$')
        .firstMatch(embedUrl.path);
    if (embedPath == null ||
        !RegExp(r'^[0-9a-fA-F]{8}-(?:[0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$')
            .hasMatch(videoId) ||
        embedUrl.scheme != 'https' ||
        embedUrl.host.isEmpty ||
        embedUrl.userInfo.isNotEmpty ||
        embedUrl.hasQuery ||
        embedUrl.hasFragment) {
      throw FormatException(
        'PeerTube necesita una URL HTTPS de inserción válida: '
        '${_withoutQuery(embedUrl)}',
      );
    }

    final basePath = embedUrl.path.substring(0, embedPath.start);
    final requestUrl = Uri(
      scheme: embedUrl.scheme,
      host: embedUrl.host,
      port: embedUrl.hasPort ? embedUrl.port : null,
      path: '$basePath/api/v1/videos/$videoId',
    );
    final response = await _get(requestUrl);
    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw HttpException(
        'PeerTube respondió HTTP ${response.statusCode}'
        '${response.reasonPhrase == null ? '' : ' ${response.reasonPhrase}'} '
        'al consultar ${_withoutQuery(requestUrl)}.',
        uri: _withoutQuery(requestUrl),
      );
    }

    final Object? decoded;
    try {
      decoded = jsonDecode(response.body);
    } on FormatException catch (error) {
      throw FormatException(
        'PeerTube devolvió JSON inválido (${error.message}) en '
        '${_withoutQuery(requestUrl)}.',
      );
    }
    if (decoded is! Map<String, dynamic>) {
      throw FormatException(
        'PeerTube devolvió una respuesta sin metadatos de video en '
        '${_withoutQuery(requestUrl)}.',
      );
    }

    final mediaUrl = _firstMediaUrl(decoded, requestUrl);
    if (mediaUrl != null) return mediaUrl;
    throw FormatException(
      'PeerTube no devolvió files[].fileUrl ni '
      'streamingPlaylists[].playlistUrl en ${_withoutQuery(requestUrl)}.',
    );
  }

  Future<http.Response> _get(Uri url) {
    final client = this.client;
    final request = client == null
        ? http.get(url, headers: const {'Accept': 'application/json'})
        : client.get(url, headers: const {'Accept': 'application/json'});
    return request.timeout(
      const Duration(seconds: 15),
      onTimeout: () => throw TimeoutException(
        'La consulta de PeerTube agotó el tiempo en ${_withoutQuery(url)}.',
      ),
    );
  }

  static Uri? _firstMediaUrl(Map<String, dynamic> video, Uri requestUrl) {
    final candidates = <({Uri uri, int score})>[];
    final files = video['files'];
    if (files is List) {
      for (final file in files) {
        if (file is Map<String, dynamic>) {
          final url = _trustedHttpsUrl(file['fileUrl'], requestUrl);
          final resolution = file['resolution'];
          final label = resolution is Map ? resolution['label'] : null;
          final height = resolution is Map ? resolution['id'] : null;
          final fileName = url?.path.toLowerCase() ?? '';
          if (url != null && (fileName.endsWith('.mp4') || fileName.contains('.mp4?'))) {
            final pixels = height is num ? height.toInt() : 0;
            final text = label is String ? label : '';
            final score = pixels == 720 || text.contains('720')
                ? 3
                : pixels == 480 || text.contains('480')
                ? 2
                : 1;
            candidates.add((uri: url, score: score));
          }
        }
      }
    }
    candidates.sort((a, b) => b.score.compareTo(a.score));
    if (candidates.isNotEmpty) return candidates.first.uri;

    // Prefer an HLS playlist only when no progressive MP4 is available.
    final playlists = video['streamingPlaylists'];
    if (playlists is List) {
      for (final playlist in playlists) {
        if (playlist is! Map<String, dynamic>) continue;
        final url = _trustedHttpsUrl(playlist['playlistUrl'], requestUrl);
        if (url != null) return url;
      }
    }
    return null;
  }

  static Uri? _trustedHttpsUrl(Object? value, Uri baseUrl) {
    if (value is! String || value.trim().isEmpty) return null;
    final parsed = Uri.tryParse(value.trim());
    if (parsed == null) return null;
    final resolved = parsed.hasScheme ? parsed : baseUrl.resolveUri(parsed);
    if (resolved.scheme != 'https' ||
        resolved.host.isEmpty ||
        resolved.userInfo.isNotEmpty) {
      return null;
    }
    return resolved;
  }

  static Uri _withoutQuery(Uri uri) => Uri(
    scheme: uri.scheme,
    host: uri.host,
    port: uri.hasPort ? uri.port : null,
    path: uri.path,
  );
}
