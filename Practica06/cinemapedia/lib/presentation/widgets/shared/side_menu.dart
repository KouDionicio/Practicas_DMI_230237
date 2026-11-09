import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import 'package:cinemapedia/config/helpers/l10n_helpers.dart';
import 'package:cinemapedia/config/theme/app_theme.dart';
import 'package:cinemapedia/presentation/providers/settings/app_region_provider.dart';
import 'package:cinemapedia/presentation/widgets/shared/app_logo.dart';

/// Busca el Scaffold que tiene el menú lateral (el de HomeScreen), aunque el
/// widget esté dentro de otro Scaffold anidado, como el de Favoritos.
ScaffoldState? findDrawerScaffold(BuildContext context) {
  var scaffold = Scaffold.maybeOf(context);
  while (scaffold != null && !scaffold.hasDrawer) {
    scaffold = Scaffold.maybeOf(scaffold.context);
  }
  return scaffold;
}

/// Botón hamburguesa reutilizable. Alterna el menú: lo abre, o lo cierra si
/// ya está abierto.
class DrawerMenuButton extends StatelessWidget {
  const DrawerMenuButton({super.key});

  @override
  Widget build(BuildContext context) {
    return IconButton(
      key: const Key('drawer-menu-button'),
      tooltip: context.l10n.menuOpenTooltip,
      icon: const Icon(Icons.menu_rounded),
      onPressed: () {
        final scaffold = findDrawerScaffold(context);
        if (scaffold == null) return;
        scaffold.isDrawerOpen ? scaffold.closeDrawer() : scaffold.openDrawer();
      },
    );
  }
}

/// Menú lateral de Cinemapedia.
///
/// Se abre con el botón hamburguesa o deslizando desde el borde (el
/// izquierdo, o el derecho en árabe) y se cierra con el botón del encabezado,
/// deslizando, tocando fuera o eligiendo una opción.
class SideMenu extends ConsumerWidget {
  final int currentIndex;

  const SideMenu({super.key, required this.currentIndex});

  static const _settingsIndex = 3;

  void _onDestinationSelected(BuildContext context, int index) {
    Scaffold.of(context).closeDrawer();
    if (index == _settingsIndex) {
      context.push('/settings');
    } else if (index != currentIndex) {
      context.go('/home/$index');
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final region = ref.watch(appRegionProvider);

    return NavigationDrawer(
      key: const Key('side-menu'),
      selectedIndex: currentIndex,
      onDestinationSelected: (index) => _onDestinationSelected(context, index),
      children: [
        // Encabezado con identidad de marca
        Container(
          margin: const EdgeInsets.fromLTRB(12, 12, 12, 8),
          padding: const EdgeInsetsDirectional.fromSTEB(16, 8, 8, 18),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(24),
            gradient: LinearGradient(
              begin: AlignmentDirectional.topStart,
              end: AlignmentDirectional.bottomEnd,
              colors: [
                AppColors.violet.withValues(alpha: .35),
                AppColors.magenta.withValues(alpha: .18),
                AppColors.crimson.withValues(alpha: .22),
              ],
            ),
            border: Border.all(color: Colors.white10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Align(
                alignment: AlignmentDirectional.centerEnd,
                child: IconButton(
                  key: const Key('drawer-close-button'),
                  tooltip: l10n.menuCloseTooltip,
                  icon: const Icon(Icons.menu_open_rounded),
                  onPressed: () => Scaffold.of(context).closeDrawer(),
                ),
              ),
              const AppLogo(size: 68, glow: true),
              const SizedBox(height: 14),
              Text('Cinemapedia', style: textTheme.headlineSmall),
              const SizedBox(height: 2),
              Text(
                l10n.appTagline,
                style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
              ),
            ],
          ),
        ),

        _SectionLabel(l10n.menuSectionExplore),
        NavigationDrawerDestination(
          icon: const Icon(Icons.home_outlined),
          selectedIcon: const Icon(Icons.home_rounded),
          label: Text(l10n.navHome),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.category_outlined),
          selectedIcon: const Icon(Icons.category_rounded),
          label: Text(l10n.navCategories),
        ),
        NavigationDrawerDestination(
          icon: const Icon(Icons.favorite_outline_rounded),
          selectedIcon: const Icon(Icons.favorite_rounded),
          label: Text(l10n.navFavorites),
        ),

        const Padding(
          padding: EdgeInsets.symmetric(horizontal: 28, vertical: 10),
          child: Divider(),
        ),
        _SectionLabel(l10n.menuSectionPreferences),
        NavigationDrawerDestination(
          icon: const Icon(Icons.settings_outlined),
          selectedIcon: const Icon(Icons.settings_rounded),
          label: Text(l10n.navSettings),
        ),

        // Región actual (acceso rápido a configuración)
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 18, 16, 16),
          child: Material(
            color: AppColors.surfaceHigh,
            borderRadius: BorderRadius.circular(16),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => _onDestinationSelected(context, _settingsIndex),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    Text(region.flag, style: const TextStyle(fontSize: 26)),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            l10n.menuCurrentRegion,
                            style: textTheme.labelSmall?.copyWith(color: AppColors.textSecondary),
                          ),
                          Text(
                            '${region.localizedName(l10n)} · ${region.nativeLanguageName}',
                            style: textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsetsDirectional.fromSTEB(28, 12, 16, 8),
      child: Text(
        text.toUpperCase(),
        style: Theme.of(context).textTheme.labelSmall?.copyWith(
              color: AppColors.textSecondary,
              letterSpacing: 1.2,
              fontWeight: FontWeight.w700,
            ),
      ),
    );
  }
}
