import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:cinemapedia/config/helpers/l10n_helpers.dart';
import 'package:cinemapedia/presentation/widgets/shared/side_menu.dart';
import 'package:cinemapedia/presentation/widgets/shared/state_message_view.dart';

/// Pestaña Categorías (antes un `SizedBox()` vacío): de momento muestra un
/// estado vacío traducido, coherente con el resto de la app.
class CategoriesView extends StatelessWidget {
  const CategoriesView({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;

    return Scaffold(
      appBar: AppBar(
        leading: const DrawerMenuButton(),
        title: Text(l10n.navCategories),
      ),
      body: StateMessageView(
        icon: Icons.category_outlined,
        title: l10n.categoriesEmptyTitle,
        message: l10n.categoriesEmptyMessage,
        actionLabel: l10n.goHome,
        onAction: () => context.go('/home/0'),
      ),
    );
  }
}
