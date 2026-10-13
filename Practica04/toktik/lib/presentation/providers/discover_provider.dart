import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/domain/repositories/discover_repository.dart';
import 'package:toktik/domain/repositories/favorites_repository.dart';
import 'package:toktik/domain/repositories/for_you_repository.dart';

class DiscoverProvider extends ChangeNotifier {
  final Map<FeedSection, List<VideoPost>> _videos = {
    for (final section in FeedSection.values) section: <VideoPost>[],
  };
  final Set<FeedSection> _loading = {};
  final Map<FeedSection, Object> _errors = {};

  DiscoverProvider({
    required this.discoverRepository,
    required this.forYouRepository,
    required this.favoritesRepository,
  });

  final DiscoverRepository discoverRepository;
  final ForYouRepository forYouRepository;
  final FavoritesRepository favoritesRepository;

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
        FeedSection.discover => await discoverRepository.getVideosByPage(1),
        FeedSection.forYou => await forYouRepository.getVideosByPage(1),
        FeedSection.favorites => await favoritesRepository.getVideosByUserId(
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
