import 'package:flutter/material.dart';

import 'package:cinemapedia/config/constants/app_regions.dart';
import 'package:cinemapedia/config/helpers/l10n_helpers.dart';
import 'package:cinemapedia/config/theme/app_theme.dart';

/// Tarjeta seleccionable de un país: bandera, código regional destacado,
/// idioma (escrito en su propio idioma) y nombre del país traducido.
class RegionCard extends StatelessWidget {
  final AppRegion region;
  final bool selected;
  final VoidCallback onTap;

  const RegionCard({
    super.key,
    required this.region,
    required this.selected,
    required this.onTap,
  });

  static const _duration = Duration(milliseconds: 260);

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final radius = BorderRadius.circular(20);

    return Semantics(
      button: true,
      selected: selected,
      inMutuallyExclusiveGroup: true,
      label: '${region.localizedName(l10n)}, ${region.nativeLanguageName}'
          '${selected ? ', ${l10n.settingsSelected}' : ''}',
      excludeSemantics: true,
      child: AnimatedContainer(
        duration: _duration,
        curve: Curves.easeOutCubic,
        padding: EdgeInsets.all(selected ? 2 : 1),
        decoration: BoxDecoration(
          borderRadius: radius,
          gradient: selected ? AppColors.brandGradient : null,
          color: selected ? null : AppColors.outline,
          boxShadow: selected
              ? [BoxShadow(color: AppColors.violet.withValues(alpha: .35), blurRadius: 18, offset: const Offset(0, 6))]
              : null,
        ),
        child: Material(
          color: selected ? const Color(0xFF1B1530) : AppColors.surfaceHigh,
          borderRadius: BorderRadius.circular(selected ? 18 : 19),
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsetsDirectional.fromSTEB(14, 14, 10, 14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(region.flag, style: const TextStyle(fontSize: 34, height: 1.1)),
                      const Spacer(),
                      _CheckIndicator(selected: selected),
                    ],
                  ),
                  const SizedBox(height: 10),
                  AnimatedDefaultTextStyle(
                    duration: _duration,
                    style: (textTheme.headlineSmall ?? const TextStyle()).copyWith(
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.5,
                      color: selected ? Colors.white : AppColors.textPrimary,
                    ),
                    child: Text(region.code),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    region.nativeLanguageName,
                    style: textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0,
                      color: selected ? AppColors.violetLight : AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    region.localizedName(l10n),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _CheckIndicator extends StatelessWidget {
  final bool selected;
  const _CheckIndicator({required this.selected});

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 220),
      transitionBuilder: (child, animation) => ScaleTransition(scale: animation, child: child),
      child: selected
          ? Container(
              key: const ValueKey('selected'),
              width: 26,
              height: 26,
              decoration: const BoxDecoration(shape: BoxShape.circle, gradient: AppColors.brandGradient),
              child: const Icon(Icons.check_rounded, size: 18, color: Colors.white),
            )
          : Container(
              key: const ValueKey('unselected'),
              width: 24,
              height: 24,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: AppColors.outline, width: 2),
              ),
            ),
    );
  }
}
