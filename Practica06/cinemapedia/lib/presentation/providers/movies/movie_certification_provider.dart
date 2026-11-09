import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/domain/entities/movie_certification.dart';
import 'package:cinemapedia/presentation/providers/movies/movies_repository_provider.dart';

/// Clasificación por edad de una película para la región seleccionada.
///
/// * Se consulta `GET /movie/{id}/release_dates` una sola vez por película y
///   región (la familia actúa como caché mientras navegas por el carrusel).
/// * Al cambiar de país, el repositorio cambia y la caché se invalida sola.
final movieCertificationProvider =
    FutureProvider.family<MovieCertification, int>((ref, movieId) {
  final repository = ref.watch(movieRepositoryProvider);
  return repository.getCertification(movieId.toString());
}, retry: (retryCount, error) => null);
