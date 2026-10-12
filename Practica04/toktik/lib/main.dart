import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/config/theme/app_theme.dart';
import 'package:toktik/domain/repositories/external_video_repository.dart';
import 'package:toktik/infrastructure/datasources/local_video_datasources_impl.dart';
import 'package:toktik/infrastructure/datasources/dailymotion_video_datasource.dart';
import 'package:toktik/infrastructure/repositories/external_video_repository_impl.dart';
import 'package:toktik/infrastructure/repositories/shared_preferences_repository.dart';
import 'package:toktik/infrastructure/repositories/video_post_repository_impl.dart';
import 'package:toktik/infrastructure/datasources/vimeo_video_datasource.dart';
import 'package:toktik/infrastructure/datasources/youtube_video_datasource.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';
import 'package:toktik/presentation/providers/external_video_search_provider.dart';
import 'package:toktik/presentation/providers/likes_provider.dart';
import 'package:toktik/presentation/providers/season_provider.dart';
import 'package:toktik/presentation/providers/seasonal_audio_provider.dart';
import 'package:toktik/presentation/screens/discover/discover_screen.dart';

const _youtubeApiKey = String.fromEnvironment('YOUTUBE_API_KEY');
const _dailymotionApiKey = String.fromEnvironment('DAILYMOTION_API_KEY');
const _dailymotionPlayerId = String.fromEnvironment('DAILYMOTION_PLAYER_ID');
const _vimeoBackendUrl = String.fromEnvironment('VIMEO_BACKEND_URL');

Uri? _resolveVimeoBackendUrl() {
  final configured = _vimeoBackendUrl.trim();
  if (configured.isNotEmpty) return Uri.tryParse(configured);
  if (kIsWeb) return Uri.parse('http://localhost:8787');
  return switch (defaultTargetPlatform) {
    TargetPlatform.android => Uri.parse('http://10.0.2.2:8787'),
    TargetPlatform.iOS ||
    TargetPlatform.macOS ||
    TargetPlatform.windows ||
    TargetPlatform.linux => Uri.parse('http://localhost:8787'),
    TargetPlatform.fuchsia => null,
  };
}

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final preferencesRepository = SharedPreferencesRepository();
    final videoPostsRepository = VideoPostsRepositoryImpl(
      videosDatasource: LocalVideoDatasource(
        loadFavoriteIds: preferencesRepository.getLikedVideoIds,
      ),
    );

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => SeasonProvider(preferencesRepository)..load(),
        ),
        ChangeNotifierProvider(
          create: (_) => LikesProvider(preferencesRepository)..load(),
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
            youtubeDatasource: YouTubeVideoDatasource(apiKey: _youtubeApiKey),
            vimeoDatasource: VimeoVideoDatasource(
              baseUrl: _resolveVimeoBackendUrl(),
            ),
            dailymotionDatasource: DailymotionVideoDatasource(
              apiKey: _dailymotionApiKey,
              playerId: _dailymotionPlayerId,
            ),
          ),
        ),
        ChangeNotifierProvider(
          create: (context) => ExternalVideoSearchProvider(
            context.read<ExternalVideoRepository>(),
          ),
        ),
        ChangeNotifierProvider(
          create: (_) =>
              DiscoverProvider(videosRepository: videoPostsRepository)
                ..loadNextPage(),
        ),
      ],
      child: Consumer<SeasonProvider>(
        builder: (context, season, _) => MaterialApp(
          title: 'TokTik',
          debugShowCheckedModeBanner: false,
          theme: AppTheme().getTheme(season.season),
          home: const DiscoverScreen(),
        ),
      ),
    );
  }
}
