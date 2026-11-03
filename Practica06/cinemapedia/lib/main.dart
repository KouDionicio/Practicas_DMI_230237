import 'package:flutter/material.dart';
import 'package:cinemapedia/config/router/app_router.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:cinemapedia/config/theme/app_theme.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cinemapedia/config/settings/country_config.dart';
import 'package:cinemapedia/presentation/providers/settings/country_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');
  final preferences = await SharedPreferences.getInstance();
  final initialCountry = CountryConfig.byCode(
    preferences.getString('selected_country') ?? 'MX',
  );

  runApp(
    ProviderScope(
      overrides: [
        selectedCountryProvider.overrideWith(
          (ref) => CountryNotifier(initialCountry: initialCountry),
        ),
      ],
      child: const MainApp(),
    ),
  );
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      routerConfig: appRouter,
      debugShowCheckedModeBanner: false,
      theme: AppTheme().getTheme(),
    );
  }
}
