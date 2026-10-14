import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/domain/repositories/discover_repository.dart';
import 'package:toktik/domain/repositories/external_video_repository.dart';
import 'package:toktik/domain/repositories/favorites_repository.dart';
import 'package:toktik/domain/repositories/for_you_repository.dart';

class DiscoverProvider extends ChangeNotifier {
  static const externalSearchQuery = 'viral videos';
  static const externalVideosPerProvider = 3;
  static const _externalSources = [
    VideoSource.youtube,
    VideoSource.vimeo,
    VideoSource.peertube,
  ];

  final Map<FeedSection, List<VideoPost>> _videos = {
    for (final section in FeedSection.values) section: <VideoPost>[],
  };
  List<ExternalVideo> _discoverExternalVideos = const [];
  final Set<FeedSection> _loading = {};
  final Map<FeedSection, Object> _errors = {};

  DiscoverProvider({
    required this.discoverRepository,
    required this.forYouRepository,
    required this.favoritesRepository,
    this.externalVideoRepository,
  });

  final DiscoverRepository discoverRepository;
  final ForYouRepository forYouRepository;
  final FavoritesRepository favoritesRepository;
  final ExternalVideoRepository? externalVideoRepository;

  List<VideoPost> videosFor(FeedSection section) =>
      List.unmodifiable(_videos[section]!);

  List<ExternalVideo> externalVideosFor(FeedSection section) =>
      section == FeedSection.discover
      ? List.unmodifiable(_discoverExternalVideos)
      : const [];

  bool isLoading(FeedSection section) => _loading.contains(section);

  Object? errorFor(FeedSection section) => _errors[section];

  Future<void> load(FeedSection section) async {
    if (_loading.contains(section)) return;
    _loading.add(section);
    _errors.remove(section);
    notifyListeners();
    try {
      if (section == FeedSection.discover) {
        _videos[section] = await discoverRepository.getVideosByPage(1);
        notifyListeners();
        _discoverExternalVideos = await _loadExternalDiscoverVideos();
      } else {
        _videos[section] = switch (section) {
          FeedSection.discover => const [],
          FeedSection.forYou => await forYouRepository.getVideosByPage(1),
          FeedSection.favorites => await favoritesRepository
              .getVideosByUserId('local'),
        };
      }
    } catch (exception) {
      _errors[section] = exception;
    } finally {
      _loading.remove(section);
      notifyListeners();
    }
  }

  Future<List<ExternalVideo>> _loadExternalDiscoverVideos() async {
    final repository = externalVideoRepository;
    if (repository == null) return const [];
    final results = await Future.wait(
      _externalSources.map((source) async {
        try {
          final videos = await repository.search(source, externalSearchQuery);
          return videos
              .where((video) => video.source == source)
              .take(externalVideosPerProvider)
              .toList(growable: false);
        } catch (exception) {
          debugPrint(
            'Discover: ${source.name} is unavailable '
            '(${exception.runtimeType}).',
          );
          return const <ExternalVideo>[];
        }
      }),
    );
    return [
      for (var index = 0; index < externalVideosPerProvider; index++)
        for (final videos in results)
          if (index < videos.length) videos[index],
    ];
  }

  Future<void> loadNextPage() async {
    await Future.wait(FeedSection.values.map(load));
  }
}

enum FeedSection { discover, forYou, favorites }
