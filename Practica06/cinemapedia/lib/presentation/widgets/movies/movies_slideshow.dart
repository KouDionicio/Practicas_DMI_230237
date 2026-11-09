import 'dart:async';
import 'dart:ui' show ImageFilter;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_router/go_router.dart';

import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/config/helpers/l10n_helpers.dart';
import 'package:cinemapedia/config/theme/app_theme.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/widgets/movies/movie_info_panel.dart';
import 'package:cinemapedia/presentation/widgets/movies/triple_tap_tracker.dart';
import 'package:cinemapedia/presentation/widgets/shared/pressable_scale.dart';

/// Carrusel principal de películas.
///
/// * Póster central con los vecinos reducidos; se desliza horizontalmente.
/// * Flechas `<` y `>`: una pulsación cambia de película; tres pulsaciones
///   consecutivas en la misma flecha saltan a la primera o a la última.
/// * [MovieInfoPanel] debajo, siempre sincronizado con el póster visible.
/// * Reproducción automática que se pausa en cuanto el usuario interactúa.
/// * En árabe (RTL) el orden y las flechas se invierten de forma natural.
class MoviesSlideshow extends StatefulWidget {

  final List<Movie> movies;
  final bool autoplay;
  final Duration autoplayInterval;
  final void Function(Movie movie)? onMovieTap;

  const MoviesSlideshow({
    super.key,
    required this.movies,
    this.autoplay = true,
    this.autoplayInterval = const Duration(seconds: 7),
    this.onMovieTap,
  });

  @override
  State<MoviesSlideshow> createState() => MoviesSlideshowState();
}

class MoviesSlideshowState extends State<MoviesSlideshow> {

  static const _viewportFraction = .58;
  static const _pauseAfterInteraction = Duration(seconds: 12);

  final _controller = PageController(viewportFraction: _viewportFraction);
  final _tracker = TripleTapTracker();

  int _selected = 0;
  int _animationToken = 0;
  bool _programmaticScroll = false;

  Timer? _autoplayTimer;
  DateTime _autoplayPausedUntil = DateTime.fromMillisecondsSinceEpoch(0);

  Timer? _jumpBadgeTimer;
  String? _jumpBadgeText;

  /// Se actualiza en build: falso cuando otra pantalla está encima.
  bool _routeIsCurrent = true;

  /// Índice de la película seleccionada (expuesto para pruebas).
  int get selectedIndex => _selected;

  int get _lastIndex => widget.movies.length - 1;

  @override
  void initState() {
    super.initState();
    _restartAutoplay();
  }

  @override
  void didUpdateWidget(covariant MoviesSlideshow oldWidget) {
    super.didUpdateWidget(oldWidget);

    final listChanged = !_sameIds(oldWidget.movies, widget.movies);
    if (listChanged) {
      // Lista nueva (p. ej. cambio de país) o distinta longitud: el contador
      // de pulsaciones ya no tiene sentido y la selección debe ser válida.
      _tracker.reset();
      final firstChanged = oldWidget.movies.isEmpty ||
          widget.movies.isEmpty ||
          oldWidget.movies.first.id != widget.movies.first.id;
      final newIndex = firstChanged ? 0 : _selected.clamp(0, _lastIndex < 0 ? 0 : _lastIndex);
      _selected = newIndex;
      if (_controller.hasClients) _controller.jumpToPage(newIndex);
    }

    if (oldWidget.autoplay != widget.autoplay ||
        oldWidget.autoplayInterval != widget.autoplayInterval) {
      _restartAutoplay();
    }
  }

