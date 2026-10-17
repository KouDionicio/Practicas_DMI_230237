import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:toktik/domain/datasources/external_video_datasource.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/domain/errors/external_video_exception.dart';
import 'package:toktik/infrastructure/datasources/peertube_video_datasource.dart';
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
        expect(request.url.queryParameters['maxResults'], '50');
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

    test('uses YouTube continuation tokens for the next result page', () async {
      final client = MockClient((request) async {
        expect(request.url.queryParameters['pageToken'], 'next-page');
        return _json({'items': [], 'nextPageToken': 'page-after-next'});
      });
      final page = await YouTubeVideoDatasource(
        apiKey: 'key',
        client: client,
      ).searchPage('cats', pageToken: 'next-page');

      expect(page.videos, isEmpty);
      expect(page.nextPageToken, 'page-after-next');
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
      'uses the direct API with the read-only token if no backend is set',
      () async {
        final client = MockClient((request) async {
          expect(request.url.host, 'api.vimeo.com');
          expect(request.url.path, '/videos');
          expect(request.url.queryParameters['query'], 'travel');
          expect(request.headers['Authorization'], 'Bearer read-only-token');
          return _json({
            'data': [
              {'uri': '/videos/42', 'name': 'Travel'},
            ],
          });
        });

        final videos = await VimeoVideoDatasource(
          baseUrl: null,
          token: 'read-only-token',
          client: client,
        ).search('travel');

        expect(videos.single.id, 'vimeo:42');
      },
    );

    test(
      'falls back to the direct API when the backend is unreachable',
      () async {
        final requestedHosts = <String>[];
        final client = MockClient((request) async {
          requestedHosts.add(request.url.host);
          if (request.url.host == 'backend.example') {
            throw http.ClientException('Connection refused');
          }
          expect(request.url.host, 'api.vimeo.com');
          expect(request.headers['Authorization'], 'Bearer read-only-token');
          return _json({
            'data': [
              {'uri': '/videos/42', 'name': 'Travel'},
            ],
          });
        });

        final videos = await VimeoVideoDatasource(
          baseUrl: Uri.https('backend.example'),
          token: 'read-only-token',
          client: client,
        ).search('travel');

        expect(requestedHosts, ['backend.example', 'api.vimeo.com']);
        expect(videos.single.id, 'vimeo:42');
      },
    );

    test(
      'reports a clear error when neither Vimeo connection is configured',
      () async {
        await expectLater(
          VimeoVideoDatasource(baseUrl: null).search('query'),
          throwsA(
            isA<ExternalVideoConfigurationException>().having(
              (error) => error.message,
              'message',
              contains('VIMEO_TOKEN'),
            ),
          ),
        );
      },
    );

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

  group('PeerTube datasource', () {
    test(
      'searches the configured instance and maps official embed fields',
      () async {
        final client = MockClient((request) async {
          expect(request.url.host, 'videos.example');
          expect(request.url.path, '/api/v1/search/videos');
          expect(request.url.queryParameters['search'], 'cooking & travel');
          expect(request.url.queryParameters['count'], '12');
          expect(request.url.queryParameters['sort'], '-views');
          expect(request.headers.containsKey('Authorization'), isFalse);
          return _json({
            'data': [
              {
                'uuid': 'a1b2c3d4-0000-4000-8000-000000000001',
                'shortUUID': 'sWxgbBUu1ScQkHqz831Qqi',
                'name': 'Cooking at home',
                'description': 'Pasta',
                'thumbnailPath': '/lazy-static/thumbnails/cooking.jpg',
                'embedPath':
                    '/videos/embed/a1b2c3d4-0000-4000-8000-000000000001',
                'duration': 125,
                'url': 'https://videos.example/w/sWxgbBUu1ScQkHqz831Qqi',
              },
              {
                'uuid': 'a1b2c3d4-0000-4000-8000-000000000002',
                'name': 'Cooking around the world',
                'description': 'Another creator',
              },
              {
                'uuid': 'a1b2c3d4-0000-4000-8000-000000000001',
                'name': 'Duplicate result',
              },
            ],
          });
        });

        final videos = await PeerTubeVideoDatasource(
          baseUrl: Uri.https('videos.example'),
          count: 12,
          client: client,
        ).search(' cooking & travel ');

        expect(videos.map((video) => video.id), [
          'peertube:a1b2c3d4-0000-4000-8000-000000000001',
          'peertube:a1b2c3d4-0000-4000-8000-000000000002',
        ]);
        expect(videos.first.title, 'Cooking at home');
        expect(videos.first.description, 'Pasta');
        expect(
          videos.first.thumbnailUrl,
          'https://videos.example/lazy-static/thumbnails/cooking.jpg',
        );
        expect(videos.first.durationSeconds, 125);
        expect(videos.first.embedUrl.host, 'videos.example');
        expect(
          videos.first.embedUrl.path,
          '/videos/embed/a1b2c3d4-0000-4000-8000-000000000001',
        );
        expect(videos.first.watchUrl.path, '/w/sWxgbBUu1ScQkHqz831Qqi');
      },
    );

    test('uses the public default instance without API credentials', () async {
      final client = MockClient((request) async {
        expect(request.url.host, 'peertube.cpy.re');
        expect(request.url.path, '/api/v1/search/videos');
        return _json({'data': []});
      });
      expect(
        await PeerTubeVideoDatasource(client: client).search('query'),
        isEmpty,
      );
    });

    test('rejects invalid instance configuration and result limits', () async {
      await expectLater(
        PeerTubeVideoDatasource(
          baseUrl: Uri.http('videos.example'),
          client: MockClient((_) async => fail('Unexpected API request')),
        ).search('query'),
        throwsA(isA<ExternalVideoConfigurationException>()),
      );
      await expectLater(
        () => PeerTubeVideoDatasource(count: 101),
        throwsArgumentError,
      );
    });

    test(
      'returns no results for an empty query without making a request',
      () async {
        final videos = await PeerTubeVideoDatasource(
          client: MockClient((_) async => fail('Unexpected API request')),
        ).search('   ');
        expect(videos, isEmpty);
      },
    );

    test(
      'preserves HTTP authentication failures and reports rate limiting',
      () async {
        final unauthorized = PeerTubeVideoDatasource(
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

        final rateLimited = PeerTubeVideoDatasource(
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

    test(
      'rejects malformed response collections, invalid IDs, and JSON',
      () async {
        final incomplete = PeerTubeVideoDatasource(
          client: MockClient(
            (_) async => _json({
              'data': [
                {'name': 'No UUID'},
              ],
            }),
          ),
        );
        await expectLater(incomplete.search('query'), throwsFormatException);
        final invalidId = PeerTubeVideoDatasource(
          client: MockClient(
            (_) async => _json({
              'data': [
                {'uuid': '../not-a-video'},
              ],
            }),
          ),
        );
        await expectLater(invalidId.search('query'), throwsFormatException);
        final untrustedUrl = PeerTubeVideoDatasource(
          client: MockClient(
            (_) async => _json({
              'data': [
                {
                  'uuid': 'a1b2c3d4-0000-4000-8000-000000000001',
                  'url':
                      'https://attacker.example/videos/watch/'
                      'a1b2c3d4-0000-4000-8000-000000000001',
                },
              ],
            }),
          ),
        );
        await expectLater(untrustedUrl.search('query'), throwsFormatException);
        final malformedJson = PeerTubeVideoDatasource(
          client: MockClient((_) async => http.Response('not json', 200)),
        );
        await expectLater(malformedJson.search('query'), throwsFormatException);
      },
    );

    test('returns empty results from the search endpoint', () async {
      final videos = await PeerTubeVideoDatasource(
        client: MockClient((_) async => _json({'data': []})),
      ).search('no matching videos');
      expect(videos, isEmpty);
    });

    test(
      'reports network failures instead of returning successful empties',
      () async {
        final datasource = PeerTubeVideoDatasource(
          client: MockClient(
            (_) async => throw http.ClientException('offline'),
          ),
        );
        await expectLater(
          datasource.search('query'),
          throwsA(isA<ExternalVideoNetworkException>()),
        );
      },
    );
  });

  test(
    'repository dispatches each source to its configured datasource',
    () async {
      final youtube = _RecordingDatasource();
      final vimeo = _RecordingDatasource();
      final peerTube = _RecordingDatasource();
      final repository = ExternalVideoRepositoryImpl(
        youtubeDatasource: youtube,
        vimeoDatasource: vimeo,
        peerTubeDatasource: peerTube,
      );

      for (final source in VideoSource.values.where(
        (source) => source.isExternal,
      )) {
        await repository.search(source, 'query');
      }

      expect(youtube.queries, ['query']);
      expect(vimeo.queries, ['query']);
      expect(peerTube.queries, ['query']);
      expect(
        () => repository.search(VideoSource.local, 'query'),
        throwsFormatException,
      );
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
        peerTubeDatasource: PeerTubeVideoDatasource(
          client: MockClient(
            (_) async => _json({
              'data': [
                {
                  'uuid': 'a1b2c3d4-0000-4000-8000-000000000003',
                  'name': 'PeerTube result',
                },
              ],
            }),
          ),
        ),
      );

      for (final source in VideoSource.values.where(
        (source) => source.isExternal,
      )) {
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
