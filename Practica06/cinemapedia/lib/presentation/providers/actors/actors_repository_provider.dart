import 'package:cinemapedia/infrastructure/datasource/actor_moviedb_datasource.dart';
import 'package:cinemapedia/infrastructure/repositories/actor_repository_impl.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/presentation/providers/settings/country_provider.dart';

// Inmutable
final actorsRepositoryProvider = Provider((ref) {
  return ActorRepositoryImpl(
    ActorMovieDbDatasource(country: ref.watch(selectedCountryProvider)),
  );
});
