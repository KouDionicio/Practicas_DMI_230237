import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:cinemapedia/presentation/widgets/movies/movies_slideshow.dart';
import 'test_helpers.dart';

void main() {
  final movies = List.generate(8, (i) => fakeMovie(i + 1));

  Future<MoviesSlideshowState> pumpCarousel(WidgetTester tester) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);

    await tester.pumpWidget(ProviderScope(
      overrides: await testOverrides(),
      child: TestApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: MoviesSlideshow(movies: movies, autoplay: false, onMovieTap: (_) {}),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    return tester.state<MoviesSlideshowState>(find.byType(MoviesSlideshow));
  }

  Future<void> tapArrow(WidgetTester tester, String key) async {
    await tester.tap(find.byKey(Key(key)));
    await tester.pump(const Duration(milliseconds: 60));
  }

  testWidgets('la flecha > avanza y el panel muestra la película seleccionada', (tester) async {
    final state = await pumpCarousel(tester);
    expect(state.selectedIndex, 0);
    expect(find.text('Movie 1'), findsWidgets);

    await tapArrow(tester, 'carousel-next');
    await tester.pumpAndSettle();
    expect(state.selectedIndex, 1);
    expect(find.text('Movie 2'), findsWidgets);
    expect(find.text('Original 2'), findsOneWidget);

    await tapArrow(tester, 'carousel-previous');
    await tester.pumpAndSettle();
    expect(state.selectedIndex, 0);
  });

  testWidgets('tres pulsaciones seguidas en > saltan a la última y en < a la primera', (tester) async {
    final state = await pumpCarousel(tester);

    await tapArrow(tester, 'carousel-next');
    await tapArrow(tester, 'carousel-next');
    await tapArrow(tester, 'carousel-next');
    await tester.pumpAndSettle();
    expect(state.selectedIndex, movies.length - 1);
    expect(find.text('Movie 8'), findsWidgets);

    await tapArrow(tester, 'carousel-previous');
    await tapArrow(tester, 'carousel-previous');
    await tapArrow(tester, 'carousel-previous');
    await tester.pumpAndSettle();
    expect(state.selectedIndex, 0);

    await tester.pump(const Duration(seconds: 2)); // aviso de salto
  });

  testWidgets('cambiar de dirección reinicia el contador (no salta)', (tester) async {
    final state = await pumpCarousel(tester);

    await tapArrow(tester, 'carousel-next');
    await tapArrow(tester, 'carousel-next');
    await tapArrow(tester, 'carousel-previous');
    await tester.pumpAndSettle();
    expect(state.selectedIndex, 1);
  });

  testWidgets('deslizar cambia de película y sincroniza el panel', (tester) async {
    final state = await pumpCarousel(tester);

    await tester.fling(find.byKey(const Key('movies-slideshow-pageview')), const Offset(-400, 0), 1500);
    await tester.pumpAndSettle();
    expect(state.selectedIndex, greaterThan(0));
    expect(find.text('Movie ${state.selectedIndex + 1}'), findsWidgets);
  });

  testWidgets('la lista puede cambiar sin romper la selección', (tester) async {
    final state = await pumpCarousel(tester);
    await tapArrow(tester, 'carousel-next');
    await tester.pumpAndSettle();

    await tester.pumpWidget(ProviderScope(
      overrides: await testOverrides(),
      child: TestApp(
        home: Scaffold(
          body: SingleChildScrollView(
            child: MoviesSlideshow(movies: movies.reversed.take(3).toList(), autoplay: false),
          ),
        ),
      ),
    ));
    await tester.pumpAndSettle();
    final newState = tester.state<MoviesSlideshowState>(find.byType(MoviesSlideshow));
    expect(identical(newState, state) || newState.selectedIndex == 0, isTrue);
    expect(newState.selectedIndex, lessThan(3));
  });
}
