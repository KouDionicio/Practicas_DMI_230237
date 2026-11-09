import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/config/helpers/l10n_helpers.dart';
import 'package:cinemapedia/config/theme/app_theme.dart';
import 'package:cinemapedia/presentation/providers/storage/favorites_provider.dart';
import 'package:cinemapedia/presentation/widgets/movies/movie_poster_grid.dart';
import 'package:cinemapedia/presentation/widgets/shared/side_menu.dart';
import 'package:cinemapedia/presentation/widgets/shared/state_message_view.dart';


/// Películas favoritas guardadas en el teléfono.
class FavoritesView extends ConsumerWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final favorites = ref.watch(favoriteMoviesProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const DrawerMenuButton(),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.navFavorites),
            if (favorites.isNotEmpty)
              Text(
                l10n.favoritesCount(HumanFormats.integer(favorites.length, l10n.localeName)),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
          ],
        ),
      ),
      body: favorites.isEmpty
          ? StateMessageView(
              icon: Icons.favorite_outline_rounded,
              title: l10n.favoritesEmptyTitle,
              message: l10n.favoritesEmptyMessage,
              actionLabel: l10n.goHome,
              onAction: () => context.go('/home/0'),
            )
          : MoviePosterGrid(movies: favorites),
    );
  }
}
