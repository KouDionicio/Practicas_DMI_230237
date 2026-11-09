import 'package:flutter/foundation.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';
import 'package:flutter_riverpod/legacy.dart';


final nowPlayingMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetchMoreMovies = ref.watch( movieRepositoryProvider ).getNowPlaying;
  return MoviesNotifier(
    fetchMoreMovies: fetchMoreMovies
  );
});

final popularMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetchMoreMovies = ref.watch( movieRepositoryProvider ).getPopular;
  return MoviesNotifier(
    fetchMoreMovies: fetchMoreMovies
  );
});

final upcomingMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetchMoreMovies = ref.watch( movieRepositoryProvider ).getUpcoming;
  return MoviesNotifier(
    fetchMoreMovies: fetchMoreMovies
  );
});

final topRatedMoviesProvider = StateNotifierProvider<MoviesNotifier, List<Movie>>((ref) {
  final fetchMoreMovies = ref.watch( movieRepositoryProvider ).getTopRated;
  return MoviesNotifier(
    fetchMoreMovies: fetchMoreMovies
  );
});



typedef MovieCallback = Future<List<Movie>> Function({ int page });

class MoviesNotifier extends StateNotifier<List<Movie>> {

  int currentPage = 0;
  bool isLoading = false;
  MovieCallback fetchMoreMovies;
  Future<void>? _currentRequest;


  MoviesNotifier({
    required this.fetchMoreMovies,
  }): super([]);

  /// Carga la primera página si todavía no existe. Lanza la excepción si
  /// falla para que la carga inicial pueda mostrar un error con reintento.
  Future<void> loadFirstPage() async {
    if ( currentPage > 0 ) return;
    if ( _currentRequest != null ) return _currentRequest;
    await _fetchNextPage();
  }

  /// Paginación infinita: los errores se registran pero no interrumpen la UI
  /// (el usuario puede volver a desplazarse para reintentar).
  Future<void> loadNextPage() async{
    if ( isLoading ) return;
    try {
      await _fetchNextPage();
      // Pausa breve para no disparar varias páginas con un mismo scroll.
      await Future.delayed(const Duration(milliseconds: 300));
    } catch (error) {
      debugPrint('MoviesNotifier.loadNextPage: $error');
    }
  }

  Future<void> _fetchNextPage() {
    isLoading = true;
    final request = () async {
      try {
        final nextPage = currentPage + 1;
        final List<Movie> movies = await fetchMoreMovies( page: nextPage );
        if ( !mounted ) return;
        currentPage = nextPage;
        final knownIds = state.map((movie) => movie.id).toSet();
        state = [...state, ...movies.where((movie) => !knownIds.contains(movie.id))];
      } finally {
        isLoading = false;
        _currentRequest = null;
      }
    }();
    _currentRequest = request;
    return request;
  }
}
