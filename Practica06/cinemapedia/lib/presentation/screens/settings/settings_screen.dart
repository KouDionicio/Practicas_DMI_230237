import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:cinemapedia/config/constants/app_regions.dart';
import 'package:cinemapedia/config/helpers/l10n_helpers.dart';
import 'package:cinemapedia/config/theme/app_theme.dart';
import 'package:cinemapedia/presentation/providers/settings/app_region_provider.dart';
import 'package:cinemapedia/presentation/widgets/settings/region_card.dart';

/// Configuración: selección visual del país, que define idioma de la
/// interfaz, parámetros de TMDB y sistema de clasificación.
class SettingsScreen extends ConsumerWidget {
  static const name = 'settings-screen';

  const SettingsScreen({super.key});

  Future<void> _select(BuildContext context, WidgetRef ref, AppRegion region) async {
    if (ref.read(appRegionProvider) == region) return;
    HapticFeedback.selectionClick();
    final messenger = ScaffoldMessenger.of(context);
    await ref.read(appRegionProvider.notifier).select(region);

    messenger
      ..hideCurrentSnackBar()
      ..showSnackBar(SnackBar(
        duration: const Duration(seconds: 2),
        // El Builder lee las traducciones ya en el idioma nuevo.
        content: Builder(
          builder: (context) => Row(
            children: [
              Text(region.flag, style: const TextStyle(fontSize: 18)),
              const SizedBox(width: 10),
              Expanded(
                child: Text(context.l10n.settingsRegionChanged(region.localizedName(context.l10n))),
              ),
            ],
          ),
        ),
      ));
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final textTheme = Theme.of(context).textTheme;
    final selected = ref.watch(appRegionProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.navSettings),
      ),
      body: SafeArea(
        top: false,
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 32),
              children: [
                // Título principal + descripción
                Text(l10n.settingsHeadline, style: textTheme.headlineSmall),
                const SizedBox(height: 8),
                Text(
                  l10n.settingsDescription,
                  style: textTheme.bodyMedium?.copyWith(color: AppColors.textSecondary),
                ),
                const SizedBox(height: 28),

                // Apartado REGIÓN E IDIOMA
                Row(
                  children: [
                    Container(
                      width: 18,
                      height: 3,
                      decoration: BoxDecoration(
                        gradient: AppColors.brandGradient,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      l10n.settingsRegionSection,
                      style: textTheme.labelLarge?.copyWith(
                        color: AppColors.violetLight,
                        letterSpacing: 1.4,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 14),

                // Cuadrícula de tarjetas (2 columnas; 1 en pantallas muy estrechas)
                LayoutBuilder(builder: (context, constraints) {
                  final columns = constraints.maxWidth < 300 ? 1 : 2;
                  const gap = 12.0;
                  final regions = AppRegions.all;
                  final rows = <Widget>[];
                  for (var i = 0; i < regions.length; i += columns) {
                    final rowItems = regions.skip(i).take(columns).toList();
                    rows.add(Padding(
                      padding: const EdgeInsets.only(bottom: gap),
                      // IntrinsicHeight iguala la altura de las dos tarjetas
                      // aunque el usuario use un tamaño de letra grande.
                      child: IntrinsicHeight(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            for (var j = 0; j < columns; j++) ...[
                              if (j > 0) const SizedBox(width: gap),
                              Expanded(
                                child: j < rowItems.length
                                    ? RegionCard(
                                        key: Key('region-card-${rowItems[j].code}'),
                                        region: rowItems[j],
                                        selected: rowItems[j] == selected,
                                        onTap: () => _select(context, ref, rowItems[j]),
                                      )
                                    : const SizedBox.shrink(),
                              ),
                            ],
                          ],
                        ),
                      ),
                    ));
                  }
                  return Column(children: rows);
                }),

                if (selected.ratingSystem != null) ...[
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      const Icon(Icons.verified_user_outlined, size: 16, color: AppColors.textSecondary),
                      const SizedBox(width: 6),
                      Text(
                        l10n.settingsRatingSystem(selected.ratingSystem!),
                        style: textTheme.bodySmall?.copyWith(color: AppColors.textSecondary),
                      ),
                    ],
                  ),
                ],
                const SizedBox(height: 18),

                // Nota informativa
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.violet.withValues(alpha: .1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.violet.withValues(alpha: .3)),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.info_outline_rounded, color: AppColors.violetLight),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          l10n.settingsInfoNote,
                          style: textTheme.bodyMedium?.copyWith(color: AppColors.textPrimary),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
