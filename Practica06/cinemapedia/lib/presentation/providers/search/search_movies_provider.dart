import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';


final searchQueryProvider = StateProvider<String>((ref) => '');

final searchedMoviesProvider = StateNotifierProvider<SearchedMoviesNotifier, List<Movie>>((ref) {

  // `watch` (antes `read`): al cambiar de país la búsqueda usa el nuevo idioma.
  final movieRepository = ref.watch( movieRepositoryProvider );

  return SearchedMoviesNotifier(
    searchMovies: movieRepository.searchMovies,
    ref: ref
  );
});


typedef SearchMoviesCallback = Future<List<Movie>> Function(String query);

class SearchedMoviesNotifier extends StateNotifier<List<Movie>> {

  final SearchMoviesCallback searchMovies;
  final Ref ref;

  SearchedMoviesNotifier({
    required this.searchMovies,
    required this.ref,
  }): super([]);


  Future<List<Movie>> searchMoviesByQuery( String query ) async{

    final List<Movie> movies = await searchMovies(query);
    if ( !mounted ) return movies;
    ref.read(searchQueryProvider.notifier).update((state) => query);

    state = movies;
    return movies;
  }

}
