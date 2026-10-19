import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';
import 'package:provider/provider.dart';
import 'package:toktik/config/theme/app_theme.dart';
import 'package:toktik/domain/repositories/external_video_repository.dart';
import 'package:toktik/infrastructure/datasources/discover_video_datasource_impl.dart';
import 'package:toktik/infrastructure/datasources/favorites_video_datasource_impl.dart';
import 'package:toktik/infrastructure/datasources/for_you_video_datasource_impl.dart';
import 'package:toktik/infrastructure/datasources/local_video_posts_mapper.dart';
import 'package:toktik/infrastructure/datasources/peertube_video_datasource.dart';
import 'package:toktik/infrastructure/datasources/vimeo_video_datasource.dart';
import 'package:toktik/infrastructure/datasources/youtube_video_datasource.dart';
import 'package:toktik/infrastructure/repositories/discover_repository_impl.dart';
import 'package:toktik/infrastructure/repositories/external_video_repository_impl.dart';
import 'package:toktik/infrastructure/repositories/favorites_repository_impl.dart';
import 'package:toktik/infrastructure/repositories/for_you_repository_impl.dart';
import 'package:toktik/infrastructure/repositories/shared_preferences_repository.dart';
import 'package:toktik/infrastructure/services/android_launcher_icon_service.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';
import 'package:toktik/presentation/providers/external_video_search_provider.dart';
import 'package:toktik/presentation/providers/likes_provider.dart';
import 'package:toktik/presentation/providers/season_provider.dart';
import 'package:toktik/presentation/providers/seasonal_audio_provider.dart';
import 'package:toktik/presentation/services/seasonal_splash_audio.dart';
import 'package:toktik/presentation/screens/startup/toktik_splash_screen.dart';

Uri? _resolveConfiguredUrl(String? value) {
  final configured = value?.trim() ?? '';
  if (configured.isEmpty) return null;
  return Uri.tryParse(configured) ?? Uri();
}

Future<void> main() async {
  final binding = WidgetsFlutterBinding.ensureInitialized();
  FlutterNativeSplash.preserve(widgetsBinding: binding);

  var environmentFileLoadFailed = false;
  try {
    await dotenv.load(isOptional: true);
  } catch (_) {
    environmentFileLoadFailed = true;
    debugPrint(
      'No se pudo cargar .env; la búsqueda externa puede requerir '
      'configuración.',
    );
  }
  final environment = dotenv.isInitialized
      ? dotenv.env
      : const <String, String>{};

  final preferencesRepository = SharedPreferencesRepository();
  final launcherIconService = AndroidLauncherIconService();
  final seasonProvider = SeasonProvider(
    preferencesRepository,
    onSeasonChanged: launcherIconService.setSeason,
  );
  await seasonProvider.load();

  final startupAudio = SeasonalSplashAudio(seasonProvider.season);
  await startupAudio.preload();

  runApp(
    MyApp(
      preferencesRepository: preferencesRepository,
      seasonProvider: seasonProvider,
      startupAudio: startupAudio,
      youtubeApiKey: environment['YOUTUBE_API_KEY'],
      vimeoToken: environment['VIMEO_TOKEN'],
      backendBaseUrl: _resolveConfiguredUrl(environment['BACKEND_BASE_URL']),
      peerTubeBaseUrl: _resolveConfiguredUrl(environment['PEERTUBE_BASE_URL']),
      environmentFileLoadFailed: environmentFileLoadFailed,
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({
    super.key,
    required this.preferencesRepository,
    required this.seasonProvider,
    required this.startupAudio,
    required this.youtubeApiKey,
    required this.vimeoToken,
    required this.backendBaseUrl,
    required this.peerTubeBaseUrl,
    required this.environmentFileLoadFailed,
  });

  final SharedPreferencesRepository preferencesRepository;
  final SeasonProvider seasonProvider;
  final SeasonalSplashAudio startupAudio;
  final String? youtubeApiKey;
  final String? vimeoToken;
  final Uri? backendBaseUrl;
  final Uri? peerTubeBaseUrl;
  final bool environmentFileLoadFailed;

  @override
  Widget build(BuildContext context) {
    final discoverRepository = DiscoverRepositoryImpl(
      datasource: LocalDiscoverVideoDatasource(),
    );
    final forYouRepository = ForYouRepositoryImpl(
      datasource: LocalForYouVideoDatasource(),
    );
    final favoritesRepository = FavoritesRepositoryImpl(
      datasource: LocalFavoritesVideoDatasource(
        loadFavoriteIds: preferencesRepository.getLikedVideoIds,
      ),
    );

    return MultiProvider(
      providers: [
        Provider<SharedPreferencesRepository>.value(value: preferencesRepository),
        ChangeNotifierProvider.value(value: seasonProvider),
        ChangeNotifierProvider(
          create: (_) => LikesProvider(
            preferencesRepository,
            validVideoIds: mapLocalVideoPosts()
                .map((video) => video.id)
                .toSet(),
          )..load(),
        ),
        ChangeNotifierProxyProvider<SeasonProvider, SeasonalAudioProvider>(
          create: (context) =>
              SeasonalAudioProvider(context.read<SeasonProvider>().season),
          update: (_, season, audio) {
            final provider = audio ?? SeasonalAudioProvider(season.season);
            unawaited(provider.setSeason(season.season));
            return provider;
          },
        ),
        Provider<ExternalVideoRepository>(
          create: (_) => ExternalVideoRepositoryImpl(
            youtubeDatasource: YouTubeVideoDatasource(apiKey: youtubeApiKey),
            vimeoDatasource: VimeoVideoDatasource(
              baseUrl: backendBaseUrl,
              token: vimeoToken,
            ),
            peerTubeDatasource: PeerTubeVideoDatasource(
              baseUrl: peerTubeBaseUrl,
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ExternalVideoSearchProvider(
            context.read<ExternalVideoRepository>(),
            environmentFileLoadFailed: environmentFileLoadFailed,
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => DiscoverProvider(
            discoverRepository: discoverRepository,
            forYouRepository: forYouRepository,
            favoritesRepository: favoritesRepository,
            externalVideoRepository: context.read<ExternalVideoRepository>(),
            preferencesRepository: preferencesRepository,
          )..loadNextPage(),
        ),
      ],
      child: Consumer<SeasonProvider>(
        builder: (context, season, _) => MaterialApp(
          title: 'TokTik',
          debugShowCheckedModeBanner: false,
          theme: AppTheme().getTheme(season.season),
          home: TokTikSplashScreen(startupAudio: startupAudio),
        ),
      ),
    );
  }
}
