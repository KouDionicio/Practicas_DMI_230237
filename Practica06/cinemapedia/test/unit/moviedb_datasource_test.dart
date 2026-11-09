import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinemapedia/domain/errors/app_exception.dart';
import 'package:cinemapedia/infrastructure/datasource/moviedb_datasource.dart';
import 'package:cinemapedia/infrastructure/datasource/tmdb_client.dart';

/// Adaptador HTTP falso: registra cada petición y responde con JSON fijo.
class FakeAdapter implements HttpClientAdapter {
  final List<Uri> requests = [];
  final Map<String, Object> responses;
  final int statusCode;
  final DioExceptionType? failWith;

  FakeAdapter(this.responses, {this.statusCode = 200, this.failWith});

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<Uint8List>? requestStream,
      Future<void>? cancelFuture) async {
    requests.add(options.uri);
    if (failWith != null) {
      throw DioException(requestOptions: options, type: failWith!);
    }
    final body = responses[options.uri.path.replaceFirst('/3', '')] ?? {};
    return ResponseBody.fromString(jsonEncode(body), statusCode, headers: {
      Headers.contentTypeHeader: [Headers.jsonContentType],
    });
  }

  @override
  void close({bool force = false}) {}
}

const _movieList = {
  'page': 1,
  'total_pages': 1,
  'total_results': 2,
  'results': [
    {'id': 1, 'title': 'すずめの戸締まり', 'original_title': 'すずめの戸締まり', 'poster_path': '/a.jpg',
     'genre_ids': [16], 'release_date': '2022-11-11', 'vote_average': 7.9, 'vote_count': 2000},
    // Sin póster: debe filtrarse.
    {'id': 2, 'title': 'Sin póster', 'poster_path': null, 'genre_ids': [], 'release_date': ''},
  ],
};

const _releaseDates = {
  'id': 1,
  'results': [
    {'iso_3166_1': 'US', 'release_dates': [{'certification': 'PG', 'type': 3}]},
    {'iso_3166_1': 'DE', 'release_dates': [
      {'certification': '', 'type': 1},
      {'certification': '12', 'type': 4},
      {'certification': '6', 'type': 3},
    ]},
  ],
};

MoviedbDatasource _datasource(FakeAdapter adapter, {required String language, required String region}) {
  final dio = Dio(BaseOptions(baseUrl: TmdbClient.baseUrl))..httpClientAdapter = adapter;
  return MoviedbDatasource(
    apiKey: 'test-key',
    language: language,
    region: region,
    client: TmdbClient(apiKey: 'test-key', language: language, dio: dio),
  );
}

