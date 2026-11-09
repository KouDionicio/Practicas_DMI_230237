import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/misc.dart' show Override;
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cinemapedia/config/helpers/l10n_helpers.dart';
import 'package:cinemapedia/config/theme/app_theme.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/domain/entities/movie_certification.dart';
import 'package:cinemapedia/domain/entities/movie_genre.dart';
import 'package:cinemapedia/domain/repositories/movies_repository.dart';
import 'package:cinemapedia/l10n/app_localizations.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';

Movie fakeMovie(int id) => Movie(
      adult: false,
      backdropPath: 'https://example.com/b$id.jpg',
      genreIds: const ['18'],
      id: id,
      originalLanguage: 'en',
      originalTitle: 'Original $id',
      overview: 'Overview $id',
      popularity: 100,
      posterPath: 'https://example.com/p$id.jpg',
      releaseDate: DateTime(2026, 1, id),
      title: 'Movie $id',
      video: false,
      voteAverage: 7.5,
      voteCount: 1200,
    );

/// Repositorio en memoria: no hace peticiones de red.
class FakeMoviesRepository extends MoviesRepository {
  final String region;
  FakeMoviesRepository(this.region);

  List<Movie> _page(int page) => List.generate(12, (i) => fakeMovie(page * 100 + i + 1));

  @override
  Future<List<Movie>> getNowPlaying({int page = 1}) async => _page(page);
  @override
  Future<List<Movie>> getPopular({int page = 1}) async => _page(page);
  @override
  Future<List<Movie>> getTopRated({int page = 1}) async => _page(page);
  @override
  Future<List<Movie>> getUpcoming({int page = 1}) async => _page(page);
  @override
  Future<Movie> getMovieById(String id) async => fakeMovie(int.parse(id));
  @override
  Future<List<Movie>> searchMovies(String query) async => [];
  @override
  Future<List<MovieGenre>> getGenres() async => region == 'JP'
      ? const [MovieGenre(id: 28, name: 'アクション'), MovieGenre(id: 35, name: 'コメディ')]
      : const [MovieGenre(id: 28, name: 'Acción'), MovieGenre(id: 35, name: 'Comedia')];
  @override
  Future<List<Movie>> getMoviesByGenre(int genreId, {int page = 1}) async =>
      List.generate(6, (i) => fakeMovie(genreId * 1000 + page * 10 + i));
  @override
  Future<MovieCertification> getCertification(String movieId) async =>
      region == 'EG' ? MovieCertification.unavailable(region) : MovieCertification(countryCode: region, rating: '12');
}

Future<List<Override>> testOverrides({Map<String, Object> prefs = const {}}) async {
  SharedPreferences.setMockInitialValues(prefs);
  final instance = await SharedPreferences.getInstance();
  return [
    sharedPreferencesProvider.overrideWithValue(instance),
    movieRepositoryProvider.overrideWith(
      (ref) => FakeMoviesRepository(ref.watch(appRegionProvider).code),
    ),
  ];
}

/// MaterialApp con la misma configuración de idioma/RTL que la app real.
class TestApp extends ConsumerWidget {
  final Widget? home;
  final RouterConfig<Object>? routerConfig;
  const TestApp({super.key, this.home, this.routerConfig});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final region = ref.watch(appRegionProvider);
    if (routerConfig != null) {
      return MaterialApp.router(
        routerConfig: routerConfig,
        theme: AppTheme(languageCode: region.languageCode).getTheme(),
        locale: region.locale,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
      );
    }
    return MaterialApp(
      theme: AppTheme(languageCode: region.languageCode).getTheme(),
      locale: region.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
      home: home,
    );
  }
}
