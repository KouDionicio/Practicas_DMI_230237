import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cinemapedia/config/constants/app_regions.dart';
import 'package:cinemapedia/l10n/app_localizations.dart';
import 'package:cinemapedia/presentation/providers/providers.dart';
import 'package:cinemapedia/presentation/screens/settings/settings_screen.dart';
import 'test_helpers.dart';

void main() {
  Future<void> pumpSettings(WidgetTester tester, {Map<String, Object> prefs = const {}}) async {
    tester.view.physicalSize = const Size(1080, 3200);
    tester.view.devicePixelRatio = 2.6;
    addTearDown(tester.view.reset);
    await tester.pumpWidget(ProviderScope(
      overrides: await testOverrides(prefs: prefs),
      child: const TestApp(home: SettingsScreen()),
    ));
    await tester.pumpAndSettle();
  }

  testWidgets('muestra las 8 tarjetas y solo una seleccionada', (tester) async {
    await pumpSettings(tester, prefs: {AppRegionNotifier.storageKey: 'MX'});
    for (final region in AppRegions.all) {
      expect(find.byKey(Key('region-card-${region.code}')), findsOneWidget);
    }
    expect(find.text('Configuración'), findsOneWidget);
    expect(find.text('REGIÓN E IDIOMA'), findsOneWidget);
    expect(find.bySemanticsLabel(RegExp('Seleccionado')), findsOneWidget);
  });

  testWidgets('elegir Japón cambia el idioma de la interfaz y se guarda', (tester) async {
    await pumpSettings(tester, prefs: {AppRegionNotifier.storageKey: 'MX'});

    await tester.tap(find.byKey(const Key('region-card-JP')));
    await tester.pumpAndSettle();

    expect(find.text('設定'), findsOneWidget);            // título
    expect(find.text('地域と言語'), findsOneWidget);      // sección
    expect(find.text('Configuración'), findsNothing);
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString(AppRegionNotifier.storageKey), 'JP');
    await tester.pump(const Duration(seconds: 3)); // SnackBar
  });

  testWidgets('elegir Corea cambia los textos a coreano', (tester) async {
    await pumpSettings(tester, prefs: {AppRegionNotifier.storageKey: 'MX'});
    await tester.tap(find.byKey(const Key('region-card-KR')));
    await tester.pumpAndSettle();
    expect(find.text('지역 및 언어'), findsOneWidget);
    await tester.pump(const Duration(seconds: 3));
  });

  testWidgets('elegir Egipto activa árabe con dirección RTL', (tester) async {
    await pumpSettings(tester, prefs: {AppRegionNotifier.storageKey: 'MX'});

    await tester.tap(find.byKey(const Key('region-card-EG')));
    await tester.pumpAndSettle();

    expect(find.text('الإعدادات'), findsOneWidget);
    final context = tester.element(find.byType(SettingsScreen));
    expect(Directionality.of(context), TextDirection.rtl);
    await tester.pump(const Duration(seconds: 3));
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
