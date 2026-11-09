import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/config/helpers/l10n_helpers.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';


class HomeView extends ConsumerWidget {
  const HomeView({ super.key });

  @override
  Widget build(BuildContext context, WidgetRef ref) {

    final l10n = context.l10n;

    // La carga inicial se lanza en la pantalla de carga y se repite sola al
    // cambiar de país (ver initialMoviesLoadProvider).
    final initialLoad = ref.watch(initialMoviesLoadProvider);
    final initialLoading = ref.watch(initialLoadingProvider);

    final slideShowMovies = ref.watch( moviesSlideshowProvider );
    final nowPlayingMovies = ref.watch( nowPlayingMoviesProvider );
    final popularMovies = ref.watch( popularMoviesProvider );
    final topRatedMovies = ref.watch( topRatedMoviesProvider );
    final upcomingMovies = ref.watch( upcomingMoviesProvider );

    final hasContent = nowPlayingMovies.isNotEmpty || popularMovies.isNotEmpty ||
        topRatedMovies.isNotEmpty || upcomingMovies.isNotEmpty;

    Widget body;
    if ( initialLoading && !hasContent ) {
      body = const SliverFillRemaining(hasScrollBody: false, child: FullScreenLoader());
    } else if ( initialLoad.hasError && !hasContent ) {
      body = SliverFillRemaining(
        hasScrollBody: false,
        child: StateMessageView(
          icon: Icons.cloud_off_rounded,
          title: l10n.errorLoadMovies,
          message: l10n.describeError(initialLoad.error),
          actionLabel: l10n.retry,
          isError: true,
          onAction: () => ref.invalidate(initialMoviesLoadProvider),
        ),
      );
    } else {
      body = SliverList(delegate: SliverChildListDelegate([

        MoviesSlideshow(movies: slideShowMovies ),

        MovieHorizontalListview(
          movies: nowPlayingMovies,
          title: l10n.nowPlayingTitle,
          // Antes era el texto fijo "Lunes 20": ahora es la fecha real del día.
          subTitle: HumanFormats.shortDay(DateTime.now(), l10n.localeName),
          loadNextPage: () =>ref.read(nowPlayingMoviesProvider.notifier).loadNextPage()
        ),

        MovieHorizontalListview(
          movies: upcomingMovies,
          title: l10n.upcomingTitle,
          subTitle: l10n.upcomingSubtitle,
          loadNextPage: () =>ref.read(upcomingMoviesProvider.notifier).loadNextPage()
        ),

        MovieHorizontalListview(
          movies: popularMovies,
          title: l10n.popularTitle,
          loadNextPage: () =>ref.read(popularMoviesProvider.notifier).loadNextPage()
        ),

        MovieHorizontalListview(
          movies: topRatedMovies,
          title: l10n.topRatedTitle,
          subTitle: l10n.topRatedSubtitle,
          loadNextPage: () =>ref.read(topRatedMoviesProvider.notifier).loadNextPage()
        ),

        const SizedBox( height: 10 ),

      ]));
    }

    return CustomScrollView(
      slivers: [

        const SliverAppBar(
          floating: true,
          automaticallyImplyLeading: false,
          titleSpacing: 0,
          title: CustomAppbar(),
        ),

        body,

      ]
    );
  }
}
