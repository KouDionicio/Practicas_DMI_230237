import 'package:flutter/material.dart';
import 'package:cinemapedia/config/theme/app_theme.dart';

/// Icono oficial de Cinemapedia (assets/icono).
class AppLogo extends StatelessWidget {
  static const asset = 'assets/icono/icono_marca.png';

  final double size;
  final bool glow;

  const AppLogo({super.key, this.size = 40, this.glow = false});

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(size * .24);
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: radius,
        boxShadow: glow
            ? [
                BoxShadow(
                  color: AppColors.violet.withValues(alpha: .45),
                  blurRadius: size * .45,
                  spreadRadius: size * .02,
                ),
                BoxShadow(
                  color: AppColors.crimson.withValues(alpha: .25),
                  blurRadius: size * .7,
                  offset: Offset(size * .08, size * .12),
                ),
              ]
            : null,
      ),
      child: ClipRRect(
        borderRadius: radius,
        child: Image.asset(
          asset,
          fit: BoxFit.cover,
          filterQuality: FilterQuality.medium,
          semanticLabel: 'Cinemapedia',
          errorBuilder: (context, error, stackTrace) => Icon(
            Icons.movie_filter_rounded,
            size: size * .6,
            color: AppColors.violetLight,
          ),
        ),
      ),
    );
  }
}
