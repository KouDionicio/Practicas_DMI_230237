import 'package:flutter_test/flutter_test.dart';
import 'package:toktik/domain/repositories/app_preferences_repository.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/domain/entities/season.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/infrastructure/models/local_video_model.dart';
import 'package:toktik/infrastructure/models/peertube_video_model.dart';
import 'package:toktik/infrastructure/models/vimeo_video_model.dart';
import 'package:toktik/infrastructure/datasources/local_video_posts_mapper.dart';
import 'package:toktik/infrastructure/models/youtube_video_model.dart';
import 'package:toktik/infrastructure/repositories/shared_preferences_repository.dart';
import 'package:toktik/presentation/providers/likes_provider.dart';
import 'package:toktik/presentation/providers/season_provider.dart';

class _MemoryPreferencesRepository implements AppPreferencesRepository {
  String? mode;
  String? season;
  Set<String> likedIds = {};
  Map<String, int> likeCounts = {};
  Map<String, Map<String, Object?>> externalVideos = {};

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

  @override
  Future<Map<String, int>> getVideoLikeCounts() async => Map.of(likeCounts);

  @override
  Future<void> saveVideoLikeCounts(Map<String, int> counts) async {
    likeCounts = Map.of(counts);
  }

  @override
  Future<Map<String, Map<String, Object?>>> getLikedExternalVideos() async =>
      Map.from(externalVideos);

