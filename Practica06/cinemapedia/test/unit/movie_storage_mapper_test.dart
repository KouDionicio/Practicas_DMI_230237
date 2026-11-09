import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/infrastructure/mappers/movie_storage_mapper.dart';

void main() {
  group('MovieStorageMapper (favoritos guardados en el teléfono)', () {
    final movie = Movie(
      adult: false,
      backdropPath: 'https://image.tmdb.org/t/p/w500/b.jpg',
      genreIds: const ['Drama', 'アニメ'],
      id: 42,
      originalLanguage: 'ja',
      originalTitle: 'すずめの戸締まり',
      overview: 'Sinopsis',
      popularity: 88.5,
      posterPath: 'https://image.tmdb.org/t/p/w500/p.jpg',
      releaseDate: DateTime(2022, 11, 11),
      title: 'Suzume',
      video: false,
      voteAverage: 7.9,
      voteCount: 2100,
    );

    test('ida y vuelta por JSON conserva todos los datos', () {
      final restored = MovieStorageMapper.fromJson(
        jsonDecode(jsonEncode(MovieStorageMapper.toJson(movie))) as Map<String, dynamic>,
      );
      expect(restored.id, equals(42));
      expect(restored.title, equals('Suzume'));
      expect(restored.originalTitle, equals('すずめの戸締まり'));
      expect(restored.genreIds, equals(['Drama', 'アニメ']));
      expect(restored.releaseDate, equals(DateTime(2022, 11, 11)));
      expect(restored.voteAverage, equals(7.9));
      expect(restored.voteCount, equals(2100));
      expect(restored.posterPath, equals(movie.posterPath));
    });

    test('tolera datos incompletos (fecha nula, campos faltantes)', () {
      final restored = MovieStorageMapper.fromJson({'id': 7, 'title': 'X', 'releaseDate': null, 'voteAverage': 8});
      expect(restored.id, equals(7));
      expect(restored.releaseDate, isNull);
      expect(restored.voteAverage, equals(8.0));
      expect(restored.genreIds, isEmpty);
    });
  });
}
