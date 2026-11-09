import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'movies_providers.dart';

/// Número máximo de películas del carrusel principal.
const slideshowMaxMovies = 10;

final moviesSlideshowProvider = Provider<List<Movie>>((ref){

  final nowPlayingMovies = ref.watch( nowPlayingMoviesProvider );

  // `take` evita el RangeError que producía `sublist(0, 6)` con pocas películas.
  return nowPlayingMovies.take(slideshowMaxMovies).toList();

});
