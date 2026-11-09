import 'package:cinemapedia/domain/datasources/actors_datasource.dart';
import 'package:cinemapedia/domain/entities/actor.dart';
import 'package:cinemapedia/infrastructure/datasource/tmdb_client.dart';
import 'package:cinemapedia/infrastructure/mappers/actor_mapper.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/credits_response.dart';

class ActorMovieDbDatasource extends ActorsDatasource {

  final TmdbClient client;

  ActorMovieDbDatasource({
    required String apiKey,
    required String language,
    TmdbClient? client,
  }) : client = client ?? TmdbClient(apiKey: apiKey, language: language);

  @override
  Future<List<Actor>> getActorsByMovie(String movieId) async{

    final json = await client.get('/movie/$movieId/credits');

    final castResponse = CreditsResponse.fromJson(json);

    List<Actor> actors = castResponse.cast.map(
      (cast) => ActorMapper.castToEntity(cast)
    ).toList();

    return actors;
  }

}
