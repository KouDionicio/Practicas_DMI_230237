import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cinemapedia/config/helpers/l10n_helpers.dart';
import 'package:cinemapedia/config/router/app_router.dart';
import 'package:cinemapedia/config/theme/app_theme.dart';
import 'package:cinemapedia/l10n/app_localizations.dart';
import 'package:cinemapedia/presentation/providers/settings/app_region_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Ambas operaciones son locales y rápidas. Las preferencias se leen antes
  // del primer frame para que la app nunca muestre un idioma incorrecto.
  final results = await Future.wait([
    dotenv.load(fileName: '.env'),
    SharedPreferences.getInstance(),
  ]);

  runApp(
    ProviderScope(
      overrides: [
        sharedPreferencesProvider.overrideWithValue(results[1] as SharedPreferences),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends ConsumerWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final region = ref.watch(appRegionProvider);

    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      onGenerateTitle: (context) => 'Cinemapedia',
      theme: AppTheme(languageCode: region.languageCode).getTheme(),
      themeMode: ThemeMode.dark,
      // Idioma global: cambia toda la interfaz (incluidos los textos de
      // Material como "Atrás") y activa RTL automáticamente en árabe.
      locale: region.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localizationsDelegates: AppLocalizations.localizationsDelegates,
    );
  }
}
