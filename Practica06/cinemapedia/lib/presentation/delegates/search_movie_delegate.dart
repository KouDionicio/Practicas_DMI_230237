import 'dart:async';

import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/config/helpers/l10n_helpers.dart';
import 'package:cinemapedia/config/theme/app_theme.dart';
import 'package:cinemapedia/presentation/widgets/shared/state_message_view.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/domain/entities/movie.dart';


typedef SearchMoviesCallback = Future<List<Movie>> Function( String query );

class SearchMovieDelegate extends SearchDelegate<Movie?>{


  final SearchMoviesCallback searchMovies;
  List<Movie> initialMovies;

  StreamController<List<Movie>> debouncedMovies = StreamController.broadcast();
  StreamController<bool> isLoadingStream = StreamController.broadcast();

  /// Último error de búsqueda (se muestra traducido).
  Object? _lastError;

  Timer? _debounceTimer;

  SearchMovieDelegate({
    required this.searchMovies,
    required this.initialMovies,
    required String searchFieldLabel,
  }):super(
    searchFieldLabel: searchFieldLabel,
  );

  void clearStreams() {
    _debounceTimer?.cancel();
    if ( !debouncedMovies.isClosed ) debouncedMovies.close();
    if ( !isLoadingStream.isClosed ) isLoadingStream.close();
  }

  void _onQueryChanged( String query ) {
    if ( isLoadingStream.isClosed ) return;
    isLoadingStream.add(true);

    if ( _debounceTimer?.isActive ?? false ) _debounceTimer!.cancel();

    _debounceTimer = Timer(const Duration( milliseconds: 500 ), () async {
      List<Movie> movies = [];
      try {
        movies = await searchMovies( query );
        _lastError = null;
      } catch (error) {
        _lastError = error;
      }
      initialMovies = movies;
      if ( !debouncedMovies.isClosed ) debouncedMovies.add(movies);
      if ( !isLoadingStream.isClosed ) isLoadingStream.add(false);
    });

  }

  Widget buildResultsAndSuggestions() {
    return StreamBuilder(
      initialData: initialMovies,
      stream: debouncedMovies.stream,
      builder: (context, snapshot) {

        final l10n = context.l10n;
        final movies = snapshot.data ?? [];

        if ( _lastError != null ) {
          return StateMessageView(
            icon: Icons.wifi_off_rounded,
            title: l10n.errorLoadMovies,
            message: l10n.describeError(_lastError),
            isError: true,
          );
        }

        if ( movies.isEmpty ) {
          return StateMessageView(
            icon: Icons.search_rounded,
            title: query.trim().isEmpty ? l10n.searchEmptyHint : l10n.searchNoResults(query.trim()),
          );
        }

        return ListView.builder(
          itemCount: movies.length,
          itemBuilder: (context, index) => _MovieItem(
            movie: movies[index],
            onMovieSelected: (context, movie) {
              clearStreams();
              close(context, movie);
            },
          ),
        );
      },
    );
  }


  @override
  List<Widget>? buildActions(BuildContext context) {

    return [

      StreamBuilder(
        initialData: false,
        stream: isLoadingStream.stream,
        builder: (context, snapshot) {
            if ( snapshot.data ?? false ) {
              return SpinPerfect(
                  duration: const Duration(seconds: 20),
                  spins: 10,
                  infinite: true,
                  child: IconButton(
                    onPressed: () => query = '',
                    icon: const Icon( Icons.refresh_rounded )
                  ),
                );
            }

             return FadeIn(
                animate: query.isNotEmpty,
                child: IconButton(
                  tooltip: context.l10n.searchClearTooltip,
                  onPressed: () => query = '',
                  icon: const Icon( Icons.clear )
                ),
              );

        },
      ),

    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      tooltip: MaterialLocalizations.of(context).backButtonTooltip,
      onPressed: () {
          clearStreams();
          close(context, null);
        },
        icon: const Icon( Icons.arrow_back_ios_new_rounded)
      );
  }

  @override
  Widget buildResults(BuildContext context) {
    return buildResultsAndSuggestions();
  }

  @override
  Widget buildSuggestions(BuildContext context) {

    _onQueryChanged(query);
    return buildResultsAndSuggestions();

  }

}

class _MovieItem extends StatelessWidget {

  final Movie movie;
  final Function onMovieSelected;

  const _MovieItem({
    required this.movie,
    required this.onMovieSelected
  });

  @override
  Widget build(BuildContext context) {

    final textStyles = Theme.of(context).textTheme;
    final size = MediaQuery.of(context).size;
    final locale = context.l10n.localeName;

    return InkWell(
      onTap: () {
        onMovieSelected(context, movie);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            // Image
            SizedBox(
              width: size.width * 0.2,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: Image.network(
                  movie.posterPath,
                  loadingBuilder: (context, child, loadingProgress) => FadeIn(child: child),
                  errorBuilder: (context, error, stackTrace) =>
                      const AspectRatio(aspectRatio: 2 / 3, child: Icon(Icons.broken_image_outlined)),
                ),
              ),
            ),

            const SizedBox(width: 10),

            // Description
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text( movie.title, style: textStyles.titleMedium ),

                  if ( movie.originalTitle.isNotEmpty && movie.originalTitle != movie.title )
                    Text(
                      movie.originalTitle,
                      style: textStyles.bodySmall?.copyWith(fontStyle: FontStyle.italic, color: AppColors.textSecondary),
                    ),

                  Text(
                    movie.overview,
                    maxLines: 3,
                    overflow: TextOverflow.ellipsis,
                  ),

                  Row(
                    children: [
                      const Icon( Icons.star_half_rounded, color: AppColors.star ),
                      const SizedBox(width: 5),
                      Text(
                        HumanFormats.decimal(movie.voteAverage, locale),
                        style: textStyles.bodyMedium!.copyWith(color: AppColors.star ),
                      ),
                    ],
                  )


                ],
              ),
            ),

          ],
        ),
      ),
    );
  }
}
