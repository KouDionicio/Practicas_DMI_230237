import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/infrastructure/repositories/movie_repository_impl.dart';
import 'package:cinemapedia/domain/repositories/movies_repository.dart';
import 'package:cinemapedia/infrastructure/datasource/moviedb_datasource.dart';
import 'package:cinemapedia/presentation/providers/settings/country_provider.dart';

final movieRepositoryProvider = Provider<MoviesRepository>((ref) {
  final country = ref.watch(selectedCountryProvider);
  return MovieRepositoryImpl(MoviedbDatasource(country: country));
});
