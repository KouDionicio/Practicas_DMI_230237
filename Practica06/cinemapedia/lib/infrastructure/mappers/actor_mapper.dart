import 'package:cinemapedia/domain/entities/actor.dart';
import 'package:cinemapedia/infrastructure/datasource/tmdb_client.dart';
import 'package:cinemapedia/infrastructure/models/moviedb/credits_response.dart';

class ActorMapper {
  static Actor castToEntity( Cast cast ) =>
      Actor(
        id: cast.id,
        name: cast.name,
        profilePath: cast.profilePath != null
        ? '${TmdbClient.imageBaseUrl}${ cast.profilePath }'
        : 'https://st3.depositphotos.com/4111759/13425/v/600/depositphotos_134255710-stock-illustration-avatar-vector-male-profile-gray.jpg',
        character: cast.character,
      );
}
