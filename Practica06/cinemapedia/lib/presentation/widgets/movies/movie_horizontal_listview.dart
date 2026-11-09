import 'package:cinemapedia/config/helpers/human_formats.dart';
import 'package:cinemapedia/config/helpers/l10n_helpers.dart';
import 'package:cinemapedia/config/theme/app_theme.dart';
import 'package:cinemapedia/presentation/widgets/shared/pressable_scale.dart';
import 'package:flutter/material.dart';
import 'package:animate_do/animate_do.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:go_router/go_router.dart';


class MovieHorizontalListview extends StatefulWidget {

  final List<Movie> movies;
  final String? title;
  final String? subTitle;
  final VoidCallback? loadNextPage;

  const MovieHorizontalListview({
    super.key,
    required this.movies,
    this.title,
    this.subTitle,
    this.loadNextPage
  });

  @override
  State<MovieHorizontalListview> createState() => _MovieHorizontalListviewState();
}

class _MovieHorizontalListviewState extends State<MovieHorizontalListview> {


  final scrollController = ScrollController();

  @override
  void initState() {
    super.initState();

    scrollController.addListener(() {
      if ( widget.loadNextPage == null ) return;

      if ( (scrollController.position.pixels + 200) >= scrollController.position.maxScrollExtent ) {
        widget.loadNextPage!();
      }

    });

  }

  @override
  void dispose() {
    scrollController.dispose();
    super.dispose();
  }



  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 370,
      child: Column(
        children: [

          if ( widget.title != null || widget.subTitle != null )
            _Title(title: widget.title, subTitle: widget.subTitle ),


          Expanded(
            child: ListView.builder(
              controller: scrollController,
              itemCount: widget.movies.length,
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 8),
              physics: const BouncingScrollPhysics(),
              itemBuilder: (context, index) {
                return FadeInRight(child: _Slide(movie: widget.movies[index]));
              },
            )
          )

        ],
      ),
    );
  }
}


class _Slide extends StatelessWidget {

  final Movie movie;

  const _Slide({ required this.movie });

  @override
  Widget build(BuildContext context) {

    final textStyles = Theme.of(context).textTheme;
    final locale = context.l10n.localeName;

    return Container(
      margin: const EdgeInsets.symmetric( horizontal: 8),
      width: 150,
      child: PressableScale(
        // Antes el toque solo funcionaba cuando la imagen terminaba de cargar.
        onTap: () => context.push('/home/0/movie/${ movie.id }'),
        semanticLabel: movie.title,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [

            //* Imagen
            ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: SizedBox(
                width: 150,
                height: 225,
                child: Image.network(
                  movie.posterPath,
                  fit: BoxFit.cover,
                  loadingBuilder: (context, child, loadingProgress) {
                    if ( loadingProgress != null ) {
                      return const ColoredBox(
                        color: AppColors.surfaceHigh,
                        child: Center(child: CircularProgressIndicator(strokeWidth: 2 )),
                      );
                    }
                    return FadeIn(child: child);
                  },
                  errorBuilder: (context, error, stackTrace) => const ColoredBox(
                    color: AppColors.surfaceHigh,
                    child: Center(child: Icon(Icons.broken_image_outlined, color: AppColors.textSecondary)),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 8),

            //* Title
            Text(
              movie.title,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: textStyles.titleSmall,
            ),

            const SizedBox(height: 2),

            //* Rating
            Row(
              children: [
                const Icon( Icons.star_rounded, color: AppColors.star, size: 18 ),
                const SizedBox( width: 3 ),
                Text(
                  HumanFormats.decimal(movie.voteAverage, locale),
                  style: textStyles.bodyMedium?.copyWith( color: AppColors.star, fontWeight: FontWeight.w700 ),
                ),
                const Spacer(),
                const Icon( Icons.local_fire_department_outlined, size: 14, color: AppColors.textSecondary ),
                Text( HumanFormats.number(movie.popularity, 0, locale), style: textStyles.bodySmall ),
              ],
            )

          ],
        ),
      ),
    );
  }
}



class _Title extends StatelessWidget {

  final String? title;
  final String? subTitle;


  const _Title({ this.title, this.subTitle});

  @override
  Widget build(BuildContext context) {

    final titleStyle = Theme.of(context).textTheme.titleLarge;

    return Container(
      padding: const EdgeInsets.only( top: 14, bottom: 6 ),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      child: Row(
        children: [

          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              gradient: AppColors.brandGradient,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: 8),

          if ( title != null )
            Expanded(child: Text(title!, style: titleStyle, overflow: TextOverflow.ellipsis )),

          if ( subTitle != null )
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.violet.withValues(alpha: .18),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.violet.withValues(alpha: .4)),
              ),
              child: Text(
                subTitle!,
                style: const TextStyle(color: AppColors.violetLight, fontSize: 12, fontWeight: FontWeight.w600),
              ),
            )

        ],
      ),
    );
  }
}
