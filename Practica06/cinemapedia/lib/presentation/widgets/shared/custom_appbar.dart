import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemapedia/config/helpers/l10n_helpers.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/delegates/search_movie_delegate.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/shared/app_logo.dart';
import 'package:cinemapedia/presentation/widgets/shared/side_menu.dart';

/// Barra superior de Inicio: menú hamburguesa, identidad y búsqueda.
class CustomAppbar extends ConsumerWidget {
  const CustomAppbar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final titleStyle = Theme.of(context).textTheme.titleMedium;
    final l10n = context.l10n;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 4),
      child: SizedBox(
        width: double.infinity,
        child: Row(
          children: [
            const DrawerMenuButton(),
            const AppLogo(size: 30),
            const SizedBox(width: 8),
            Text('Cinemapedia', style: titleStyle),
            const Spacer(),
            IconButton(
                tooltip: l10n.searchTooltip,
                onPressed: () {
                  final searchedMovies = ref.read(searchedMoviesProvider);
                  final searchQuery = ref.read(searchQueryProvider);

                  showSearch<Movie?>(
                          query: searchQuery,
                          context: context,
                          delegate: SearchMovieDelegate(
                              searchFieldLabel: l10n.searchFieldLabel,
                              initialMovies: searchedMovies,
                              searchMovies: ref
                                  .read(searchedMoviesProvider.notifier)
                                  .searchMoviesByQuery))
                      .then((movie) {
                    if (movie == null || !context.mounted) return;

                    context.push('/home/0/movie/${movie.id}');
                  });
                },
                icon: const Icon(Icons.search_rounded))
          ],
        ),
      ),
    );
  }
}
