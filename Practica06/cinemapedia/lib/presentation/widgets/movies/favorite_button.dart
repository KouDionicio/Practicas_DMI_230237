import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/config/helpers/l10n_helpers.dart';
import 'package:cinemapedia/config/theme/app_theme.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/storage/favorites_provider.dart';

/// Corazón para agregar o quitar una película de favoritos.
///
/// Muestra un aviso traducido con la opción "Deshacer".
/// [onImage] añade un fondo oscuro para que se vea sobre un póster.
class FavoriteButton extends ConsumerWidget {
  final Movie movie;
  final bool onImage;

  const FavoriteButton({super.key, required this.movie, this.onImage = false});

  Future<void> _toggle(BuildContext context, WidgetRef ref) async {
    final l10n = context.l10n;
    final messenger = ScaffoldMessenger.of(context);
    final notifier = ref.read(favoriteMoviesProvider.notifier);

    HapticFeedback.lightImpact();
    final isNowFavorite = await notifier.toggle(movie);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        duration: const Duration(seconds: 3),
        content: Text(isNowFavorite
            ? l10n.favoriteAdded(movie.title)
            : l10n.favoriteRemoved(movie.title)),
        action: SnackBarAction(
          label: l10n.undo,
          onPressed: () => notifier.toggle(movie),
        ),
      ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final isFavorite = ref.watch(isFavoriteProvider(movie.id));

    final button = IconButton(
      key: Key('favorite-button-${movie.id}'),
      tooltip: isFavorite ? l10n.favoriteRemove : l10n.favoriteAdd,
      onPressed: () => _toggle(context, ref),
      icon: AnimatedSwitcher(
        duration: const Duration(milliseconds: 250),
        transitionBuilder: (child, animation) => ScaleTransition(
          scale: CurvedAnimation(parent: animation, curve: Curves.easeOutBack),
          child: child,
        ),
        child: Icon(
          isFavorite ? Icons.favorite_rounded : Icons.favorite_border_rounded,
          key: ValueKey(isFavorite),
          color: isFavorite ? AppColors.crimson : (onImage ? Colors.white : AppColors.textPrimary),
        ),
      ),
    );

    if (!onImage) return button;

    return Padding(
      padding: const EdgeInsets.all(6),
      child: Material(
        color: Colors.black.withValues(alpha: .45),
        shape: const CircleBorder(),
        child: button,
      ),
    );
  }
}
