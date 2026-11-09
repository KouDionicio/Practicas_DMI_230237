import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/config/helpers/l10n_helpers.dart';
import 'package:cinemapedia/config/theme/app_theme.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/storage/favorites_provider.dart';
import 'package:cinemapedia/presentation/widgets/shared/pressable_scale.dart';

/// Cuadrícula de pósters adaptable (3 columnas en teléfono, más en tablet),
/// con paginación infinita opcional. La usan Favoritos y Categorías.
class MoviePosterGrid extends StatefulWidget {
  final List<Movie> movies;
  final VoidCallback? loadNextPage;
  final bool isLoadingMore;

  const MoviePosterGrid({
    super.key,
    required this.movies,
    this.loadNextPage,
    this.isLoadingMore = false,
  });

  @override
  State<MoviePosterGrid> createState() => _MoviePosterGridState();
}

class _MoviePosterGridState extends State<MoviePosterGrid> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(() {
      if (widget.loadNextPage == null) return;
      final position = _scrollController.position;
      if (position.pixels + 400 >= position.maxScrollExtent) widget.loadNextPage!();
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomScrollView(
      controller: _scrollController,
      physics: const BouncingScrollPhysics(parent: AlwaysScrollableScrollPhysics()),
      slivers: [
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(12, 8, 12, 12),
          sliver: SliverGrid.builder(
            gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
              maxCrossAxisExtent: 170,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 2 / 3,
            ),
            itemCount: widget.movies.length,
            itemBuilder: (context, index) => FadeInUp(
              duration: const Duration(milliseconds: 350),
              from: 12,
              child: _PosterTile(movie: widget.movies[index]),
            ),
          ),
        ),
        if (widget.isLoadingMore)
          const SliverToBoxAdapter(
            child: Padding(
              padding: EdgeInsets.only(bottom: 24),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
          ),
      ],
    );
  }
}

class _PosterTile extends ConsumerWidget {
  final Movie movie;
  const _PosterTile({required this.movie});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isFavorite = ref.watch(isFavoriteProvider(movie.id));
    final locale = context.l10n.localeName;

    return PressableScale(
      onTap: () => context.push('/home/0/movie/${movie.id}'),
      semanticLabel: movie.title,
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              movie.posterPath,
              fit: BoxFit.cover,
              loadingBuilder: (context, child, progress) => progress == null
                  ? child
                  : const ColoredBox(color: AppColors.surfaceHigh),
              errorBuilder: (context, error, stackTrace) => ColoredBox(
                color: AppColors.surfaceHigh,
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8),
                    child: Text(movie.title, textAlign: TextAlign.center, maxLines: 4),
                  ),
                ),
              ),
            ),
            // Degradado inferior + calificación
            const Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [.6, 1],
                    colors: [Colors.transparent, Colors.black87],
                  ),
                ),
              ),
            ),
            PositionedDirectional(
              start: 8,
              bottom: 6,
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, size: 15, color: AppColors.star),
                  const SizedBox(width: 2),
                  Text(
                    HumanFormats.decimal(movie.voteAverage, locale),
                    style: const TextStyle(color: AppColors.star, fontWeight: FontWeight.w700, fontSize: 12),
                  ),
                ],
              ),
            ),
            if (isFavorite)
              const PositionedDirectional(
                top: 6,
                end: 6,
                child: Icon(Icons.favorite_rounded, size: 18, color: AppColors.crimson),
              ),
          ],
        ),
      ),
    );
  }
}
