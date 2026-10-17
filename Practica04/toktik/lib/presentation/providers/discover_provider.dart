import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/domain/entities/external_video_page.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/domain/repositories/discover_repository.dart';
import 'package:toktik/domain/repositories/external_video_repository.dart';
import 'package:toktik/domain/repositories/favorites_repository.dart';
import 'package:toktik/domain/repositories/for_you_repository.dart';

class DiscoverProvider extends ChangeNotifier {
  static const externalSearchQuery = 'viral videos';
  static const externalVideosPerProvider = 50;
  static const _externalSources = [
    VideoSource.youtube,
    VideoSource.vimeo,
    VideoSource.peertube,
  ];

  final Map<FeedSection, List<VideoPost>> _videos = {
    for (final section in FeedSection.values) section: <VideoPost>[],
  };
  List<ExternalVideo> _discoverExternalVideos = const [];
  final Map<VideoSource, Object> _externalErrors = {};
  final Map<VideoSource, String> _externalPageTokens = {};
  bool _externalLoadingMore = false;
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

  Map<VideoSource, Object> get externalErrors =>
      Map.unmodifiable(_externalErrors);
  bool get isLoadingMoreExternal => _externalLoadingMore;

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
          FeedSection.favorites => await favoritesRepository.getVideosByUserId(
            'local',
          ),
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
    _externalErrors.clear();
    _externalPageTokens.clear();
    final results = await Future.wait<ExternalVideoPage>(
      _externalSources.map((source) async {
        try {
          final page = await searchExternalVideoPage(
            repository,
            source,
            externalSearchQuery,
          );
          if (page.nextPageToken case final token?) {
            _externalPageTokens[source] = token;
          }
          return ExternalVideoPage(
            page.videos.where((video) => video.source == source).toList(),
            nextPageToken: page.nextPageToken,
          );
        } catch (exception) {
          _externalErrors[source] = exception;
          debugPrint(
            'Discover: ${source.name} is unavailable '
            '(${exception.runtimeType}).',
          );
          return const ExternalVideoPage([]);
        }
      }),
    );
    return [
      for (var index = 0; index < externalVideosPerProvider; index++)
        for (final page in results)
          if (index < page.videos.length) page.videos[index],
    ];
  }

  Future<void> loadMoreExternalVideos() async {
    final repository = externalVideoRepository;
    if (repository == null ||
        _externalLoadingMore ||
        _externalPageTokens.isEmpty) {
      return;
    }
    _externalLoadingMore = true;
    notifyListeners();
    try {
      final pages = await Future.wait(
        _externalPageTokens.entries.map((entry) async {
          final page = await searchExternalVideoPage(
            repository,
            entry.key,
            externalSearchQuery,
            pageToken: entry.value,
          );
          return MapEntry(entry.key, page);
        }),
      );
      final existingIds = _discoverExternalVideos
          .map((video) => video.id)
          .toSet();
      for (final result in pages) {
        final token = result.value.nextPageToken;
        if (token == null) {
          _externalPageTokens.remove(result.key);
        } else {
          _externalPageTokens[result.key] = token;
        }
        _discoverExternalVideos = [
          ..._discoverExternalVideos,
          ...result.value.videos.where(
            (video) => video.source == result.key && existingIds.add(video.id),
          ),
        ];
      }
    } catch (exception) {
      debugPrint(
        'Discover external pagination failed (${exception.runtimeType}).',
      );
    } finally {
      _externalLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadNextPage() async {
    await Future.wait(FeedSection.values.map(load));
  }
}

enum FeedSection { discover, forYou, favorites }
