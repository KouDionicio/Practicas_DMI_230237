import 'package:flutter/material.dart';
import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/config/helpers/l10n_helpers.dart';
import 'package:cinemapedia/config/theme/app_theme.dart';

/// Calificación de TMDB (0–10) representada con cinco estrellas y medias
/// estrellas, más el valor numérico en el formato del idioma actual.
class StarRating extends StatelessWidget {
  final double voteAverage;
  final double size;
  final bool showValue;

  const StarRating({
    super.key,
    required this.voteAverage,
    this.size = 18,
    this.showValue = true,
  });

  /// Devuelve cuántas estrellas llenas y si hay media estrella.
  static ({int full, bool half}) starsFor(double voteAverage) {
    final outOfFive = (voteAverage.clamp(0, 10) / 2);
    final rounded = (outOfFive * 2).round() / 2; // múltiplos de 0.5
    return (full: rounded.floor(), half: rounded - rounded.floor() >= .5);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final stars = starsFor(voteAverage);
    final value = HumanFormats.decimal(voteAverage, l10n.localeName);

    return Semantics(
      label: l10n.ratingSemantics(value),
      excludeSemantics: true,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          for (var i = 0; i < 5; i++)
            Icon(
              i < stars.full
                  ? Icons.star_rounded
                  : (i == stars.full && stars.half)
                      ? Icons.star_half_rounded
                      : Icons.star_outline_rounded,
              size: size,
              color: AppColors.star,
            ),
          if (showValue) ...[
            SizedBox(width: size * .3),
            Text(
              value,
              style: TextStyle(
                color: AppColors.star,
                fontWeight: FontWeight.w700,
                fontSize: size * .8,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