  static bool _sameIds(List<Movie> a, List<Movie> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id) return false;
    }
    return true;
  }

  @override
  void dispose() {
    _autoplayTimer?.cancel();
    _jumpBadgeTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  // ------------------------------------------------------------ autoplay

  void _restartAutoplay() {
    _autoplayTimer?.cancel();
    if (!widget.autoplay) return;
    _autoplayTimer = Timer.periodic(widget.autoplayInterval, (_) => _onAutoplayTick());
  }

  void _pauseAutoplay() {
    _autoplayPausedUntil = DateTime.now().add(_pauseAfterInteraction);
  }

  void _onAutoplayTick() {
    if (!mounted || widget.movies.length < 2) return;
    if (DateTime.now().isBefore(_autoplayPausedUntil)) return;
    // No avanzar cuando otra pantalla (detalle, configuración) está encima.
    if (!_routeIsCurrent) return;
    _goTo(_selected >= _lastIndex ? 0 : _selected + 1);
  }

  // ---------------------------------------------------------- navegación

  /// Lógica de las flechas (pública para poder probarla).
  void handleArrow(CarouselDirection direction) {
    if (widget.movies.isEmpty) return;
    _pauseAutoplay();

    final isTriple = _tracker.registerTap(direction);
    final target = isTriple
        ? (direction == CarouselDirection.next ? _lastIndex : 0)
        : (_selected + (direction == CarouselDirection.next ? 1 : -1)).clamp(0, _lastIndex);

    if (target == _selected) return;

    if (isTriple) {
      HapticFeedback.mediumImpact();
      _showJumpBadge(direction == CarouselDirection.next
          ? context.l10n.carouselJumpedLast
          : context.l10n.carouselJumpedFirst);
    } else {
      HapticFeedback.selectionClick();
    }
    _goTo(target, isJump: isTriple);
  }

  /// Selección directa (tocar un póster lateral o un indicador). Cuenta como
  /// "seleccionar otra película", así que reinicia el contador.
  void _selectDirectly(int index) {
    _pauseAutoplay();
    _tracker.reset();
    if (index != _selected) _goTo(index);
  }

  void _goTo(int index, {bool isJump = false}) {
    if (index < 0 || index > _lastIndex) return;
    final distance = (index - _selected).abs();
    setState(() => _selected = index);
    if (!_controller.hasClients) return;

    final token = ++_animationToken;
    _programmaticScroll = true;
    final duration = isJump
        ? Duration(milliseconds: 280 + 45 * distance.clamp(1, 9))
        : const Duration(milliseconds: 380);

    _controller
        .animateToPage(index, duration: duration, curve: Curves.easeOutCubic)
        .whenComplete(() {
      if (mounted && token == _animationToken) _programmaticScroll = false;
    });
  }

  void _onPageChanged(int index) {
    // Durante una animación iniciada por las flechas, PageView informa de
    // páginas intermedias: se ignoran para no perder el contador.
    if (_programmaticScroll) return;
    if (index != _selected) {
      _tracker.reset();
      setState(() => _selected = index);
    }
  }

  bool _onScrollNotification(ScrollNotification notification) {
    if (notification is ScrollStartNotification && notification.dragDetails != null) {
      // El usuario arrastra con el dedo: interrumpe cualquier animación de
      // las flechas y cuenta como selección manual.
      _programmaticScroll = false;
      _animationToken++;
      _tracker.reset();
      _pauseAutoplay();
    }
    return false;
  }

  void _showJumpBadge(String text) {
    _jumpBadgeTimer?.cancel();
    setState(() => _jumpBadgeText = text);
    _jumpBadgeTimer = Timer(const Duration(milliseconds: 1100), () {
      if (mounted) setState(() => _jumpBadgeText = null);
    });
  }

  void _openMovie(Movie movie) {
    _pauseAutoplay();
    if (widget.onMovieTap != null) {
      widget.onMovieTap!(movie);
    } else {
      context.push('/home/0/movie/${movie.id}');
    }
  }

  // --------------------------------------------------------------- build

  @override
  Widget build(BuildContext context) {
    _routeIsCurrent = ModalRoute.of(context)?.isCurrent ?? true;
    if (widget.movies.isEmpty) return const SizedBox.shrink();

    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final selectedMovie = widget.movies[_selected.clamp(0, _lastIndex)];

    return LayoutBuilder(
      builder: (context, constraints) {
        final width = constraints.maxWidth;
        final posterWidth = width * _viewportFraction - 20;
        final posterHeight = (posterWidth * 1.5).clamp(240.0, 440.0);

        return Column(
          children: [
            // Encabezado: título de sección + posición actual
            Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 16, 4),
              child: Row(
                children: [
                  Container(
                    width: 4,
                    height: 20,
                    decoration: BoxDecoration(
                      gradient: AppColors.brandGradient,
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(child: Text(l10n.featuredTitle, style: textTheme.titleLarge)),
                  Text(
                    l10n.carouselPosition(
                      HumanFormats.integer(_selected + 1, l10n.localeName),
                      HumanFormats.integer(widget.movies.length, l10n.localeName),
                    ),
                    style: textTheme.labelLarge?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: posterHeight + 28,
              child: Stack(
                children: [
                  // Fondo ambiental con el backdrop de la película actual
                  Positioned.fill(child: _AmbientBackdrop(movie: selectedMovie)),

                  // Pósters
                  Positioned.fill(
                    child: NotificationListener<ScrollNotification>(
                      onNotification: _onScrollNotification,
                      child: PageView.builder(
                        key: const Key('movies-slideshow-pageview'),
                        controller: _controller,
                        itemCount: widget.movies.length,
                        onPageChanged: _onPageChanged,
                        physics: const BouncingScrollPhysics(parent: PageScrollPhysics()),
                        itemBuilder: (context, index) => AnimatedBuilder(
                          animation: _controller,
                          builder: (context, child) {
                            double page = _selected.toDouble();
                            if (_controller.hasClients && _controller.position.haveDimensions) {
                              page = _controller.page ?? page;
                            }
                            final distance = (page - index).abs().clamp(0.0, 1.0);
                            return Transform.scale(
                              scale: 1 - .14 * distance,
                              child: Opacity(opacity: 1 - .45 * distance, child: child),
                            );
                          },
                          child: _PosterCard(
                            movie: widget.movies[index],
                            isSelected: index == _selected,
                            onTap: () => index == _selected
                                ? _openMovie(widget.movies[index])
                                : _selectDirectly(index),
                          ),
                        ),
                      ),
                    ),
                  ),

                  // Flechas (start = anterior, end = siguiente; se invierten en RTL)
                  PositionedDirectional(
                    start: 6,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _ArrowButton(
                        key: const Key('carousel-previous'),
                        icon: Icons.chevron_left_rounded,
                        tooltip: l10n.carouselPrevious,
                        enabled: _selected > 0,
                        onPressed: () => handleArrow(CarouselDirection.previous),
                      ),
                    ),
                  ),
                  PositionedDirectional(
                    end: 6,
                    top: 0,
                    bottom: 0,
                    child: Center(
                      child: _ArrowButton(
                        key: const Key('carousel-next'),
                        icon: Icons.chevron_right_rounded,
                        tooltip: l10n.carouselNext,
                        enabled: _selected < _lastIndex,
                        onPressed: () => handleArrow(CarouselDirection.next),
                      ),
                    ),
                  ),

                  // Aviso breve tras un salto por triple pulsación
                  Positioned(
                    left: 0,
                    right: 0,
                    bottom: 18,
                    child: IgnorePointer(
                      child: Center(
                        child: AnimatedOpacity(
                          opacity: _jumpBadgeText == null ? 0 : 1,
                          duration: const Duration(milliseconds: 200),
                          child: _JumpBadge(text: _jumpBadgeText ?? ''),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            // Indicadores de página (también seleccionables)
            _PageDots(
              count: widget.movies.length,
              selected: _selected,
              onSelected: _selectDirectly,
            ),
            const SizedBox(height: 6),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.touch_app_outlined, size: 14, color: AppColors.textSecondary),
                  const SizedBox(width: 6),
                  Flexible(
                    child: Text(
                      l10n.carouselTripleTapHint,
                      textAlign: TextAlign.center,
                      style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            MovieInfoPanel(
              movie: selectedMovie,
              onViewDetails: () => _openMovie(selectedMovie),
            ),
            const SizedBox(height: 8),
          ],
        );
      },
    );
  }
}

class _PosterCard extends StatelessWidget {
  final Movie movie;
  final bool isSelected;
  final VoidCallback onTap;

  const _PosterCard({required this.movie, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(10, 10, 10, 18),
      child: PressableScale(
        onTap: onTap,
        semanticLabel: movie.title,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(22),
            gradient: isSelected ? AppColors.brandGradient : null,
            boxShadow: [
              BoxShadow(
                color: isSelected ? AppColors.violet.withValues(alpha: .4) : Colors.black54,
                blurRadius: isSelected ? 24 : 12,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          padding: EdgeInsets.all(isSelected ? 2 : 0),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(isSelected ? 20 : 22),
            child: AspectRatio(
              aspectRatio: 2 / 3,
              child: Image.network(
                movie.posterPath,
                fit: BoxFit.cover,
                gaplessPlayback: true,
                loadingBuilder: (context, child, progress) {
                  if (progress == null) return child;
                  return const ColoredBox(
                    color: AppColors.surfaceHigh,
                    child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
                  );
                },
                errorBuilder: (context, error, stackTrace) => const ColoredBox(
                  color: AppColors.surfaceHigh,
                  child: Center(
                    child: Icon(Icons.broken_image_outlined, size: 40, color: AppColors.textSecondary),
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Botón grande de flecha. Reclama los arrastres horizontales que empiezan
/// sobre él para que el PageView no robe la pulsación, y no usa
/// `onDoubleTap`, de modo que cada toque se procesa al instante (necesario
/// para la triple pulsación).
class _ArrowButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final bool enabled;
  final VoidCallback onPressed;

  const _ArrowButton({
    super.key,
    required this.icon,
    required this.tooltip,
    required this.enabled,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return RawGestureDetector(
      behavior: HitTestBehavior.opaque,
      gestures: {
        HorizontalDragGestureRecognizer:
            GestureRecognizerFactoryWithHandlers<HorizontalDragGestureRecognizer>(
          HorizontalDragGestureRecognizer.new,
          (recognizer) => recognizer.onStart = (_) {},
        ),
      },
      child: AnimatedOpacity(
        opacity: enabled ? 1 : .35,
        duration: const Duration(milliseconds: 200),
        child: Material(
          color: Colors.black.withValues(alpha: .55),
          shape: const CircleBorder(side: BorderSide(color: Colors.white24)),
          clipBehavior: Clip.antiAlias,
          child: IconButton(
            tooltip: tooltip,
            iconSize: 34,
            constraints: const BoxConstraints.tightFor(width: 56, height: 56),
            color: Colors.white,
            disabledColor: Colors.white,
            onPressed: enabled ? onPressed : null,
            icon: Icon(icon),
          ),
        ),
      ),
    );
  }
}

class _AmbientBackdrop extends StatelessWidget {
  final Movie movie;
  const _AmbientBackdrop({required this.movie});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        fit: StackFit.expand,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 600),
            child: ImageFiltered(
              key: ValueKey(movie.id),
              imageFilter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
              child: Opacity(
                opacity: .45,
                child: Image.network(
                  movie.backdropPath,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) => const SizedBox.shrink(),
                ),
              ),
            ),
          ),
          const DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [AppColors.background, Colors.transparent, AppColors.background],
                stops: [0, .45, 1],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _PageDots extends StatelessWidget {
  final int count;
  final int selected;
  final ValueChanged<int> onSelected;

  const _PageDots({required this.count, required this.selected, required this.onSelected});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(count, (index) {
        final active = index == selected;
        return GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () => onSelected(index),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 3, vertical: 8),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              curve: Curves.easeOutCubic,
              width: active ? 22 : 7,
              height: 7,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(4),
                gradient: active ? AppColors.brandGradient : null,
                color: active ? null : AppColors.outline,
              ),
            ),
          ),
        );
      }),
    );
  }
}

class _JumpBadge extends StatelessWidget {
  final String text;
  const _JumpBadge({required this.text});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(20),
        boxShadow: const [BoxShadow(color: Colors.black54, blurRadius: 12)],
      ),
      child: Text(
        text,
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
      ),
    );
  }
}
