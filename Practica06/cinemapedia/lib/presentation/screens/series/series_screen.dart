import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/config/helpers/l10n_helpers.dart';
import 'package:cinemapedia/config/theme/app_theme.dart';
import 'package:cinemapedia/domain/entities/tv_series.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';

/// Detalle de una serie. Mismo diseño que el detalle de película.
///
/// Los datos dependen de la región: al cambiar de país, los providers se
/// reinician y la serie se vuelve a pedir en el nuevo idioma.
class SeriesScreen extends ConsumerWidget {

  static const name = 'series-screen';

  final String seriesId;

  const SeriesScreen({ super.key, required this.seriesId });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final id = int.tryParse(seriesId) ?? -1;
    final series = ref.watch(seriesInfoProvider(id));

    return series.when(
      skipLoadingOnRefresh: false,
      loading: () => Scaffold(
        appBar: AppBar(),
        body: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
      ),
      error: (error, _) => Scaffold(
        appBar: AppBar(),
        body: StateMessageView(
          icon: Icons.live_tv_outlined,
          title: l10n.errorLoadSerie,
          message: l10n.describeError(error),
          actionLabel: l10n.retry,
          isError: true,
          onAction: () => ref.invalidate(seriesInfoProvider(id)),
        ),
      ),
      data: (series) => Scaffold(
        body: CustomScrollView(
          physics: const ClampingScrollPhysics(),
          slivers: [
            _CustomSliverAppBar(series: series),
            SliverList(delegate: SliverChildBuilderDelegate(
              (context, index) => _SeriesDetails(series: series),
              childCount: 1,
            )),
          ],
        ),
      ),
    );
  }
}


class _SeriesDetails extends StatelessWidget {

  final TvSeries series;

  const _SeriesDetails({ required this.series });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final textStyles = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final locale = l10n.localeName;
    final firstAirDate = series.firstAirDate;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [

        Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // Imagen
              ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Image.network(
                  series.posterPath,
                  width: size.width * 0.3,
                  errorBuilder: (context, error, stackTrace) => SizedBox(
                    width: size.width * 0.3,
                    child: const AspectRatio(aspectRatio: 2 / 3, child: Icon(Icons.broken_image_outlined)),
                  ),
                ),
              ),

              const SizedBox(width: 12),

              // Descripción
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(series.name, style: textStyles.titleLarge),
                    if (series.originalName.isNotEmpty && series.originalName != series.name) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.originalTitleLabel}: ${series.originalName}',
                        style: textStyles.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        SeriesCertificationBadge(seriesId: series.id),
                        StarRating(voteAverage: series.voteAverage),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.firstAirDateLabel}: ${firstAirDate == null ? l10n.releaseDateUnknown : HumanFormats.date(firstAirDate, locale)}',
                      style: textStyles.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Text(l10n.overviewTitle, style: textStyles.titleMedium),
                    const SizedBox(height: 4),
                    Text(series.overview.isEmpty ? l10n.overviewUnavailable : series.overview),
                  ],
                ),
              ),

            ],
          ),
        ),

        // Temporadas, episodios y cadena
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8),
          child: Wrap(
            spacing: 10,
            runSpacing: 4,
            children: [
              if (series.numberOfSeasons != null)
                _InfoChip(
                  icon: Icons.video_library_outlined,
                  text: '${l10n.seasonsLabel}: ${HumanFormats.integer(series.numberOfSeasons!, locale)}',
                ),
              if (series.numberOfEpisodes != null)
                _InfoChip(
                  icon: Icons.playlist_play_rounded,
                  text: '${l10n.episodesLabel}: ${HumanFormats.integer(series.numberOfEpisodes!, locale)}',
                ),
              if (series.networks.isNotEmpty)
                _InfoChip(
                  icon: Icons.live_tv_rounded,
                  text: '${l10n.networksLabel}: ${series.networks.join(', ')}',
                ),
            ],
          ),
        ),

        // Géneros
        if (series.genreIds.isNotEmpty)
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 0),
            child: Text(l10n.genresTitle, style: textStyles.titleMedium),
          ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            children: [
              ...series.genreIds.map((genre) => Container(
                margin: const EdgeInsetsDirectional.only(end: 10),
                child: Chip(
                  label: Text(genre),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                ),
              )),
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 4),
          child: Text(l10n.castTitle, style: textStyles.titleMedium),
        ),
        _SeriesCast(seriesId: series.id),

        const SizedBox(height: 50),
      ],
    );
  }
}


class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({ required this.icon, required this.text });

  @override
  Widget build(BuildContext context) {
    return Chip(
      avatar: Icon(icon, size: 18, color: AppColors.violetLight),
      label: Text(text),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
    );
  }
}


class _SeriesCast extends ConsumerWidget {

  final int seriesId;

  const _SeriesCast({ required this.seriesId });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cast = ref.watch(seriesCastProvider(seriesId));

    return cast.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(strokeWidth: 2),
      ),
      error: (error, _) => Padding(
        padding: const EdgeInsets.all(12),
        child: Text(context.l10n.castEmpty, style: const TextStyle(color: AppColors.textSecondary)),
      ),
      data: (actors) {
        if (actors.isEmpty) {
          return Padding(
            padding: const EdgeInsets.all(12),
            child: Text(context.l10n.castEmpty, style: const TextStyle(color: AppColors.textSecondary)),
          );
        }

        return SizedBox(
          height: 300,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            itemCount: actors.length,
            itemBuilder: (context, index) {
              final actor = actors[index];

              return Container(
                padding: const EdgeInsets.all(8.0),
                width: 135,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FadeInRight(
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(20),
                        child: Image.network(
                          actor.profilePath,
                          height: 180,
                          width: 135,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) => const SizedBox(
                            height: 180,
                            width: 135,
                            child: ColoredBox(color: AppColors.surfaceHigh, child: Icon(Icons.person_outline_rounded)),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(actor.name, maxLines: 2),
                    Text(
                      actor.character ?? '',
                      maxLines: 2,
                      style: const TextStyle(fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis),
                    ),
                  ],
                ),
              );
            },
          ),
        );
      },
    );
  }
}


class _CustomSliverAppBar extends StatelessWidget {

  final TvSeries series;

  const _CustomSliverAppBar({ required this.series });

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return SliverAppBar(
      backgroundColor: Colors.black,
      expandedHeight: size.height * 0.7,
      foregroundColor: Colors.white,
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        background: Stack(
          children: [
            SizedBox.expand(
              child: Image.network(
                series.posterPath,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if (loadingProgress != null) return const SizedBox();
                  return FadeIn(child: child);
                },
                errorBuilder: (context, error, stackTrace) => const ColoredBox(color: AppColors.surface),
              ),
            ),
            const SizedBox.expand(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.7, 1.0],
                    colors: [Colors.transparent, AppColors.background],
                  ),
                ),
              ),
            ),
            const SizedBox.expand(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    stops: [0.0, 0.3],
                    colors: [Colors.black87, Colors.transparent],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
