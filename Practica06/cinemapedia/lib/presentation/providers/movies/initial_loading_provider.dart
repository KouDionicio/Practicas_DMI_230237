import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'movies_providers.dart';

/// Carga la primera página de las cuatro listas de inicio.
///
/// Observa los notifiers: cuando cambia la región se crean notifiers nuevos y
/// esta carga se repite automáticamente con el nuevo idioma/país.
/// Sin reintentos automáticos: ante un error se muestra un botón "Reintentar".
final initialMoviesLoadProvider = FutureProvider<void>((ref) async {
  final notifiers = [
    ref.watch( nowPlayingMoviesProvider.notifier ),
    ref.watch( popularMoviesProvider.notifier ),
    ref.watch( topRatedMoviesProvider.notifier ),
    ref.watch( upcomingMoviesProvider.notifier ),
  ];
  await Future.wait( notifiers.map((notifier) => notifier.loadFirstPage()) );
}, retry: (retryCount, error) => null);

final initialLoadingProvider = Provider<bool>((ref) {

  final step1 = ref.watch( nowPlayingMoviesProvider ).isEmpty;
  final step2 = ref.watch( popularMoviesProvider ).isEmpty;
  final step3 = ref.watch( topRatedMoviesProvider ).isEmpty;
  final step4 = ref.watch( upcomingMoviesProvider ).isEmpty;

  if( step1 || step2 || step3 || step4 ) {
    // Sigue cargando solo mientras la carga inicial no haya terminado.
    return ref.watch( initialMoviesLoadProvider ).isLoading;
  }

  return false; // terminamos de cargar
});
