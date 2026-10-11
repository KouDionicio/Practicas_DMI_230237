import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/domain/repositories/video_posts_repository.dart';

class DiscoverProvider extends ChangeNotifier {
  final VideoPostsRepository videosRepository;

  final Map<FeedSection, List<VideoPost>> _videos = {
    for (final section in FeedSection.values) section: <VideoPost>[],
  };
  final Set<FeedSection> _loading = {};
  final Map<FeedSection, Object> _errors = {};

  DiscoverProvider({required this.videosRepository});

  List<VideoPost> videosFor(FeedSection section) =>
      List.unmodifiable(_videos[section]!);

  bool isLoading(FeedSection section) => _loading.contains(section);

  Object? errorFor(FeedSection section) => _errors[section];

  Future<void> load(FeedSection section) async {
    if (_loading.contains(section)) return;
    _loading.add(section);
    _errors.remove(section);
    notifyListeners();
    try {
      final List<VideoPost> posts = switch (section) {
        FeedSection.discover => await videosRepository.getTrendingVideosByPage(
          1,
        ),
        FeedSection.forYou => await videosRepository.getForYouVideosByPage(1),
        FeedSection.favorites => await videosRepository.getFavoriteVideosByUser(
          'local',
        ),
      };
      _videos[section] = posts;
    } catch (exception) {
      _errors[section] = exception;
    } finally {
      _loading.remove(section);
      notifyListeners();
    }
  }

  Future<void> loadNextPage() async {
    await Future.wait(FeedSection.values.map(load));
  }
}

enum FeedSection { discover, forYou, favorites }
