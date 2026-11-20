import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinemapedia/domain/errors/app_exception.dart';
import 'package:cinemapedia/infrastructure/datasource/tmdb_client.dart';
import 'package:cinemapedia/infrastructure/datasource/tv_moviedb_datasource.dart';

/// Adaptador HTTP falso: registra cada petición y responde con JSON fijo.
class _FakeAdapter implements HttpClientAdapter {
  final List<Uri> requests = [];
  final Map<String, Object> responses;
  final DioExceptionType? failWith;

  _FakeAdapter(this.responses, {this.failWith});

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream,
      Future<void>? cancelFuture) async {
    requests.add(options.uri);
    if (failWith != null) throw DioException(requestOptions: options, type: failWith!);
    final body = responses[options.uri.path.replaceFirst('/3', '')] ?? {};
    return ResponseBody.fromString(jsonEncode(body), 200, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

const _tvList = {
  'page': 1,
  'total_pages': 1,
  'results': [
    {'id': 1, 'name': '오징어 게임', 'original_name': '오징어 게임', 'poster_path': '/sq.jpg',
     'genre_ids': [18], 'first_air_date': '2021-09-17', 'vote_average': 7.8, 'vote_count': 15000},
    // Sin póster: debe filtrarse (igual que en películas).
    {'id': 2, 'name': 'Sin póster', 'poster_path': null, 'first_air_date': ''},
  ],
};

TvMovieDbDatasource _datasource(_FakeAdapter adapter, {required String language, required String region}) {
  final dio = Dio(BaseOptions(baseUrl: TmdbClient.baseUrl))..httpClientAdapter = adapter;
  return TvMovieDbDatasource(
    apiKey: 'test-key',
    language: language,
    region: region,
    client: TmdbClient(apiKey: 'test-key', language: language, dio: dio),
  );
}

void main() {
  group('Series: parámetros de TMDB', () {
    test('airing_today envía language y la zona horaria del país', () async {
      final adapter = _FakeAdapter({'/tv/airing_today': _tvList});
      final series = await _datasource(adapter, language: 'ko-KR', region: 'KR').getAiringToday(page: 2);

      final uri = adapter.requests.single;
      expect(uri.path, equals('/3/tv/airing_today'));
      expect(uri.queryParameters['language'], equals('ko-KR'));
      expect(uri.queryParameters['timezone'], equals('Asia/Seoul'));
      expect(uri.queryParameters['page'], equals('2'));
      expect(uri.queryParameters['api_key'], equals('test-key'));
      expect(series.length, equals(1));
      expect(series.single.name, equals('오징어 게임'));
      expect(series.single.firstAirDate, equals(DateTime(2021, 9, 17)));
    });

    test('on_the_air usa la zona horaria; popular y top_rated solo el idioma', () async {
      final adapter = _FakeAdapter({
        '/tv/on_the_air': _tvList, '/tv/popular': _tvList, '/tv/top_rated': _tvList,
      });
      final ds = _datasource(adapter, language: 'ar-EG', region: 'EG');
      await ds.getOnTheAir();
      await ds.getPopular();
      await ds.getTopRated();

      expect(adapter.requests[0].path, equals('/3/tv/on_the_air'));
      expect(adapter.requests[0].queryParameters['timezone'], equals('Africa/Cairo'));
      expect(adapter.requests[1].path, equals('/3/tv/popular'));
      expect(adapter.requests[2].path, equals('/3/tv/top_rated'));
      for (final uri in adapter.requests) {
        expect(uri.queryParameters['language'], equals('ar-EG'));
      }
      // TMDB no acepta timezone en popular/top_rated: no se envía.
      expect(adapter.requests[1].queryParameters.containsKey('timezone'), isFalse);
      expect(adapter.requests[2].queryParameters.containsKey('timezone'), isFalse);
    });

    test('detalle tolera campos nulos y extrae temporadas, episodios y cadenas', () async {
      final adapter = _FakeAdapter({'/tv/7': {
        'id': 7, 'name': 'Serie', 'original_name': 'Show', 'poster_path': null, 'backdrop_path': null,
        'first_air_date': null, 'genres': [{'id': 18, 'name': 'Drama'}],
        'number_of_seasons': 3, 'number_of_episodes': 24,
        'networks': [{'id': 1, 'name': 'HBO'}, {'id': 2, 'name': null}],
      }});
      final series = await _datasource(adapter, language: 'es-MX', region: 'MX').getSeriesById('7');
      expect(series.name, equals('Serie'));
      expect(series.originalName, equals('Show'));
      expect(series.firstAirDate, isNull);
      expect(series.genreIds, equals(['Drama']));
      expect(series.numberOfSeasons, equals(3));
      expect(series.numberOfEpisodes, equals(24));
      expect(series.networks, equals(['HBO']));
    });

    test('reparto desde /tv/{id}/credits reutilizando el modelo de películas', () async {
      final adapter = _FakeAdapter({'/tv/7/credits': {
        'id': 7,
        'cast': [{'id': 9, 'name': 'Lee Jung-jae', 'character': 'Seong Gi-hun', 'profile_path': '/p.jpg'}],
      }});
      final cast = await _datasource(adapter, language: 'ko-KR', region: 'KR').getCast('7');
      expect(adapter.requests.single.path, equals('/3/tv/7/credits'));
      expect(cast.single.name, equals('Lee Jung-jae'));
      expect(cast.single.character, equals('Seong Gi-hun'));
    });
  });

  group('Series: clasificación de contenido por país', () {
    const ratings = {
      'id': 7,
      'results': [
        {'iso_3166_1': 'US', 'rating': 'TV-MA'},
        {'iso_3166_1': 'KR', 'rating': '19'},
        {'iso_3166_1': 'DE', 'rating': ''},
      ],
    };

    test('Corea obtiene su clasificación (19), no la de EE. UU.', () async {
      final adapter = _FakeAdapter({'/tv/7/content_ratings': ratings});
      final rating = await _datasource(adapter, language: 'ko-KR', region: 'KR').getContentRating('7');
      expect(adapter.requests.single.path, equals('/3/tv/7/content_ratings'));
      expect(rating.rating, equals('19'));
      expect(rating.countryCode, equals('KR'));
    });

    test('vacía o inexistente → no disponible (nunca se toma otro país)', () async {
      for (final region in ['DE', 'EG']) {
        final adapter = _FakeAdapter({'/tv/7/content_ratings': ratings});
        final rating = await _datasource(adapter, language: 'de-DE', region: region).getContentRating('7');
        expect(rating.isAvailable, isFalse);
        expect(rating.countryCode, equals(region));
      }
    });

    test('sin conexión → NetworkException', () async {
      final adapter = _FakeAdapter({}, failWith: DioExceptionType.connectionError);
      Object? error;
      try {
        await _datasource(adapter, language: 'es-MX', region: 'MX').getPopular();
      } catch (e) {
        error = e;
      }
      expect(error, isA<NetworkException>());
    });
  });
}
