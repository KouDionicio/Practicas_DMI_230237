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
import 'package:toktik/presentation/screens/startup/toktik_splash_screen.dart';
import 'package:toktik/presentation/services/seasonal_splash_audio.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('plays the branded splash before opening Discover', (
    tester,
  ) async {
    final preferences = _MemoryPreferencesRepository();
    final seasonProvider = SeasonProvider(preferences);
    final likesProvider = LikesProvider(preferences);
    final startupAudio = _FakeStartupAudio();
    final discoverProvider = DiscoverProvider(
      discoverRepository: _EmptyFeeds(),
      forYouRepository: _EmptyFeeds(),
      favoritesRepository: _EmptyFeeds(),
    );
    await Future.wait([
      seasonProvider.load(),
      likesProvider.load(),
      discoverProvider.loadNextPage(),
    ]);

    await tester.pumpWidget(
      MultiProvider(
        providers: [
          ChangeNotifierProvider.value(value: seasonProvider),
          ChangeNotifierProvider.value(value: likesProvider),
          ChangeNotifierProvider.value(value: discoverProvider),
        ],
        child: MaterialApp(
          home: TokTikSplashScreen(
            startupAudio: startupAudio,
            splashDuration: const Duration(milliseconds: 20),
            removeNativeSplash: () {},
            destinationBuilder: (_) => const Text('Discover'),
          ),
        ),
      ),
    );
    await tester.pump();
    await seasonProvider.setMode(SeasonMode.manual);
    await seasonProvider.setManualSeason(Season.christmas);
    await tester.pump();

    expect(startupAudio.season, Season.christmas);
    expect(
      find.byWidgetPredicate(
        (widget) =>
            widget is Image &&
            widget.image is AssetImage &&
            (widget.image as AssetImage).assetName ==
                Season.christmas.splashLogoAsset,
      ),
      findsOneWidget,
    );
    await tester.runAsync(
      () => Future<void>.delayed(const Duration(milliseconds: 50)),
    );
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 500));
    await tester.pump();

    expect(find.text('Discover'), findsOneWidget);
    expect(startupAudio.requestedDuration, const Duration(milliseconds: 20));
    expect(startupAudio.isDisposed, isTrue);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox.shrink());
    seasonProvider.dispose();
    likesProvider.dispose();
    discoverProvider.dispose();
  });
}

class _FakeStartupAudio implements StartupAudio {
  Duration? requestedDuration;
  Season? season;
  bool isDisposed = false;

  @override
  Object? get error => null;

  @override
  Future<void> setSeason(Season value) async {
    season = value;
  }

  @override
  Future<void> preload() async {}

  @override
  Future<void> playFor(Duration duration) async {
    requestedDuration = duration;
    await Future<void>.delayed(duration);
  }

  @override
  Future<void> dispose() async {
    isDisposed = true;
  }
}

class _MemoryPreferencesRepository implements AppPreferencesRepository {
  String? mode;
  String? season;

  @override
  Future<String?> getManualSeason() async => season;

  @override
  Future<String?> getSeasonMode() async => mode;

  @override
  Future<Set<String>> getLikedVideoIds() async => {};

  @override
  Future<void> saveManualSeason(String value) async {
    season = value;
  }

  @override
  Future<void> saveSeasonMode(String value) async {
    mode = value;
  }

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
}

class _EmptyFeeds
    implements DiscoverRepository, ForYouRepository, FavoritesRepository {
  @override
  Future<List<VideoPost>> getVideosByPage(int page) async => [];

  @override
  Future<List<VideoPost>> getVideosByUserId(String userId) async => [];
}