void main() {
  genresAndDiscoverTests();

  group('MoviedbDatasource: parámetros regionales', () {
    test('las listas envían language y region del país seleccionado', () async {
      final adapter = FakeAdapter({'/movie/now_playing': _movieList});
      final ds = _datasource(adapter, language: 'ja-JP', region: 'JP');

      final movies = await ds.getNowPlaying(page: 2);

      final query = adapter.requests.single.queryParameters;
      expect(adapter.requests.single.path, equals('/3/movie/now_playing'));
      expect(query['language'], equals('ja-JP'));
      expect(query['region'], equals('JP'));
      expect(query['page'], equals('2'));
      expect(query['api_key'], equals('test-key'));
      // Película sin póster filtrada; título localizado conservado.
      expect(movies.length, equals(1));
      expect(movies.single.title, equals('すずめの戸締まり'));
    });

    test('popular, top_rated, upcoming y búsqueda también envían region', () async {
      final adapter = FakeAdapter({
        '/movie/popular': _movieList, '/movie/top_rated': _movieList,
        '/movie/upcoming': _movieList, '/search/movie': _movieList,
      });
      final ds = _datasource(adapter, language: 'ar-EG', region: 'EG');
      await ds.getPopular();
      await ds.getTopRated();
      await ds.getUpcoming();
      await ds.searchMovies('Dune');

      for (final uri in adapter.requests) {
        expect(uri.queryParameters['language'], equals('ar-EG'));
        expect(uri.queryParameters['region'], equals('EG'));
      }
      expect(adapter.requests.last.queryParameters['query'], equals('Dune'));
    });

    test('búsqueda vacía no hace peticiones', () async {
      final adapter = FakeAdapter({});
      final ds = _datasource(adapter, language: 'es-MX', region: 'MX');
      expect(await ds.searchMovies('   '), isEmpty);
      expect(adapter.requests, isEmpty);
    });
  });

  group('Clasificaciones por país', () {
    test('Alemania usa su clasificación de cines (FSK 6), no la de EE. UU.', () async {
      final adapter = FakeAdapter({'/movie/1/release_dates': _releaseDates});
      final ds = _datasource(adapter, language: 'de-DE', region: 'DE');

      final certification = await ds.getCertification('1');

      expect(adapter.requests.single.path, equals('/3/movie/1/release_dates'));
      expect(certification.countryCode, equals('DE'));
      expect(certification.rating, equals('6'));
      expect(certification.isAvailable, isTrue);
    });

    test('Estados Unidos obtiene PG', () async {
      final adapter = FakeAdapter({'/movie/1/release_dates': _releaseDates});
      final certification = await _datasource(adapter, language: 'en-US', region: 'US').getCertification('1');
      expect(certification.rating, equals('PG'));
    });

    test('sin datos para el país: no disponible (nunca se toma otro país)', () async {
      final adapter = FakeAdapter({'/movie/1/release_dates': _releaseDates});
      final certification = await _datasource(adapter, language: 'ar-EG', region: 'EG').getCertification('1');
      expect(certification.isAvailable, isFalse);
      expect(certification.rating, isNull);
      expect(certification.countryCode, equals('EG'));
    });
  });

  group('Errores de red traducidos a excepciones de dominio', () {
    Future<Object?> errorOf(Future<void> Function() call) async {
      try {
        await call();
      } catch (error) {
        return error;
      }
      return null;
    }

    test('sin conexión → NetworkException', () async {
      final adapter = FakeAdapter({}, failWith: DioExceptionType.connectionError);
      final ds = _datasource(adapter, language: 'es-MX', region: 'MX');
      expect(await errorOf(() => ds.getPopular()), isA<NetworkException>());
    });

    test('HTTP 401 → UnauthorizedException (API key inválida)', () async {
      final adapter = FakeAdapter({'/movie/popular': {'status_message': 'Invalid API key'}}, statusCode: 401);
      final ds = _datasource(adapter, language: 'es-MX', region: 'MX');
      expect(await errorOf(() => ds.getPopular()), isA<UnauthorizedException>());
    });

    test('HTTP 404 → NotFoundException', () async {
      final adapter = FakeAdapter({}, statusCode: 404);
      final ds = _datasource(adapter, language: 'es-MX', region: 'MX');
      expect(await errorOf(() => ds.getMovieById('999')), isA<NotFoundException>());
    });
  });

  group('MovieDetails tolera campos nulos de TMDB', () {
    test('detalle con imdb_id, homepage, tagline y fecha nulos', () async {
      final adapter = FakeAdapter({'/movie/7': {
        'id': 7, 'title': 'Película', 'original_title': 'Film', 'imdb_id': null, 'homepage': null,
        'tagline': null, 'release_date': '', 'poster_path': null, 'backdrop_path': null,
        'genres': [{'id': 18, 'name': 'Drama'}], 'runtime': null, 'belongs_to_collection': null,
      }});
      final movie = await _datasource(adapter, language: 'es-MX', region: 'MX').getMovieById('7');
      expect(movie.title, equals('Película'));
      expect(movie.releaseDate, isNull);
      expect(movie.genreIds, equals(['Drama']));
    });
  });
}

void genresAndDiscoverTests() {
  group('Categorías: géneros y discover', () {
    test('géneros traducidos con el idioma del país', () async {
      final adapter = FakeAdapter({'/genre/movie/list': {
        'genres': [{'id': 28, 'name': '액션'}, {'id': 35, 'name': '코미디'}, {'id': 99, 'name': ''}],
      }});
      final genres = await _datasource(adapter, language: 'ko-KR', region: 'KR').getGenres();

      expect(adapter.requests.single.path, equals('/3/genre/movie/list'));
      expect(adapter.requests.single.queryParameters['language'], equals('ko-KR'));
      expect(genres.map((g) => g.name).toList(), equals(['액션', '코미디'])); // vacío descartado
    });

    test('películas por género filtradas por región y ordenadas por popularidad', () async {
      final adapter = FakeAdapter({'/discover/movie': _movieList});
      final movies = await _datasource(adapter, language: 'pt-BR', region: 'BR')
          .getMoviesByGenre(28, page: 3);

      final query = adapter.requests.single.queryParameters;
      expect(adapter.requests.single.path, equals('/3/discover/movie'));
      expect(query['with_genres'], equals('28'));
      expect(query['page'], equals('3'));
      expect(query['region'], equals('BR'));
      expect(query['language'], equals('pt-BR'));
      expect(query['sort_by'], equals('popularity.desc'));
      expect(query['include_adult'], equals('false'));
      expect(movies.length, equals(1)); // la película sin póster se filtra
    });
  });
}
