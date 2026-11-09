import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:cinemapedia/domain/entities/movie.dart';

final movieInfoProvider = StateNotifierProvider<MovieMapNotifier, Map<String, Movie>>((ref) {
  final movieRepository = ref.watch( movieRepositoryProvider );
  return MovieMapNotifier(getMovie: movieRepository.getMovieById );
});


/*
  {
    '505642': Movie(),
    '505643': Movie(),
  }
*/

typedef GetMovieCallback = Future<Movie>Function(String movieId);

class MovieMapNotifier extends StateNotifier<Map<String,Movie>> {

  final GetMovieCallback getMovie;
  final Map<String, Future<void>> _inFlight = {};

  MovieMapNotifier({
    required this.getMovie,
  }): super({});


  /// Carga el detalle una sola vez; llamadas simultáneas comparten la misma
  /// petición. Lanza la excepción si falla.
  Future<void> loadMovie( String movieId ) {
    if ( state[movieId] != null ) return Future.value();
    return _inFlight[movieId] ??= _load(movieId).whenComplete(() => _inFlight.remove(movieId));
  }

  Future<void> _load( String movieId ) async {
    final movie = await getMovie( movieId );
    if ( !mounted ) return;
    state = { ...state, movieId: movie };
  }

}