  @override
  Future<void> saveLikedExternalVideos(
    Map<String, Map<String, Object?>> videos,
  ) async {
    externalVideos = Map.from(videos);
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
      await repository.saveVideoLikeCounts({'local:one': 13, 'local:two': 24});
      final savedExternal = ExternalVideo(
        id: 'vimeo:42',
        source: VideoSource.vimeo,
        title: 'Vimeo clip',
        description: 'Saved description',
        thumbnailUrl: 'https://i.vimeocdn.com/video/42.jpg',
        watchUrl: Uri.https('vimeo.com', '/42'),
        embedUrl: Uri.https('player.vimeo.com', '/video/42'),
      );
      await repository.saveLikedExternalVideos({
        savedExternal.id: savedExternal.toJson(),
      });

      expect(await repository.getSeasonMode(), SeasonMode.manual.name);
      expect(await repository.getManualSeason(), Season.christmas.name);
      expect(await repository.getLikedVideoIds(), {'local:one', 'local:two'});
      expect(await repository.getVideoLikeCounts(), {
        'local:one': 13,
        'local:two': 24,
      });
      expect(
        ExternalVideo.fromJson(
          (await repository.getLikedExternalVideos()).values.single,
        ).id,
        savedExternal.id,
      );
    },
  );

  group('automatic seasonal selection', () {
    test('includes the first and last days of Halloween', () {
      expect(SeasonCalendar.forDate(DateTime(2026, 10, 1)), Season.halloween);
      expect(SeasonCalendar.forDate(DateTime(2026, 10, 31)), Season.halloween);
      expect(SeasonCalendar.forDate(DateTime(2026, 9, 30)), Season.normal);
      expect(SeasonCalendar.forDate(DateTime(2026, 11, 1)), Season.normal);
    });

    test('covers Christmas across the year boundary', () {
      expect(SeasonCalendar.forDate(DateTime(2026, 12, 1)), Season.christmas);
      expect(SeasonCalendar.forDate(DateTime(2026, 12, 31)), Season.christmas);
      expect(SeasonCalendar.forDate(DateTime(2027, 1, 1)), Season.christmas);
      expect(SeasonCalendar.forDate(DateTime(2027, 1, 6)), Season.christmas);
      expect(SeasonCalendar.forDate(DateTime(2027, 1, 7)), Season.normal);
    });

    test('includes only February 1 through 14 for Valentine season', () {
      expect(SeasonCalendar.forDate(DateTime(2026, 2, 1)), Season.valentines);
      expect(SeasonCalendar.forDate(DateTime(2026, 2, 14)), Season.valentines);
      expect(SeasonCalendar.forDate(DateTime(2026, 2, 15)), Season.normal);
    });
  });

  group('seasonal branding assets', () {
    test('maps each season to its splash logo and launcher alias', () {
      const expected = {
        Season.normal: (
          'assets/icons/normal.png',
          'MainActivityNormal',
          'ic_launcher_normal',
        ),
        Season.halloween: (
          'assets/icons/halloween.png',
          'MainActivityHalloween',
          'ic_launcher_halloween',
        ),
        Season.christmas: (
          'assets/icons/navidad.png',
          'MainActivityChristmas',
          'ic_launcher_christmas',
        ),
        Season.valentines: (
          'assets/icons/san_valentin.png',
          'MainActivityValentines',
          'ic_launcher_valentines',
        ),
      };

      for (final season in Season.values) {
        expect(season.splashLogoAsset, expected[season]!.$1);
        expect(season.launcherAlias, expected[season]!.$2);
        expect(season.launcherIconResource, expected[season]!.$3);
      }
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

    test('synchronizes launcher alias on load and every manual confirmation', () async {
      final preferences = _MemoryPreferencesRepository()
        ..mode = SeasonMode.manual.name
        ..season = Season.normal.name;
      final launcherUpdates = <Season>[];
      final provider = SeasonProvider(
        preferences,
        onSeasonChanged: (season) async => launcherUpdates.add(season),
      );

      await provider.load();
      await provider.setManualSeason(Season.halloween);
      // Re-selecting the same season must repair a stale package-manager state.
      await provider.setManualSeason(Season.halloween);
      await provider.setManualSeason(Season.christmas);

      expect(launcherUpdates, [
        Season.normal,
        Season.halloween,
        Season.halloween,
        Season.christmas,
      ]);
      provider.dispose();
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
        expect(provider.likeCount(video), 13);
        expect(preferences.likedIds, {'local:one'});
        expect(preferences.likeCounts, {'local:one': 13});

        final restored = LikesProvider(preferences);
        await restored.load();
        expect(restored.isLiked(video), isTrue);
        expect(restored.likeCount(video), 13);
        await restored.toggleLike(video);
        expect(restored.isLiked(video), isFalse);
        expect(restored.likeCount(video), 12);
        expect(preferences.likedIds, isEmpty);
        expect(preferences.likeCounts, {'local:one': 12});
      },
    );

    test(
      'persists and restores external favorites with source-qualified IDs',
      () async {
        final external = ExternalVideo(
          id: 'youtube:abc123',
          source: VideoSource.youtube,
          title: 'YouTube clip',
          description: 'description',
          thumbnailUrl: 'https://i.ytimg.com/vi/abc123/default.jpg',
          watchUrl: Uri(
            scheme: 'https',
            host: 'www.youtube.com',
            path: '/watch',
            query: 'v=abc123',
          ),
          embedUrl: Uri(
            scheme: 'https',
            host: 'www.youtube.com',
            path: '/embed/abc123',
          ),
        );
        final preferences = _MemoryPreferencesRepository();
        final provider = LikesProvider(preferences);
        await provider.load();
        await provider.toggleExternalLike(external);
        expect(provider.likedVideoIds, {'youtube:abc123'});
        expect(provider.likedExternalVideos.single.id, 'youtube:abc123');

        final restored = LikesProvider(preferences);
        await restored.load();
        expect(restored.likedExternalVideos.single.title, 'YouTube clip');
        await restored.toggleExternalLike(external);
        expect(restored.likedExternalVideos, isEmpty);
        expect(preferences.likedIds, isEmpty);
        expect(preferences.externalVideos, isEmpty);
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
      expect(provider.likeCount(video), 12);
      expect(preferences.likedIds, isEmpty);
    });

    test(
      'prunes saved likes and counts for videos no longer available',
      () async {
        final preferences = _MemoryPreferencesRepository()
          ..likedIds = {'assets/videos/1.mp4', 'removed-video-id'}
          ..likeCounts = {'assets/videos/1.mp4': 18, 'removed-video-id': 21};
        final provider = LikesProvider(
          preferences,
          validVideoIds: {'assets/videos/1.mp4', 'assets/videos/3.mp4'},
        );

        await provider.load();

        expect(provider.likedVideoIds, {'assets/videos/1.mp4'});
        expect(provider.videoLikeCounts, {'assets/videos/1.mp4': 18});
        expect(preferences.likedIds, {'assets/videos/1.mp4'});
        expect(preferences.likeCounts, {'assets/videos/1.mp4': 18});
        expect(provider.error, isNull);
      },
    );
  });

  group('video model mappers', () {
    test('local feeds contain only the nine remaining bundled videos', () {
      final videos = mapLocalVideoPosts();
      expect(videos, hasLength(9));
    });

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
            'high': {'url': 'https://i.ytimg.com/high.jpg'},
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
            {'link': 'https://i.vimeocdn.com/vimeo.jpg'},
          ],
        },
      }).toEntity();
      expect(video.source, VideoSource.vimeo);
      expect(video.id, 'vimeo:42');
      expect(video.embedUrl.host, 'player.vimeo.com');
      expect(video.embedUrl.path, '/video/42');
    });

    test('maps PeerTube metadata to instance watch and embed URLs', () {
      const uuid = 'a1b2c3d4-0000-4000-8000-000000000001';
      final video = PeerTubeVideoModel.fromJson(
        {
          'uuid': uuid,
          'shortUUID': 'sWxgbBUu1ScQkHqz831Qqi',
          'name': 'PeerTube clip',
          'thumbnailPath': '/lazy-static/thumbnails/peertube.jpg',
          'embedPath': '/videos/embed/$uuid',
          'url': 'https://peertube.cpy.re/w/sWxgbBUu1ScQkHqz831Qqi',
          'duration': 125,
        },
        instanceUrl: Uri.https('peertube.cpy.re'),
      ).toEntity(instanceUrl: Uri.https('peertube.cpy.re'));
      expect(video.source, VideoSource.peertube);
      expect(video.id, 'peertube:$uuid');
      expect(video.watchUrl.path, '/w/sWxgbBUu1ScQkHqz831Qqi');
      expect(video.embedUrl.path, '/videos/embed/$uuid');
      expect(video.thumbnailUrl, contains('peertube.cpy.re'));
      expect(video.durationSeconds, 125);
    });

    test('rejects malformed external video identifiers', () {
      expect(
        () => YouTubeVideoModel.fromJson({
          'id': {'videoId': '../not-a-video'},
          'snippet': {},
        }),
        throwsFormatException,
      );
      expect(
        () => VimeoVideoModel.fromJson({'uri': '/videos/42/extra'}),
        throwsFormatException,
      );
      expect(
        () => PeerTubeVideoModel.fromJson({
          'uuid': '../not-a-video',
        }, instanceUrl: Uri.https('peertube.cpy.re')),
        throwsFormatException,
      );
    });

    test('ignores thumbnails outside the provider HTTPS CDN', () {
      final youtube = YouTubeVideoModel.fromJson({
        'id': {'videoId': 'abc123'},
        'snippet': {
          'thumbnails': {
            'high': {'url': 'https://attacker.example/image.jpg'},
          },
        },
      }).toEntity();
      final vimeo = VimeoVideoModel.fromJson({
        'uri': '/videos/42',
        'pictures': {
          'sizes': [
            {'link': 'https://attacker.example/image.jpg'},
          ],
        },
      }).toEntity();
      final peerTube = PeerTubeVideoModel.fromJson(
        {
          'uuid': 'a1b2c3d4-0000-4000-8000-000000000001',
          'thumbnailPath': 'https://attacker.example/image.jpg',
        },
        instanceUrl: Uri.https('peertube.cpy.re'),
      ).toEntity(instanceUrl: Uri.https('peertube.cpy.re'));

      expect(youtube.thumbnailUrl, isEmpty);
      expect(vimeo.thumbnailUrl, isEmpty);
      expect(peerTube.thumbnailUrl, isEmpty);
    });

    test('detects supported external providers from canonical URLs', () {
      expect(
        VideoSource.fromUrl('https://www.youtube.com/watch?v=abc123&t=42s'),
        VideoSource.youtube,
      );
      expect(
        VideoSource.fromUrl('https://youtu.be/abc123?si=sample'),
        VideoSource.youtube,
      );
      expect(
        VideoSource.fromUrl('https://vimeo.com/42?autoplay=1'),
        VideoSource.vimeo,
      );
      expect(
        VideoSource.fromUrl(
          'https://peertube.cpy.re/videos/watch/a1b2c3d4-0000-4000-8000-000000000001',
        ),
        VideoSource.peertube,
      );
      expect(VideoSource.fromUrl('https://example.com/video.mp4'), isNull);
      expect(VideoSource.fromUrl('assets/videos/1.mp4'), VideoSource.local);
    });
  });
}
