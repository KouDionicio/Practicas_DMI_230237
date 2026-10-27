import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/infrastructure/repositories/movie_repository_impl.dart';
import 'package:cinemapedia/domain/repositories/movies_repository.dart';

final movieRepositoryProvider = Provider((ref){
    return MovieRepositoryImpl(MoviesDatasource());
})