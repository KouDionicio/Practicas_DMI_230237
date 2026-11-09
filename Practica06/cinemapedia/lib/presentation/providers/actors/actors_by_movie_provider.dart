import 'package:cinemapedia/domain/entities/actor.dart';
import 'package:cinemapedia/presentation/providers/actors/actors_repository_provider.dart';
import 'package:flutter_riverpod/legacy.dart';

final actorsByMovieProvider = StateNotifierProvider<ActorsByMovieNotifier, Map<String, List<Actor>>>((ref) {
  final actorsRepository = ref.watch( actorsRepositoryProvider );

  return ActorsByMovieNotifier( getActors: actorsRepository.getActorsByMovie );
});


/*
  {
    '505642': <Actor>[],
    '505643': <Actor>[],
  }
*/

typedef GetActorsCallback = Future<List<Actor>>Function(String movieId);

class ActorsByMovieNotifier extends StateNotifier<Map<String,List<Actor>>> {

  final GetActorsCallback getActors;
  final Set<String> _inFlight = {};

  ActorsByMovieNotifier({
    required this.getActors,
  }): super({});


  /// Carga el reparto una sola vez por película. Lanza la excepción si falla
  /// para que la pantalla pueda mostrar un mensaje y reintentar.
  Future<void> loadActors( String movieId ) async {
    if ( state[movieId] != null || _inFlight.contains(movieId) ) return;
    _inFlight.add(movieId);
    try {
      final List<Actor> actors = await getActors( movieId );
      if ( !mounted ) return;
      state = { ...state, movieId: actors };
    } finally {
      _inFlight.remove(movieId);
    }
  }

}
