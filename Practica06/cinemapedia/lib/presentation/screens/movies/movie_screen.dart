import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/config/helpers/l10n_helpers.dart';
import 'package:cinemapedia/config/theme/app_theme.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';


class MovieScreen extends ConsumerStatefulWidget {

  static const name = 'movie-screen';

  final String movieId;

  const MovieScreen({
    super.key,
    required this.movieId
  });

  @override
  MovieScreenState createState() => MovieScreenState();
}

class MovieScreenState extends ConsumerState<MovieScreen> {

  Object? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    setState(() => _error = null);
    ref.read(movieInfoProvider.notifier).loadMovie(widget.movieId).catchError((Object error) {
      if (mounted) setState(() => _error = error);
    });
    ref.read(actorsByMovieProvider.notifier).loadActors(widget.movieId).catchError((Object _) {});
  }

  @override
  Widget build(BuildContext context) {

    final l10n = context.l10n;
    final Movie? movie = ref.watch( movieInfoProvider )[widget.movieId];

    // Si cambia el país, los providers se reinician y hay que volver a pedir
    // el detalle en el nuevo idioma.
    ref.listen(movieRepositoryProvider, (_, _) => _load());

    if ( movie == null ) {
      return Scaffold(
        appBar: AppBar(),
        body: _error == null
            ? const Center( child: CircularProgressIndicator( strokeWidth: 2))
            : StateMessageView(
                icon: Icons.movie_filter_outlined,
                title: l10n.errorLoadMovie,
                message: l10n.describeError(_error),
                actionLabel: l10n.retry,
                isError: true,
                onAction: _load,
              ),
      );
    }


    return Scaffold(
      body: CustomScrollView(
        physics: const ClampingScrollPhysics(),
        slivers: [
          _CustomSliverAppBar(movie: movie),
          SliverList(delegate: SliverChildBuilderDelegate(
            (context, index) => _MovieDetails(movie: movie),
            childCount: 1
          ))
        ],
      ),
    );
  }
}


class _MovieDetails extends StatelessWidget {

  final Movie movie;

  const _MovieDetails({required this.movie});

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;
    final textStyles = Theme.of(context).textTheme;
    final l10n = context.l10n;
    final releaseDate = movie.releaseDate;


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
                  movie.posterPath,
                  width: size.width * 0.3,
                  errorBuilder: (context, error, stackTrace) => SizedBox(
                    width: size.width * 0.3,
                    child: const AspectRatio(aspectRatio: 2 / 3, child: Icon(Icons.broken_image_outlined)),
                  ),
                ),
              ),

              const SizedBox( width: 12 ),

              // Descripción
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text( movie.title, style: textStyles.titleLarge ),
                    if ( movie.originalTitle.isNotEmpty && movie.originalTitle != movie.title ) ...[
                      const SizedBox(height: 4),
                      Text(
                        '${l10n.originalTitleLabel}: ${movie.originalTitle}',
                        style: textStyles.bodyMedium?.copyWith(fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                      ),
                    ],
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10,
                      runSpacing: 8,
                      crossAxisAlignment: WrapCrossAlignment.center,
                      children: [
                        CertificationBadge(movieId: movie.id),
                        StarRating(voteAverage: movie.voteAverage),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${l10n.releaseDateLabel}: ${releaseDate == null ? l10n.releaseDateUnknown : HumanFormats.date(releaseDate, l10n.localeName)}',
                      style: textStyles.bodySmall?.copyWith(color: AppColors.textSecondary),
                    ),
                    const SizedBox(height: 12),
                    Text( l10n.overviewTitle, style: textStyles.titleMedium ),
                    const SizedBox(height: 4),
                    Text( movie.overview.isEmpty ? l10n.overviewUnavailable : movie.overview ),
                  ],
                ),
              )

            ],
          ),
        ),


        // Generos de la película
        if ( movie.genreIds.isNotEmpty )
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(12, 4, 12, 0),
            child: Text( l10n.genresTitle, style: textStyles.titleMedium ),
          ),
        Padding(
          padding: const EdgeInsets.all(8),
          child: Wrap(
            children: [
              ...movie.genreIds.map((gender) => Container(
                margin: const EdgeInsetsDirectional.only( end: 10),
                child: Chip(
                  label: Text( gender ),
                  shape: RoundedRectangleBorder( borderRadius: BorderRadius.circular(20)),
                ),
              ))
            ],
          ),
        ),

        Padding(
          padding: const EdgeInsetsDirectional.fromSTEB(12, 8, 12, 4),
          child: Text( l10n.castTitle, style: textStyles.titleMedium ),
        ),
        _ActorsByMovie(movieId: movie.id.toString() ),

        const SizedBox(height: 50 ),
      ],
    );
  }
}


class _ActorsByMovie extends ConsumerWidget {

  final String movieId;

  const _ActorsByMovie({required this.movieId});

  @override
  Widget build(BuildContext context, ref) {

    final actorsByMovie = ref.watch( actorsByMovieProvider );

    if ( actorsByMovie[movieId] == null ) {
      return const Padding(
        padding: EdgeInsets.all(16),
        child: CircularProgressIndicator(strokeWidth: 2),
      );
    }
    final actors = actorsByMovie[movieId]!;

    if ( actors.isEmpty ) {
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

                // Actor Photo
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

                // Nombre
                const SizedBox(height: 5,),

                Text(actor.name, maxLines: 2 ),
                Text(actor.character ?? '',
                  maxLines: 2,
                  style: const TextStyle( fontWeight: FontWeight.bold, overflow: TextOverflow.ellipsis ),
              ),

              ],
            ),
          );


        },
      ),
    );

  }
}





class _CustomSliverAppBar extends StatelessWidget {

  final Movie movie;

  const _CustomSliverAppBar({
    required this.movie
  });

  @override
  Widget build(BuildContext context) {

    final size = MediaQuery.of(context).size;

    return SliverAppBar(
      backgroundColor: Colors.black,
      expandedHeight: size.height * 0.7,
      foregroundColor: Colors.white,
      actions: [
        FavoriteButton(movie: movie, onImage: true),
      ],
      flexibleSpace: FlexibleSpaceBar(
        titlePadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        background: Stack(
          children: [

            SizedBox.expand(
              child: Image.network(
                movie.posterPath,
                fit: BoxFit.cover,
                loadingBuilder: (context, child, loadingProgress) {
                  if ( loadingProgress != null ) return const SizedBox();
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
                    colors: [
                      Colors.transparent,
                      AppColors.background
                    ]
                  )
                )
              ),
            ),

            const SizedBox.expand(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: AlignmentDirectional.topStart,
                    end: AlignmentDirectional.bottomEnd,
                    stops: [0.0, 0.3],
                    colors: [
                      Colors.black87,
                      Colors.transparent,
                    ]
                  )
                )
              ),
            ),



          ],
        ),
      ),
    );
  }
}
