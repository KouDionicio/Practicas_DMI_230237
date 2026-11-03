import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';

final movieCertificationProvider = FutureProvider.family<String?, String>((
  ref,
  movieId,
) {
  return ref.watch(movieRepositoryProvider).getCertification(movieId);
});
