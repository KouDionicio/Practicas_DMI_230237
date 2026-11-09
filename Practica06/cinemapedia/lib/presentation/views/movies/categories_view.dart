import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/config/helpers/l10n_helpers.dart';
import 'package:cinemapedia/config/theme/app_theme.dart';
import 'package:cinemapedia/domain/entities/movie_genre.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/movies/movie_poster_grid.dart';
import 'package:cinemapedia/presentation/widgets/shared/side_menu.dart';
import 'package:cinemapedia/presentation/widgets/shared/state_message_view.dart';

/// Exploración por géneros de TMDB.
///
/// Los nombres de los géneros llegan traducidos al idioma del país elegido y
/// las películas se filtran por su región (`/discover/movie`).
class CategoriesView extends ConsumerStatefulWidget {
  const CategoriesView({super.key});

  @override
  ConsumerState<CategoriesView> createState() => _CategoriesViewState();
}

class _CategoriesViewState extends ConsumerState<CategoriesView> {
  int? _selectedGenreId;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final genres = ref.watch(movieGenresProvider);

    return Scaffold(
      appBar: AppBar(
        leading: const DrawerMenuButton(),
        title: Text(l10n.navCategories),
      ),
      body: genres.when(
        skipLoadingOnRefresh: false,
        loading: () => const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        error: (error, _) => StateMessageView(
          icon: Icons.cloud_off_rounded,
          title: l10n.errorLoadGenres,
          message: l10n.describeError(error),
          actionLabel: l10n.retry,
          isError: true,
          onAction: () => ref.invalidate(movieGenresProvider),
        ),
        data: (genres) {
          if (genres.isEmpty) {
            return StateMessageView(icon: Icons.category_outlined, title: l10n.errorLoadGenres);
          }
          // Género seleccionado (el primero por defecto).
          final selected = genres.firstWhere(
            (genre) => genre.id == _selectedGenreId,
            orElse: () => genres.first,
          );

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsetsDirectional.fromSTEB(16, 4, 16, 8),
                child: Text(
                  l10n.categoriesHint,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ),
              _GenreChips(
                genres: genres,
                selectedId: selected.id,
                onSelected: (genre) => setState(() => _selectedGenreId = genre.id),
              ),
              const SizedBox(height: 4),
              Expanded(child: _GenreMovies(key: ValueKey(selected.id), genreId: selected.id)),
            ],
          );
        },
      ),
    );
  }
}

class _GenreChips extends StatelessWidget {
  final List<MovieGenre> genres;
  final int selectedId;
  final ValueChanged<MovieGenre> onSelected;

  const _GenreChips({required this.genres, required this.selectedId, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 48,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: genres.length,
        separatorBuilder: (_, _) => const SizedBox(width: 8),
        itemBuilder: (context, index) {
          final genre = genres[index];
          final isSelected = genre.id == selectedId;
          return ChoiceChip(
            key: Key('genre-chip-${genre.id}'),
            label: Text(genre.name),
            selected: isSelected,
            showCheckmark: false,
            selectedColor: AppColors.violet.withValues(alpha: .35),
            side: BorderSide(color: isSelected ? AppColors.violetLight : AppColors.outline),
            labelStyle: TextStyle(
              color: isSelected ? Colors.white : AppColors.textPrimary,
              fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            ),
            onSelected: (_) => onSelected(genre),
          );
        },
      ),
    );
  }
}

class _GenreMovies extends ConsumerWidget {
  final int genreId;
  const _GenreMovies({super.key, required this.genreId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final firstPage = ref.watch(genreFirstPageProvider(genreId));
    final movies = ref.watch(moviesByGenreProvider(genreId));

    if (movies.isEmpty) {
      if (firstPage.isLoading) {
        return const Center(child: CircularProgressIndicator(strokeWidth: 2));
      }
      if (firstPage.hasError) {
        return StateMessageView(
          icon: Icons.cloud_off_rounded,
          title: l10n.errorLoadMovies,
          message: l10n.describeError(firstPage.error),
          actionLabel: l10n.retry,
          isError: true,
          onAction: () => ref.invalidate(genreFirstPageProvider(genreId)),
        );
      }
      return StateMessageView(icon: Icons.movie_filter_outlined, title: l10n.categoryEmpty);
    }

    return MoviePosterGrid(
      movies: movies,
      loadNextPage: () => ref.read(moviesByGenreProvider(genreId).notifier).loadNextPage(),
    );
  }
}
