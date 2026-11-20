import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cinemapedia/config/router/app_router.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/screens/screens.dart';
import 'package:cinemapedia/presentation/views/views.dart';
import 'package:cinemapedia/presentation/widgets/widgets.dart';
import 'test_helpers.dart';

void main() {
  Future<GoRouter> pumpAt(WidgetTester tester, String location, {String region = 'MX'}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);
    final router = GoRouter(initialLocation: location, routes: appRouter.configuration.routes);
    addTearDown(router.dispose);
    await tester.pumpWidget(ProviderScope(
      overrides: await testOverrides(prefs: {AppRegionNotifier.storageKey: region}),
      child: TestApp(routerConfig: router),
    ));
    await tester.pumpAndSettle();
    return router;
  }

  String location(GoRouter router) => router.routerDelegate.currentConfiguration.uri.toString();

  testWidgets('la barra inferior navega entre Inicio, Categorías, Favoritos y Series', (tester) async {
    final router = await pumpAt(tester, '/home/0');

    await tester.tap(find.text('Series').last);
    await tester.pumpAndSettle();
    expect(location(router), '/home/3');
    expect(find.byType(SeriesSlideshow), findsOneWidget);
    expect(find.text('Al aire hoy'), findsOneWidget);

    await tester.tap(find.text('Categorías').last);
    await tester.pumpAndSettle();
    expect(location(router), '/home/1');

    await tester.tap(find.text('Favoritos').last);
    await tester.pumpAndSettle();
    expect(location(router), '/home/2');

    await tester.tap(find.text('Inicio').last);
    await tester.pumpAndSettle();
    expect(location(router), '/home/0');
    expect(find.byType(MoviesSlideshow), findsOneWidget); // películas intactas
  });

  testWidgets('el menú lateral incluye Series y navega a la pestaña', (tester) async {
    final router = await pumpAt(tester, '/home/0');

    await tester.tap(find.byKey(const Key('drawer-menu-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.descendant(of: find.byKey(const Key('side-menu')), matching: find.text('Series')));
    await tester.pumpAndSettle();
    expect(location(router), '/home/3');

    // Configuración sigue funcionando desde el menú.
    await tester.tap(find.byKey(const Key('drawer-menu-button')).hitTestable());
    await tester.pumpAndSettle();
    await tester.tap(find.text('Configuración'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  testWidgets('las flechas del carrusel de series cambian la serie del panel', (tester) async {
    await pumpAt(tester, '/home/3');
    final state = tester.state<SeriesSlideshowState>(find.byType(SeriesSlideshow));
    expect(state.selectedIndex, 0);

    await tester.tap(find.byKey(const Key('series-carousel-next')));
    await tester.pumpAndSettle();
    expect(state.selectedIndex, 1);
  });

  testWidgets('"Ver detalles" abre el detalle de la serie con temporadas y reparto', (tester) async {
    final router = await pumpAt(tester, '/home/3');

    await tester.scrollUntilVisible(find.text('Ver detalles'), 200,
        scrollable: find.descendant(of: find.byType(SeriesView), matching: find.byType(Scrollable)).first);
    await tester.tap(find.text('Ver detalles'));
    await tester.pumpAndSettle();

    expect(location(router), startsWith('/home/3/series/'));
    expect(find.byType(SeriesScreen), findsOneWidget);
    expect(find.text('Temporadas: 3'), findsOneWidget);
    expect(find.text('Episodios: 24'), findsOneWidget);
  });

  testWidgets('los textos de Series se traducen (japonés)', (tester) async {
    await pumpAt(tester, '/home/3', region: 'JP');
    expect(find.text('本日放送'), findsOneWidget);
    expect(find.text('TVシリーズ'), findsWidgets);
    expect(find.text('シリーズ 30001'), findsWidgets); // datos en el idioma del país
  });
}
