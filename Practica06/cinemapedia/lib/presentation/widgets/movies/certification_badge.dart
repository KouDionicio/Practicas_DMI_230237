import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/config/helpers/l10n_helpers.dart';
import 'package:cinemapedia/config/theme/app_theme.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';

/// Clasificación por edad de [movieId] en el país seleccionado.
///
/// Muestra la clasificación tal como la publica TMDB para ese país (sin
/// convertirla ni tomarla de otro país). Si no existe, lo indica con un texto
/// traducido; si falla la petición, permite reintentar.
class CertificationBadge extends ConsumerWidget {
  final int movieId;

  const CertificationBadge({super.key, required this.movieId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final region = ref.watch(appRegionProvider);
    final certification = ref.watch(movieCertificationProvider(movieId));

    return certification.when(
      skipLoadingOnRefresh: false,
      loading: () => _Pill(
        semanticLabel: l10n.certificationLoading,
        muted: true,
        child: const SizedBox(
          width: 14,
          height: 14,
          child: CircularProgressIndicator(strokeWidth: 2),
        ),
      ),
      error: (error, _) => Tooltip(
        message: l10n.certificationError,
        child: _Pill(
          muted: true,
          semanticLabel: l10n.certificationError,
          onTap: () => ref.invalidate(movieCertificationProvider(movieId)),
          child: Row(mainAxisSize: MainAxisSize.min, children: [
            const Icon(Icons.refresh_rounded, size: 15, color: AppColors.textSecondary),
            const SizedBox(width: 4),
            Text(region.code, style: const TextStyle(color: AppColors.textSecondary)),
          ]),
        ),
      ),
      data: (value) {
        if (!value.isAvailable) {
          return _Pill(
            muted: true,
            semanticLabel: l10n.certificationUnavailable,
            child: Text(
              l10n.certificationUnavailable,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 12),
            ),
          );
        }
        final system = region.ratingSystem;
        return _Pill(
          semanticLabel: '${l10n.certificationLabel}: ${value.rating} (${region.localizedName(l10n)})',
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                value.rating!,
                style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 13, color: Colors.white),
              ),
              const SizedBox(width: 6),
              Text(
                system == null ? region.code : '${region.code} · $system',
                style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
              ),
            ],
          ),
        );
      },
    );
  }
}

class _Pill extends StatelessWidget {
  final Widget child;
  final bool muted;
  final VoidCallback? onTap;
  final String semanticLabel;

  const _Pill({required this.child, required this.semanticLabel, this.muted = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    final pill = AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: muted ? AppColors.surfaceHighest : AppColors.crimsonDeep.withValues(alpha: .55),
        border: Border.all(
          color: muted ? AppColors.outline : AppColors.crimson.withValues(alpha: .8),
        ),
      ),
      child: child,
    );

    return Semantics(
      label: semanticLabel,
      button: onTap != null,
      excludeSemantics: true,
      child: onTap == null
          ? pill
          : InkWell(borderRadius: BorderRadius.circular(8), onTap: onTap, child: pill),
    );
  }
}
