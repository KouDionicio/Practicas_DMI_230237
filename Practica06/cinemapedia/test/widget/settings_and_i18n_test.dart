import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cinemapedia/config/constants/app_regions.dart';
import 'package:cinemapedia/l10n/app_localizations.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:go_router/go_router.dart';

import 'package:cinemapedia/config/router/app_router.dart';
import 'package:cinemapedia/presentation/screens/screens.dart';
import 'test_helpers.dart';

void main() {
  /// Flujo real: Inicio → (menú) Configuración, con las rutas de la app.
  Future<GoRouter> pumpSettings(WidgetTester tester, {Map<String, Object> prefs = const {}}) async {
    tester.view.physicalSize = const Size(1080, 3200);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);
    final router = GoRouter(initialLocation: '/home/0', routes: appRouter.configuration.routes);
    addTearDown(router.dispose);
    await tester.pumpWidget(ProviderScope(
      overrides: await testOverrides(prefs: prefs),
      child: TestApp(routerConfig: router),
    ));
    await tester.pumpAndSettle();
    router.push('/settings');
    await tester.pumpAndSettle();
    return router;
  }

  /// Toca una tarjeta y espera a que termine la redirección a Inicio.
  Future<void> selectRegion(WidgetTester tester, String code) async {
    await tester.tap(find.byKey(Key('region-card-$code')));
    await tester.pump();
    await tester.pump(SettingsScreen.redirectDelay);
    await tester.pumpAndSettle();
  }

  String location(GoRouter router) => router.routerDelegate.currentConfiguration.uri.toString();

  testWidgets('muestra las 8 tarjetas y solo una seleccionada', (tester) async {
    await pumpSettings(tester, prefs: {AppRegionNotifier.storageKey: 'MX'});
    for (final region in AppRegions.all) {
      expect(find.byKey(Key('region-card-${region.code}')), findsOneWidget);
    }
    expect(find.text('Configuración'), findsOneWidget);
    expect(find.text('REGIÓN E IDIOMA'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Seleccionado')), findsOneWidget);
  });

  testWidgets('elegir Japón guarda la región, cambia el idioma y redirige a Inicio', (tester) async {
    final router = await pumpSettings(tester, prefs: {AppRegionNotifier.storageKey: 'MX'});

    await selectRegion(tester, 'JP');

    // Redirigido a Inicio, sin Configuración debajo ni pantallas duplicadas.
    expect(location(router), '/home/0');
    expect(find.byType(SettingsScreen), findsNothing);
    expect(find.byType(HomeScreen), findsOneWidget);
    expect(router.canPop(), isFalse);
    // Inicio ya está en japonés.
    expect(find.text('ホーム'), findsWidgets);
    expect(find.text('TVシリーズ'), findsWidgets);
    expect(find.text('Inicio'), findsNothing);
    // Preferencia guardada.
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(AppRegionNotifier.storageKey), 'JP');
    await tester.pump(const Duration(seconds: 3)); // SnackBar
  });

  testWidgets('elegir Corea redirige a Inicio en coreano', (tester) async {
    final router = await pumpSettings(tester, prefs: {AppRegionNotifier.storageKey: 'MX'});
    await selectRegion(tester, 'KR');
    expect(location(router), '/home/0');
    expect(find.text('홈'), findsWidgets);
    expect(find.text('TV 시리즈'), findsWidgets);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('elegir Egipto redirige a Inicio en árabe con dirección RTL', (tester) async {
    final router = await pumpSettings(tester, prefs: {AppRegionNotifier.storageKey: 'MX'});
    await selectRegion(tester, 'EG');

    expect(location(router), '/home/0');
    expect(find.text('الرئيسية'), findsWidgets);
    final context = tester.element(find.byType(HomeScreen));
    expect(Directionality.of(context), TextDirection.rtl);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('volver a tocar el país ya seleccionado no navega', (tester) async {
    final router = await pumpSettings(tester, prefs: {AppRegionNotifier.storageKey: 'MX'});
    await selectRegion(tester, 'MX');
    expect(location(router), '/settings');
    expect(find.byType(SettingsScreen), findsOneWidget);
  });

  test('la región guardada se recupera en una nueva sesión', () async {
    SharedPreferences.setMockInitialValues({AppRegionNotifier.storageKey: 'BR'});
    final prefs = await SharedPreferences.getInstance();
    final container = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
    addTearDown(container.dispose);

    expect(container.read(appRegionProvider), AppRegions.brazil);
    await container.read(appRegionProvider.notifier).select(AppRegions.germany);

    // "Reabrir la app": contenedor nuevo con las mismas preferencias.
    final reopened = ProviderContainer(overrides: [sharedPreferencesProvider.overrideWithValue(prefs)]);
    addTearDown(reopened.dispose);
    expect(reopened.read(appRegionProvider), AppRegions.germany);
  });

  test('las 8 traducciones existen y son distintas', () {
    final titles = <String>{};
    for (final region in AppRegions.all) {
      final l10n = lookupAppLocalizations(Locale(region.languageCode, region.code));
      expect(l10n.navSettings, isNotEmpty);
      titles.add(l10n.navSettings);
    }
    expect(titles.length, AppRegions.all.length);
  });
}
