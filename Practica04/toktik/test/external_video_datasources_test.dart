import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:toktik/domain/datasources/external_video_datasource.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/domain/errors/external_video_exception.dart';
import 'package:toktik/infrastructure/datasources/dailymotion_video_datasource.dart';
import 'package:toktik/infrastructure/datasources/vimeo_video_datasource.dart';
import 'package:toktik/infrastructure/datasources/youtube_video_datasource.dart';
import 'package:toktik/infrastructure/repositories/external_video_repository_impl.dart';

http.Response _json(Object value, {int statusCode = 200}) =>
    http.Response(jsonEncode(value), statusCode);

void main() {
  group('YouTube datasource', () {
    test('requests official search.list and maps the response', () async {
      final client = MockClient((request) async {
        expect(request.url.host, 'www.googleapis.com');
        expect(request.url.path, '/youtube/v3/search');
        expect(request.url.queryParameters['type'], 'video');
        expect(request.url.queryParameters['q'], 'cats');
        expect(request.url.queryParameters['key'], 'restricted-key');
        return _json({
          'items': [
            {
              'id': {'videoId': 'abc123'},
              'snippet': {
                'title': 'Cats',
                'description': 'A cat video',
                'thumbnails': {
                  'high': {'url': 'https://i.ytimg.com/cat.jpg'},
                },
              },
            },
          ],
        });
      });

      final videos = await YouTubeVideoDatasource(
        apiKey: 'restricted-key',
        client: client,
      ).search('cats');

      expect(videos.single.id, 'youtube:abc123');
      expect(videos.single.embedUrl.host, 'www.youtube.com');
    });

    test('reports authentication and HTTP failures', () async {
      final datasource = YouTubeVideoDatasource(
        apiKey: 'key',
        client: MockClient(
          (_) async => _json({
            'error': {'message': 'Invalid API key'},
          }, statusCode: 403),
        ),
      );
      await expectLater(
        datasource.search('cats'),
        throwsA(
          isA<ExternalVideoApiException>()
              .having((error) => error.statusCode, 'statusCode', 403)
              .having(
                (error) => error.isAuthenticationError,
                'isAuthenticationError',
                isTrue,
              ),
        ),
      );
    });

    test(
      'reports API server errors without converting them to empty results',
      () async {
        final datasource = YouTubeVideoDatasource(
          apiKey: 'key',
          client: MockClient(
            (_) async => _json({'message': 'Unavailable'}, statusCode: 503),
          ),
        );
        await expectLater(
          datasource.search('cats'),
          throwsA(
            isA<ExternalVideoApiException>()
                .having((error) => error.statusCode, 'statusCode', 503)
                .having(
                  (error) => error.isAuthenticationError,
                  'isAuthenticationError',
                  isFalse,
                ),
          ),
        );
      },
    );

    test('rejects incomplete search items', () async {
      final datasource = YouTubeVideoDatasource(
        apiKey: 'key',
        client: MockClient(
          (_) async => _json({
            'items': [
              {'snippet': {}},
            ],
          }),
        ),
      );
      await expectLater(datasource.search('cats'), throwsFormatException);
    });
  });

  group('Vimeo datasource', () {
    test(
      'calls the Vimeo backend and maps results without sending a token',
      () async {
        final client = MockClient((request) async {
          expect(request.url.host, 'vimeo-backend.example');
          expect(request.url.path, '/api/vimeo/search');
          expect(request.url.queryParameters['query'], 'travel');
          expect(request.headers.containsKey('Authorization'), isFalse);
          return _json({
            'data': [
              {
                'uri': '/videos/42',
                'name': 'Travel',
                'description': 'A trip',
                'pictures': {
                  'sizes': [
                    {'link': 'https://i.vimeocdn.com/travel.jpg'},
                  ],
                },
              },
            ],
          });
        });

        final videos = await VimeoVideoDatasource(
          baseUrl: Uri.https('vimeo-backend.example'),
          client: client,
        ).search('travel');

        expect(videos.single.id, 'vimeo:42');
        expect(videos.single.embedUrl.host, 'player.vimeo.com');
      },
    );

    test('reports missing backend URL configuration', () async {
      await expectLater(
        VimeoVideoDatasource(baseUrl: null).search('query'),
        throwsA(isA<ExternalVideoConfigurationException>()),
      );
    });

    test('reports unauthorized access and incomplete response data', () async {
      final unauthorized = VimeoVideoDatasource(
        baseUrl: Uri.https('vimeo-backend.example'),
        client: MockClient(
          (_) async => _json({
            'error': {'message': 'Invalid token'},
          }, statusCode: 401),
        ),
      );
      await expectLater(
        unauthorized.search('query'),
        throwsA(
          isA<ExternalVideoApiException>().having(
            (error) => error.isAuthenticationError,
            'isAuthenticationError',
            isTrue,
          ),
        ),
      );

      final incomplete = VimeoVideoDatasource(
        baseUrl: Uri.https('vimeo-backend.example'),
        client: MockClient(
          (_) async => _json({
            'data': [
              {'name': 'No URI'},
            ],
          }),
        ),
      );
      await expectLater(incomplete.search('query'), throwsFormatException);
    });
  });

  group('Dailymotion datasource', () {
    test(
      'searches public videos across creators and maps player card fields',
      () async {
        final client = MockClient((request) async {
          expect(request.url.host, 'api.dailymotion.com');
          expect(request.url.path, '/videos');
          expect(request.url.queryParameters['search'], 'cooking');
          expect(request.url.queryParameters['page'], '1');
          expect(request.url.queryParameters['limit'], '25');
          expect(
            request.url.queryParameters['fields'],
            'id,title,description,thumbnail_720_url,duration,embed_url,url',
          );
          expect(request.url.queryParameters['api_key'], 'public-test-key');
          return _json({
            'list': [
              {
                'id': 'x1',
                'title': 'Cooking at home',
                'description': 'Pasta',
                'thumbnail_720_url': 'https://s1.dmcdn.net/cooking.jpg',
                'duration': 125,
                'embed_url': 'https://geo.dailymotion.com/player.html?video=x1',
                'url': 'https://www.dailymotion.com/video/x1',
              },
              {
                'id': 'x2',
                'title': 'Cooking around the world',
                'description': 'Another creator',
              },
            ],
          });
        });

        final videos = await DailymotionVideoDatasource(
          apiKey: 'public-test-key',
          playerId: 'player_1',
          client: client,
        ).search('cooking');

        expect(videos.map((video) => video.id), [
          'dailymotion:x1',
          'dailymotion:x2',
        ]);
        expect(videos.first.title, 'Cooking at home');
        expect(videos.first.description, 'Pasta');
        expect(videos.first.thumbnailUrl, 'https://s1.dmcdn.net/cooking.jpg');
        expect(videos.first.durationSeconds, 125);
        expect(videos.first.embedUrl.host, 'geo.dailymotion.com');
        expect(videos.first.embedUrl.path, '/player/player_1.html');
        expect(videos.first.embedUrl.queryParameters['video'], 'x1');
      },
    );

    test('requires the public API key and Player ID', () async {
      await expectLater(
        DailymotionVideoDatasource(
          apiKey: null,
          playerId: 'player_1',
          client: MockClient((_) async => fail('Unexpected API request')),
        ).search('query'),
        throwsA(isA<ExternalVideoConfigurationException>()),
      );
      await expectLater(
        DailymotionVideoDatasource(
          apiKey: 'public-test-key',
          playerId: null,
          client: MockClient((_) async => fail('Unexpected API request')),
        ).search('query'),
        throwsA(isA<ExternalVideoConfigurationException>()),
      );
    });

    test(
      'returns no results for an empty query without making a request',
      () async {
        final videos = await DailymotionVideoDatasource(
          apiKey: null,
          playerId: null,
          client: MockClient((_) async => fail('Unexpected API request')),
        ).search('   ');
        expect(videos, isEmpty);
      },
    );

    test(
      'preserves HTTP authentication failures and reports rate limiting',
      () async {
        final unauthorized = DailymotionVideoDatasource(
          apiKey: 'public-test-key',
          playerId: 'player_1',
          client: MockClient(
            (_) async => _json({'error': 'unauthorized'}, statusCode: 401),
          ),
        );
        await expectLater(
          unauthorized.search('query'),
          throwsA(
            isA<ExternalVideoApiException>()
                .having((error) => error.statusCode, 'statusCode', 401)
                .having(
                  (error) => error.isAuthenticationError,
                  'isAuthenticationError',
                  isTrue,
                ),
          ),
        );

        final rateLimited = DailymotionVideoDatasource(
          apiKey: 'public-test-key',
          playerId: 'player_1',
          client: MockClient(
            (_) async => http.Response(
              jsonEncode({'error': 'Too many requests'}),
              429,
              headers: {'retry-after': '30'},
            ),
          ),
        );
        await expectLater(
          rateLimited.search('query'),
          throwsA(
            isA<ExternalVideoApiException>()
                .having((error) => error.statusCode, 'statusCode', 429)
                .having(
                  (error) => error.message,
                  'message',
                  contains('30 segundos'),
                ),
          ),
        );
      },
    );

    test('rejects malformed results and invalid video IDs', () async {
      final incomplete = DailymotionVideoDatasource(
        apiKey: 'public-test-key',
        playerId: 'player_1',
        client: MockClient(
          (_) async => _json({
            'list': [
              {'title': 'No ID'},
            ],
          }),
        ),
      );
      await expectLater(incomplete.search('query'), throwsFormatException);
      final invalidId = DailymotionVideoDatasource(
        apiKey: 'public-test-key',
        playerId: 'player_1',
        client: MockClient(
          (_) async => _json({
            'list': [
              {'id': '../not-a-video'},
            ],
          }),
        ),
      );
      await expectLater(invalidId.search('query'), throwsFormatException);
    });

    test('returns an empty results list from the official endpoint', () async {
      final videos = await DailymotionVideoDatasource(
        apiKey: 'public-test-key',
        playerId: 'player_1',
        client: MockClient((_) async => _json({'list': []})),
      ).search('no matching videos');
      expect(videos, isEmpty);
    });
  });

  test(
    'repository dispatches each source to its configured datasource',
    () async {
      final youtube = _RecordingDatasource();
      final vimeo = _RecordingDatasource();
      final dailymotion = _RecordingDatasource();
      final repository = ExternalVideoRepositoryImpl(
        youtubeDatasource: youtube,
        vimeoDatasource: vimeo,
        dailymotionDatasource: dailymotion,
      );

      for (final source in VideoSource.values) {
        await repository.search(source, 'query');
      }

      expect(youtube.queries, ['query']);
      expect(vimeo.queries, ['query']);
      expect(dailymotion.queries, ['query']);
    },
  );

  test(
    'repository returns mapped data from all three HTTP datasources',
    () async {
      final repository = ExternalVideoRepositoryImpl(
        youtubeDatasource: YouTubeVideoDatasource(
          apiKey: 'key',
          client: MockClient(
            (_) async => _json({
              'items': [
                {
                  'id': {'videoId': 'yt1'},
                  'snippet': {'title': 'YouTube result'},
                },
              ],
            }),
          ),
        ),
        vimeoDatasource: VimeoVideoDatasource(
          baseUrl: Uri.https('vimeo-backend.example'),
          client: MockClient(
            (_) async => _json({
              'data': [
                {'uri': '/videos/42', 'name': 'Vimeo result'},
              ],
            }),
          ),
        ),
        dailymotionDatasource: DailymotionVideoDatasource(
          apiKey: 'public-test-key',
          playerId: 'player_1',
          client: MockClient(
            (_) async => _json({
              'list': [
                {'id': 'dm1', 'title': 'Dailymotion result'},
              ],
            }),
          ),
        ),
      );

      for (final source in VideoSource.values) {
        final results = await repository.search(source, 'result');
        expect(results, hasLength(1));
        expect(results.single.source, source);
      }
    },
  );
}

class _RecordingDatasource implements ExternalVideoDatasource {
  final List<String> queries = [];

  @override
  Future<List<ExternalVideo>> search(String query) async {
    queries.add(query);
    return const [];
  }
}
