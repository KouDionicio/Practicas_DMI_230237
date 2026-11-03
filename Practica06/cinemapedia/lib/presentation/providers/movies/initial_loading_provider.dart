import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'movies_providers.dart';

final initialLoadingProvider = Provider<bool>((ref) {
  final step1 = ref.watch(nowPlayingMoviesProvider).isEmpty;
  final step2 = ref.watch(popularMoviesProvider).isEmpty;
  final step3 = ref.watch(topRatedMoviesProvider).isEmpty;
  final step4 = ref.watch(upcomingMoviesProvider).isEmpty;

  if (step1 || step2 || step3 || step4) return true;

  return false;
});

final initialLoadingErrorProvider = Provider<bool>((ref) {
  ref.watch(nowPlayingMoviesProvider);
  ref.watch(popularMoviesProvider);
  ref.watch(topRatedMoviesProvider);
  ref.watch(upcomingMoviesProvider);
  return ref.read(nowPlayingMoviesProvider.notifier).hasError ||
      ref.read(popularMoviesProvider.notifier).hasError ||
      ref.read(topRatedMoviesProvider.notifier).hasError ||
      ref.read(upcomingMoviesProvider.notifier).hasError;
});
