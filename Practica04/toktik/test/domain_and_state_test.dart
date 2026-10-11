import 'package:flutter_test/flutter_test.dart';
import 'package:toktik/domain/repositories/app_preferences_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/infrastructure/models/dailymotion_video_model.dart';
import 'package:toktik/infrastructure/models/local_video_model.dart';
import 'package:toktik/infrastructure/models/vimeo_video_model.dart';
import 'package:toktik/infrastructure/models/youtube_video_model.dart';
import 'package:toktik/infrastructure/repositories/shared_preferences_repository.dart';
import 'package:toktik/presentation/providers/likes_provider.dart';
import 'package:toktik/presentation/providers/season_provider.dart';

class _MemoryPreferencesRepository implements AppPreferencesRepository {
  String? mode;
  String? season;
  Set<String> likedIds = {};

  @override
  Future<String?> getSeasonMode() async => mode;

  @override
  Future<String?> getManualSeason() async => season;

  @override
  Future<void> saveSeasonMode(String value) async {
    mode = value;
  }

  @override
  Future<void> saveManualSeason(String value) async {
    season = value;
  }

  @override
  Future<Set<String>> getLikedVideoIds() async => Set.of(likedIds);

  @override
  Future<void> saveLikedVideoIds(Set<String> ids) async {
    likedIds = Set.of(ids);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'shared preferences repository persists app settings and likes',
    () async {
      SharedPreferences.setMockInitialValues({});
      final repository = SharedPreferencesRepository();

      await repository.saveSeasonMode(SeasonMode.manual.name);
      await repository.saveManualSeason(Season.christmas.name);
      await repository.saveLikedVideoIds({'local:one', 'local:two'});

      expect(await repository.getSeasonMode(), SeasonMode.manual.name);
      expect(await repository.getManualSeason(), Season.christmas.name);
      expect(await repository.getLikedVideoIds(), {'local:one', 'local:two'});
    },
  );

  group('automatic seasonal selection', () {
    test('includes the first and last days of Halloween', () {
      expect(SeasonDetails.forDate(DateTime(2026, 10, 1)), Season.halloween);
      expect(SeasonDetails.forDate(DateTime(2026, 10, 31)), Season.halloween);
      expect(SeasonDetails.forDate(DateTime(2026, 9, 30)), Season.normal);
      expect(SeasonDetails.forDate(DateTime(2026, 11, 1)), Season.normal);
    });

    test('covers Christmas across the year boundary', () {
      expect(SeasonDetails.forDate(DateTime(2026, 12, 1)), Season.christmas);
      expect(SeasonDetails.forDate(DateTime(2026, 12, 31)), Season.christmas);
      expect(SeasonDetails.forDate(DateTime(2027, 1, 1)), Season.christmas);
      expect(SeasonDetails.forDate(DateTime(2027, 1, 6)), Season.christmas);
      expect(SeasonDetails.forDate(DateTime(2027, 1, 7)), Season.normal);
    });

    test('includes only February 1 through 14 for Valentine season', () {
      expect(SeasonDetails.forDate(DateTime(2026, 2, 1)), Season.valentines);
      expect(SeasonDetails.forDate(DateTime(2026, 2, 14)), Season.valentines);
      expect(SeasonDetails.forDate(DateTime(2026, 2, 15)), Season.normal);
    });
  });

