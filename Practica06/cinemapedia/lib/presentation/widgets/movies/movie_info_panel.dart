import 'package:flutter/material.dart';

import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/config/helpers/l10n_helpers.dart';
import 'package:cinemapedia/config/theme/app_theme.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/widgets/movies/certification_badge.dart';
import 'package:cinemapedia/presentation/widgets/movies/star_rating.dart';

/// Contenedor con la información de la película seleccionada en el carrusel.
///
/// Se reconstruye cada vez que cambia [movie] y anima la transición, así los
/// datos siempre corresponden al póster visible.
class MovieInfoPanel extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onViewDetails;

  const MovieInfoPanel({super.key, required this.movie, this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(22),
        gradient: LinearGradient(
          begin: AlignmentDirectional.topStart,
          end: AlignmentDirectional.bottomEnd,
          colors: [
            AppColors.violet.withValues(alpha: .35),
            AppColors.crimson.withValues(alpha: .25),
          ],
        ),
      ),
      padding: const EdgeInsets.all(1.2),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(21),
        ),
        child: AnimatedSize(
          duration: const Duration(milliseconds: 250),
          curve: Curves.easeOutCubic,
          alignment: AlignmentDirectional.topStart,
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 320),
            switchInCurve: Curves.easeOutCubic,
            switchOutCurve: Curves.easeIn,
            layoutBuilder: (current, previous) => Stack(
              alignment: AlignmentDirectional.topStart,
              children: [...previous, if (current != null) current],
            ),
            transitionBuilder: (child, animation) => FadeTransition(
              opacity: animation,
              child: SlideTransition(
                position: Tween(begin: const Offset(0, .06), end: Offset.zero).animate(animation),
                child: child,
              ),
            ),
            child: _PanelContent(
              key: ValueKey(movie.id),
              movie: movie,
              onViewDetails: onViewDetails,
            ),
          ),
        ),
      ),
    );
  }
}

class _PanelContent extends StatelessWidget {
  final Movie movie;
  final VoidCallback? onViewDetails;

  const _PanelContent({super.key, required this.movie, this.onViewDetails});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final locale = l10n.localeName;
    final labelStyle = textTheme.labelSmall?.copyWith(
      color: AppColors.textSecondary,
      letterSpacing: .6,
      fontWeight: FontWeight.w600,
    );
    final releaseDate = movie.releaseDate;

    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(18, 16, 18, 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Clasificación + calificación
          Wrap(
            spacing: 10,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              CertificationBadge(movieId: movie.id),
              StarRating(voteAverage: movie.voteAverage),
              Text(
                l10n.votesCount(HumanFormats.number(movie.voteCount.toDouble(), 0, locale)),
                style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
          const SizedBox(height: 14),

          // Título localizado
          Text(l10n.localizedTitleLabel.toUpperCase(), style: labelStyle),
          const SizedBox(height: 2),
          Text(
            movie.title,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.titleLarge?.copyWith(height: 1.2),
          ),
          const SizedBox(height: 10),

          // Título original
          Text(
            movie.originalLanguage.isEmpty
                ? l10n.originalTitleLabel.toUpperCase()
                : '${l10n.originalTitleLabel.toUpperCase()} · ${movie.originalLanguage.toUpperCase()}',
            style: labelStyle,
          ),
          const SizedBox(height: 2),
          Text(
            movie.originalTitle.isEmpty ? movie.title : movie.originalTitle,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic, color: AppColors.textPrimary),
          ),
          const SizedBox(height: 12),

          // Estreno
          Row(
            children: [
              const Icon(Icons.event_rounded, size: 16, color: AppColors.violetLight),
              const SizedBox(width: 6),
              Flexible(
                child: Text(
                  '${l10n.releaseDateLabel}: ${releaseDate == null ? l10n.releaseDateUnknown : HumanFormats.date(releaseDate, locale)}',
                  style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),

          // Sinopsis breve
          Text(
            movie.overview.isEmpty ? l10n.overviewUnavailable : movie.overview,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
          ),

          if (onViewDetails != null)
            Align(
              alignment: AlignmentDirectional.centerEnd,
              child: TextButton(
                onPressed: onViewDetails,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(l10n.viewDetails),
                    const SizedBox(width: 6),
                    // arrow_forward se invierte automáticamente en RTL.
                    const Icon(Icons.arrow_forward_rounded, size: 18),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
