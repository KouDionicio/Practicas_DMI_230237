import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemapedia/config/helpers/l10n_helpers.dart';
import 'package:cinemapedia/presentation/widgets/shared/side_menu.dart';
import 'package:cinemapedia/presentation/widgets/shared/state_message_view.dart';


class FavoritesView extends StatelessWidget {
  const FavoritesView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        leading: const DrawerMenuButton(),
        title: Text(l10n.navFavorites),
      ),
      body: StateMessageView(
        icon: Icons.favorite_outline_rounded,
        title: l10n.favoritesEmptyTitle,
        message: l10n.favoritesEmptyMessage,
        actionLabel: l10n.goHome,
        onAction: () => context.go('/home/0'),
      ),
    );
  }
}
