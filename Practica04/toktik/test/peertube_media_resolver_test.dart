import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:toktik/presentation/widgets/video/peertube_media_resolver.dart';

const _videoId = 'a1b2c3d4-0000-4000-8000-000000000001';

void main() {
  test('resolves the real HTTPS file URL using the instance API', () async {
    final resolver = PeerTubeMediaResolver(
      client: MockClient((request) async {
        expect(request.url.path, '/tenant/api/v1/videos/$_videoId');
        expect(request.url.hasQuery, isFalse);
        return http.Response(
          jsonEncode({
            'files': [
              {'fileUrl': 'https://cdn.example/video.mp4?token=private'},
            ],
            'streamingPlaylists': [
              {'playlistUrl': 'https://cdn.example/video.m3u8'},
            ],
          }),
          200,
        );
      }),
    );

    final result = await resolver.resolve(
      Uri.https('peertube.example', '/tenant/videos/embed/$_videoId'),
      _videoId,
    );

    expect(result.toString(), 'https://cdn.example/video.mp4?token=private');
  });

  test('falls back to HTTPS HLS when no valid file URL is available', () async {
    final resolver = PeerTubeMediaResolver(
      client: MockClient((_) async {
        return http.Response(
          jsonEncode({
            'files': [
              {'fileUrl': 'http://cdn.example/video.mp4'},
            ],
            'streamingPlaylists': [
              {'playlistUrl': 'https://cdn.example/video.m3u8'},
            ],
          }),
          200,
        );
      }),
    );

    final result = await resolver.resolve(
      Uri.https('peertube.example', '/videos/embed/$_videoId'),
      _videoId,
    );

    expect(result.toString(), 'https://cdn.example/video.m3u8');
  });

  test(
    'reports the HTTP status and omits query data from the API URL',
    () async {
      final resolver = PeerTubeMediaResolver(
        client: MockClient((_) async => http.Response('unavailable', 503)),
      );

      await expectLater(
        resolver.resolve(
          Uri.https('peertube.example', '/videos/embed/$_videoId'),
          _videoId,
        ),
        throwsA(
          isA<HttpException>()
              .having((error) => error.message, 'message', contains('HTTP 503'))
              .having(
                (error) => error.message,
                'URL',
                contains('https://peertube.example/api/v1/videos/$_videoId'),
              ),
        ),
      );
    },
  );
}
