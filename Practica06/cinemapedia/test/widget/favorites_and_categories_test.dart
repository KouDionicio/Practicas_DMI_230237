import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cinemapedia/config/router/app_router.dart';
import 'package:cinemapedia/infrastructure/datasource/shared_prefs_favorites_datasource.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
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

  testWidgets('Favoritos vacío muestra el mensaje traducido', (tester) async {
    await pumpAt(tester, '/home/2');
    expect(find.text('Aún no tienes favoritos'), findsOneWidget);
  });

  testWidgets('el corazón del detalle agrega la película, la guarda y aparece en Favoritos', (tester) async {
    final router = await pumpAt(tester, '/home/0/movie/5');

    await tester.tap(find.byKey(const Key('favorite-button-5')).first);
    await tester.pumpAndSettle();
    expect(find.text('«Movie 5» se agregó a favoritos'), findsOneWidget);

    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(SharedPrefsFavoritesDatasource.storageKey), contains('"id":5'));

    router.go('/home/2');
    await tester.pumpAndSettle();
    expect(find.text('Aún no tienes favoritos'), findsNothing);
    expect(find.bySemanticsLabel('Movie 5'), findsOneWidget);
    await tester.pump(const Duration(seconds: 4)); // SnackBar
  });

  testWidgets('Deshacer revierte el cambio', (tester) async {
    await pumpAt(tester, '/home/0/movie/5');
    await tester.tap(find.byKey(const Key('favorite-button-5')).first);
    await tester.pumpAndSettle();
    await tester.tap(find.text('Deshacer'));
    await tester.pumpAndSettle();

    final container = ProviderScope.containerOf(tester.element(find.byType(Scaffold).first));
    expect(container.read(favoriteMoviesProvider), isEmpty);
    await tester.pump(const Duration(seconds: 4));
  });

  testWidgets('Categorías muestra los géneros traducidos y sus películas', (tester) async {
    await pumpAt(tester, '/home/1', region: 'JP');
    expect(find.text('アクション'), findsOneWidget);
    expect(find.text('ジャンルを選択してください'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Movie')), findsWidgets);

    await tester.tap(find.byKey(const Key('genre-chip-35')));
    await tester.pumpAndSettle();
    final chip = tester.widget<ChoiceChip>(find.byKey(const Key('genre-chip-35')));
    expect(chip.selected, isTrue);
  });
}
