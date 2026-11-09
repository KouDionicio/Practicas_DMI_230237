import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

import 'package:cinemapedia/config/router/app_router.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/screens/screens.dart';
import 'test_helpers.dart';

void main() {
  Future<void> pumpHome(WidgetTester tester, {String region = 'MX'}) async {
    tester.view.physicalSize = const Size(1080, 2400);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);

    // Mismas rutas que la app, empezando en Inicio (sin splash).
    final router = GoRouter(initialLocation: '/home/0', routes: appRouter.configuration.routes);
    addTearDown(router.dispose);

    await tester.pumpWidget(ProviderScope(
      overrides: await testOverrides(prefs: {AppRegionNotifier.storageKey: region}),
      child: TestApp(routerConfig: router),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('el botón hamburguesa abre el menú y el botón del menú lo cierra', (tester) async {
    await pumpHome(tester);
    final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold).first);

    await tester.tap(find.byKey(const Key('drawer-menu-button')));
    await tester.pumpAndSettle();
    expect(scaffold.isDrawerOpen, isTrue);
    expect(find.text('Cinemapedia'), findsWidgets);
    expect(find.text('Configuración'), findsOneWidget);

    await tester.tap(find.byKey(const Key('drawer-close-button')));
    await tester.pumpAndSettle();
    expect(scaffold.isDrawerOpen, isFalse);
  });

  testWidgets('el menú se abre y se cierra con gestos de deslizamiento', (tester) async {
    await pumpHome(tester);
    final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold).first);

    await tester.dragFrom(const Offset(4, 600), const Offset(320, 0));
    await tester.pumpAndSettle();
    expect(scaffold.isDrawerOpen, isTrue);

    await tester.fling(find.byKey(const Key('side-menu')), const Offset(-320, 0), 1200);
    await tester.pumpAndSettle();
    expect(scaffold.isDrawerOpen, isFalse);
  });

  testWidgets('desde el menú se navega a Configuración y se regresa a Inicio', (tester) async {
    await pumpHome(tester);

    await tester.tap(find.byKey(const Key('drawer-menu-button')));
    await tester.pumpAndSettle();
    await tester.tap(find.text('Configuración'));
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsOneWidget);

    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.byType(SettingsScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
  });

  testWidgets('en árabe el menú se abre desde la derecha (RTL)', (tester) async {
    await pumpHome(tester, region: 'EG');
    final scaffold = tester.state<ScaffoldState>(find.byType(Scaffold).first);

    final width = tester.view.physicalSize.width / tester.view.devicePixelRatio;
    await tester.dragFrom(Offset(width - 4, 600), const Offset(-320, 0));
    await tester.pumpAndSettle();
    expect(scaffold.isDrawerOpen, isTrue);
    expect(find.text('الإعدادات'), findsOneWidget);
  });
}
