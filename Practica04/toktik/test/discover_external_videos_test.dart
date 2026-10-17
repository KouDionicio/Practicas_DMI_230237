import 'package:flutter_test/flutter_test.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/domain/repositories/discover_repository.dart';
import 'package:toktik/domain/repositories/external_video_repository.dart';
import 'package:toktik/domain/repositories/favorites_repository.dart';
import 'package:toktik/domain/repositories/for_you_repository.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  test(
    'Discover includes external results and retains provider failures',
    () async {
      final provider = DiscoverProvider(
        discoverRepository: _EmptyFeed(),
        forYouRepository: _EmptyFeed(),
        favoritesRepository: _EmptyFeed(),
        externalVideoRepository: _ExternalFeeds(),
      );

      await provider.load(FeedSection.discover);

      expect(provider.externalVideosFor(FeedSection.discover), hasLength(1));
      expect(
        provider.externalVideosFor(FeedSection.discover).first.source,
        VideoSource.youtube,
      );
      expect(provider.externalErrors.keys, contains(VideoSource.vimeo));
      provider.dispose();
    },
  );
}

class _EmptyFeed
    implements DiscoverRepository, ForYouRepository, FavoritesRepository {
  @override
  Future<List<VideoPost>> getVideosByPage(int page) async => const [];

  @override
  Future<List<VideoPost>> getVideosByUserId(String userId) async => const [];
}

class _ExternalFeeds implements ExternalVideoRepository {
  @override
  Future<List<ExternalVideo>> search(VideoSource source, String query) async {
    if (source == VideoSource.vimeo) throw StateError('VIMEO_TOKEN missing');
    if (source == VideoSource.peertube) return const [];
    return [
      ExternalVideo(
        id: 'youtube:abc123',
        source: VideoSource.youtube,
        title: 'Configured YouTube result',
        description: '',
        thumbnailUrl: '',
        watchUrl: Uri.https('youtube.com', '/watch', {'v': 'abc123'}),
        embedUrl: Uri.https('www.youtube.com', '/embed/abc123'),
      ),
    ];
  }
}
