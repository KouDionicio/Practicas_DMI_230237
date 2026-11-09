import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/config/constants/environment.dart';
import 'package:cinemapedia/domain/repositories/actors_repository.dart';
import 'package:cinemapedia/infrastructure/datasource/actor_moviedb_datasource.dart';
import 'package:cinemapedia/infrastructure/repositories/actor_repository_impl.dart';
import 'package:cinemapedia/presentation/providers/settings/app_region_provider.dart';

/// Repositorio de actores en el idioma actual (los nombres de personajes
/// también se localizan en TMDB).
final actorsRepositoryProvider = Provider<ActorsRepository>((ref) {
  final languageTag = ref.watch(appRegionProvider.select((r) => r.tmdbLanguage));
  return ActorRepositoryImpl(
    ActorMovieDbDatasource(apiKey: Environment.theMovieDbKey, language: languageTag),
  );
});
