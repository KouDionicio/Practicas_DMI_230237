import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:toktik/domain/entities/season.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/domain/repositories/app_preferences_repository.dart';
import 'package:toktik/domain/repositories/discover_repository.dart';
import 'package:toktik/domain/repositories/favorites_repository.dart';
import 'package:toktik/domain/repositories/for_you_repository.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';
import 'package:toktik/presentation/providers/likes_provider.dart';
import 'package:toktik/presentation/providers/season_provider.dart';
import 'package:toktik/presentation/providers/seasonal_audio_provider.dart';
import 'package:toktik/presentation/screens/discover/discover_screen.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets(
    'narrow Discover header keeps navigation and options accessible',
    (tester) async {
      tester.view.physicalSize = const Size(182, 700);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      await tester.pumpWidget(
        MultiProvider(
          providers: [
            ChangeNotifierProvider(
              create: (_) => SeasonProvider(_FakePreferences()),
            ),
            ChangeNotifierProvider(
              create: (_) => LikesProvider(_FakePreferences()),
            ),
            ChangeNotifierProvider(
              create: (_) => SeasonalAudioProvider(Season.normal),
            ),
            ChangeNotifierProvider(
              create: (_) => DiscoverProvider(
                discoverRepository: _FakeFeeds(),
                forYouRepository: _FakeFeeds(),
                favoritesRepository: _FakeFeeds(),
              ),
            ),
          ],
          child: const MaterialApp(home: DiscoverScreen()),
        ),
      );
      await tester.pump();

      expect(tester.takeException(), isNull);
      expect(find.text('Discover'), findsOneWidget);
      expect(find.text('For You'), findsOneWidget);
      expect(find.text('Favorites'), findsOneWidget);
      expect(find.byTooltip('Configuración de temporada'), findsOneWidget);
      expect(find.byTooltip('Más opciones'), findsOneWidget);

      await tester.tap(find.byTooltip('Más opciones'));
      await tester.pumpAndSettle();

      expect(find.text('Buscar videos externos'), findsOneWidget);
      expect(find.text('Reproducir audio ambiental'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
}

class _FakePreferences implements AppPreferencesRepository {
  @override
  Future<Set<String>> getLikedVideoIds() async => {};

  @override
  Future<String?> getManualSeason() async => null;

  @override
  Future<String?> getSeasonMode() async => null;

  @override
  Future<void> saveLikedVideoIds(Set<String> ids) async {}

  @override
  Future<Map<String, int>> getVideoLikeCounts() async => {};

  @override
  Future<void> saveVideoLikeCounts(Map<String, int> counts) async {}

  @override
  Future<Map<String, Map<String, Object?>>> getLikedExternalVideos() async =>
      {};

  @override
  Future<void> saveLikedExternalVideos(
    Map<String, Map<String, Object?>> videos,
  ) async {}

  @override
  Future<void> saveManualSeason(String season) async {}

  @override
  Future<void> saveSeasonMode(String mode) async {}
}

class _FakeFeeds
    implements DiscoverRepository, ForYouRepository, FavoritesRepository {
  @override
  Future<List<VideoPost>> getVideosByPage(int page) async => [];

  @override
  Future<List<VideoPost>> getVideosByUserId(String userId) async => [];
}