  group('season preferences', () {
    test(
      'defaults to automatic and recalculates from the supplied date',
      () async {
        var currentDate = DateTime(2026, 10, 10);
        final preferences = _MemoryPreferencesRepository();
        final provider = SeasonProvider(preferences, now: () => currentDate);

        await provider.load();
        expect(provider.mode, SeasonMode.automatic);
        expect(provider.season, Season.halloween);

        currentDate = DateTime(2026, 11, 1);
        expect(provider.season, Season.normal);
        provider.dispose();
      },
    );

    test('persists manual mode and selected season', () async {
      final preferences = _MemoryPreferencesRepository();
      final provider = SeasonProvider(
        preferences,
        now: () => DateTime(2026, 10, 15),
      );
      await provider.load();
      await provider.setManualSeason(Season.valentines);
      await provider.setMode(SeasonMode.manual);
      expect(provider.season, Season.valentines);

      final restored = SeasonProvider(preferences);
      await restored.load();
      expect(restored.mode, SeasonMode.manual);
      expect(restored.manualSeason, Season.valentines);
      expect(restored.season, Season.valentines);
      provider.dispose();
      restored.dispose();
    });
  });

  group('persistent likes', () {
    const video = VideoPost(
      id: 'local:one',
      caption: 'Clip',
      videoUrl: 'assets/videos/1.mp4',
      description: '',
      likes: 12,
    );

    test(
      'restores stable liked IDs and can unlike without a negative count',
      () async {
        final preferences = _MemoryPreferencesRepository();
        final provider = LikesProvider(preferences);
        await provider.load();
        await provider.toggleLike(video);
        expect(provider.isLiked(video), isTrue);
        expect(preferences.likedIds, {'local:one'});

        final restored = LikesProvider(preferences);
        await restored.load();
        expect(restored.isLiked(video), isTrue);
        await restored.toggleLike(video);
        expect(restored.isLiked(video), isFalse);
        expect(preferences.likedIds, isEmpty);
      },
    );

    test('serializes rapid repeated taps to the final toggled state', () async {
      final preferences = _MemoryPreferencesRepository();
      final provider = LikesProvider(preferences);
      await provider.load();
      await Future.wait([
        provider.toggleLike(video),
        provider.toggleLike(video),
      ]);
      expect(provider.isLiked(video), isFalse);
      expect(preferences.likedIds, isEmpty);
    });
  });

  group('video model mappers', () {
    test('maps a local asset to a stable domain ID', () {
      final video = LocalVideoModel.fromJson({
        'name': 'Local',
        'videoUrl': 'assets/videos/1.mp4',
        'likes': 8,
      }).toVideoPostEntity();
      expect(video.id, 'assets/videos/1.mp4');
      expect(video.likes, 8);
    });

    test('maps YouTube search metadata to its required embed URL', () {
      final video = YouTubeVideoModel.fromJson({
        'id': {'videoId': 'abc123'},
        'snippet': {
          'title': 'YouTube clip',
          'description': 'Description',
          'thumbnails': {
            'high': {'url': 'https://img.example/high.jpg'},
          },
        },
      }).toEntity();
      expect(video.source, VideoSource.youtube);
      expect(video.id, 'youtube:abc123');
      expect(video.embedUrl.host, 'www.youtube.com');
      expect(video.embedUrl.path, '/embed/abc123');
    });

    test('maps Vimeo metadata to the Vimeo player URL', () {
      final video = VimeoVideoModel.fromJson({
        'uri': '/videos/42',
        'name': 'Vimeo clip',
        'pictures': {
          'sizes': [
            {'link': 'https://img.example/vimeo.jpg'},
          ],
        },
      }).toEntity();
      expect(video.source, VideoSource.vimeo);
      expect(video.id, 'vimeo:42');
      expect(video.embedUrl.host, 'player.vimeo.com');
      expect(video.embedUrl.path, '/video/42');
    });

    test('maps Dailymotion metadata to its official embed URL', () {
      final video = DailymotionVideoModel.fromJson({
        'id': 'xyz123',
        'title': 'Dailymotion clip',
        'thumbnail_720_url': 'https://img.example/dailymotion.jpg',
      }).toEntity();
      expect(video.source, VideoSource.dailymotion);
      expect(video.id, 'dailymotion:xyz123');
      expect(video.embedUrl.host, 'www.dailymotion.com');
      expect(video.embedUrl.path, '/embed/video/xyz123');
    });
  });
}
