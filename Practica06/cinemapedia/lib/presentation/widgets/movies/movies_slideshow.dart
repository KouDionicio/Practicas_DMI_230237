import 'package:card_swiper/card_swiper.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/movies/movie_certification_provider.dart';

class MoviesSlideshow extends ConsumerStatefulWidget {
  final List<Movie> movies;
  const MoviesSlideshow({super.key, required this.movies});

  @override
  ConsumerState<MoviesSlideshow> createState() => _MoviesSlideshowState();
}

class _MoviesSlideshowState extends ConsumerState<MoviesSlideshow> {
  final _controller = SwiperController();
  int _index = 0;
  int _repeatedDirection = 0;
  int _repeatCount = 0;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _navigate(int direction) {
    final count = widget.movies.length;
    if (count < 2) return;
    _repeatCount = direction == _repeatedDirection ? _repeatCount + 1 : 1;
    _repeatedDirection = direction;
    final target = _repeatCount >= 3
        ? (direction > 0 ? count - 1 : 0)
        : (_index + direction + count) % count;
    _repeatCount = _repeatCount >= 3 ? 0 : _repeatCount;
    _controller.move(target);
  }

  @override
  Widget build(BuildContext context) {
    if (widget.movies.isEmpty) {
      return const SizedBox(
        height: 300,
        child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
      );
    }
    final safeIndex = _index.clamp(0, widget.movies.length - 1);
    final movie = widget.movies[safeIndex];
    final certification = ref.watch(
      movieCertificationProvider(movie.id.toString()),
    );
    return SizedBox(
      height: 350,
      width: double.infinity,
      child: Stack(
        children: [
          Swiper(
            controller: _controller,
            itemCount: widget.movies.length,
            loop: widget.movies.length > 1,
            autoplay: widget.movies.length > 1,
            autoplayDelay: 6000,
            viewportFraction: .88,
            scale: .94,
            onIndexChanged: (index) => setState(() => _index = index),
            itemBuilder: (context, index) => _MovieSlide(
              movie: widget.movies[index],
              certification: index == safeIndex ? certification : null,
            ),
          ),
          if (widget.movies.length > 1) ...[
            Positioned(
              left: 8,
              top: 120,
              child: _ArrowButton(
                icon: Icons.chevron_left_rounded,
                label: 'Película anterior',
                onPressed: () => _navigate(-1),
              ),
            ),
            Positioned(
              right: 8,
              top: 120,
              child: _ArrowButton(
                icon: Icons.chevron_right_rounded,
                label: 'Película siguiente',
                onPressed: () => _navigate(1),
              ),
            ),
          ],
          Positioned(
            bottom: 15,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                widget.movies.length.clamp(0, 8),
                (index) => AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  margin: const EdgeInsets.symmetric(horizontal: 3),
                  width: index == safeIndex ? 18 : 6,
                  height: 6,
                  decoration: BoxDecoration(
                    color: index == safeIndex
                        ? Theme.of(context).colorScheme.primary
                        : Colors.white38,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onPressed;
  const _ArrowButton({
    required this.icon,
    required this.label,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.black.withValues(alpha: .58),
    shape: const CircleBorder(),
    child: InkWell(
      onTap: onPressed,
      customBorder: const CircleBorder(),
      child: Tooltip(
        message: label,
        child: SizedBox(
          width: 44,
          height: 44,
          child: Icon(icon, color: Colors.white, size: 30),
        ),
      ),
    ),
  );
}

class _MovieSlide extends StatelessWidget {
  final Movie movie;
  final AsyncValue<String?>? certification;
  const _MovieSlide({required this.movie, required this.certification});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 26),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: Stack(
          fit: StackFit.expand,
          children: [
            Image.network(
              movie.backdropPath,
              fit: BoxFit.cover,
              errorBuilder: (context, error, stack) => Container(
                color: colors.surfaceContainerHighest,
                child: const Icon(Icons.movie_outlined, size: 56),
              ),
            ),
            const DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Colors.transparent, Color(0xDD08090B)],
                  stops: [.2, 1],
                ),
              ),
            ),
            Positioned(
              left: 18,
              right: 18,
              bottom: 22,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    movie.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      height: 1.05,
                    ),
                  ),
                  if (movie.originalTitle.trim().isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Original: ${movie.originalTitle}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(color: Colors.white70),
                    ),
                  ],
                  const SizedBox(height: 7),
                  Row(
                    children: [
                      _RatingStars(rating: movie.voteAverage),
                      const SizedBox(width: 3),
                      Text(
                        movie.voteAverage.toStringAsFixed(1),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      const SizedBox(width: 12),
                      const Icon(
                        Icons.local_movies_outlined,
                        size: 17,
                        color: Colors.white70,
                      ),
                      const SizedBox(width: 5),
                      Flexible(
                        child: Text(
                          certification?.when(
                                data: (value) => value == null || value.isEmpty
                                    ? 'Clasificación no disponible'
                                    : 'Clasificación $value',
                                loading: () => 'Consultando clasificación…',
                                error: (error, stack) =>
                                    'Clasificación no disponible',
                              ) ??
                              'Clasificación no disponible',
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white70,
                            fontSize: 12,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _RatingStars extends StatelessWidget {
  final double rating;
  const _RatingStars({required this.rating});

  @override
  Widget build(BuildContext context) {
    final value = (rating / 2).clamp(0, 5);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(5, (index) {
        final icon = index + 1 <= value
            ? Icons.star_rounded
            : index < value
            ? Icons.star_half_rounded
            : Icons.star_outline_rounded;
        return Icon(icon, size: 15, color: const Color(0xFFFFC857));
      }),
    );
  }
}
