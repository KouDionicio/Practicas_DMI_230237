import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/config/helpers/l10n_helpers.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';

/// Apartado de Series: misma estructura que Inicio (películas), con un
/// carrusel destacado y cuatro listas horizontales con scroll infinito.
class SeriesView extends ConsumerWidget {
  const SeriesView({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;

    // Se repite sola al cambiar de país (nuevo idioma y zona horaria).
    final initialLoad = ref.watch(initialSeriesLoadProvider);

    final slideshowSeries = ref.watch(seriesSlideshowProvider);
    final airingToday = ref.watch(airingTodaySeriesProvider);
    final onTheAir = ref.watch(onTheAirSeriesProvider);
    final popular = ref.watch(popularSeriesProvider);
    final topRated = ref.watch(topRatedSeriesProvider);

    final hasContent = airingToday.isNotEmpty || onTheAir.isNotEmpty ||
        popular.isNotEmpty || topRated.isNotEmpty;

    Widget body;
    if (initialLoad.isLoading && !hasContent) {
      body = SliverFillRemaining(
        hasScrollBody: false,
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircularProgressIndicator(strokeWidth: 2),
              const SizedBox(height: 12),
              Text(l10n.loaderLoading),
            ],
          ),
        ),
      );
    } else if (initialLoad.hasError && !hasContent) {
      body = SliverFillRemaining(
        hasScrollBody: false,
        child: StateMessageView(
          icon: Icons.cloud_off_rounded,
          title: l10n.errorLoadSeries,
          message: l10n.describeError(initialLoad.error),
          actionLabel: l10n.retry,
          isError: true,
          onAction: () => ref.invalidate(initialSeriesLoadProvider),
        ),
      );
    } else {
      body = SliverList(delegate: SliverChildListDelegate([

        SeriesSlideshow(series: slideshowSeries),

        SeriesHorizontalListview(
          series: airingToday,
          title: l10n.seriesAiringTodayTitle,
          loadNextPage: () => ref.read(airingTodaySeriesProvider.notifier).loadNextPage(),
        ),

        SeriesHorizontalListview(
          series: onTheAir,
          title: l10n.seriesOnTheAirTitle,
          subTitle: l10n.seriesOnTheAirSubtitle,
          loadNextPage: () => ref.read(onTheAirSeriesProvider.notifier).loadNextPage(),
        ),

        SeriesHorizontalListview(
          series: popular,
          title: l10n.seriesPopularTitle,
          loadNextPage: () => ref.read(popularSeriesProvider.notifier).loadNextPage(),
        ),

        SeriesHorizontalListview(
          series: topRated,
          title: l10n.seriesTopRatedTitle,
          subTitle: l10n.topRatedSubtitle,
          loadNextPage: () => ref.read(topRatedSeriesProvider.notifier).loadNextPage(),
        ),

        const SizedBox(height: 10),

      ]));
    }

    return CustomScrollView(
      slivers: [
        SliverAppBar(
          floating: true,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          // Misma barra que Inicio (menú, logotipo y título), sin el buscador,
          // que es exclusivo de películas.
          title: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                const DrawerMenuButton(),
                const AppLogo(size: 30),
                const SizedBox(width: 8),
                Text(l10n.navSeries, style: Theme.of(context).textTheme.titleMedium),
              ],
            ),
          ),
        ),
        body,
      ],
    );
  }
}
