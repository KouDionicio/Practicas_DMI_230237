import 'dart:async';
import 'dart:math';

import 'package:flutter/foundation.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/domain/entities/external_video_page.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/domain/errors/external_video_exception.dart';
import 'package:toktik/domain/repositories/discover_repository.dart';
import 'package:toktik/domain/repositories/external_video_repository.dart';
import 'package:toktik/domain/repositories/favorites_repository.dart';
import 'package:toktik/domain/repositories/for_you_repository.dart';
import 'package:toktik/infrastructure/repositories/shared_preferences_repository.dart';

class DiscoverProvider extends ChangeNotifier {
  static const externalSearchQuery = 'viral videos';
  static const externalVideosPerProvider = 50;
  static const _externalSources = [VideoSource.youtube, VideoSource.vimeo, VideoSource.peertube];
  final Map<FeedSection, List<VideoPost>> _videos = {
    for (final section in FeedSection.values) section: <VideoPost>[],
  };
  List<ExternalVideo> _discoverExternalVideos = const [];
  final Map<VideoSource, Object> _externalErrors = {};
  final Map<VideoSource, String> _externalPageTokens = {};
  final Map<String, ExternalVideoPage> _pageCache = {};
  final Set<String> _seenIds = {};
  final Set<String> _unembeddableYouTubeIds = {};
  final Set<FeedSection> _loading = {};
  final Map<FeedSection, Object> _errors = {};
  final _RequestLimiter _limiter = _RequestLimiter(2);
  final Random _random = Random();
  bool _historyLoaded = false;
  bool _externalLoadingMore = false;
  int _paginationSourceCursor = 0;

  DiscoverProvider({
    required this.discoverRepository,
    required this.forYouRepository,
    required this.favoritesRepository,
    this.externalVideoRepository,
    this.preferencesRepository,
  });

  final DiscoverRepository discoverRepository;
  final ForYouRepository forYouRepository;
  final FavoritesRepository favoritesRepository;
  final ExternalVideoRepository? externalVideoRepository;
  final SharedPreferencesRepository? preferencesRepository;

  List<VideoPost> videosFor(FeedSection section) => List.unmodifiable(_videos[section]!);
  List<ExternalVideo> externalVideosFor(FeedSection section) => section == FeedSection.discover ? List.unmodifiable(_discoverExternalVideos) : const [];
  bool isLoading(FeedSection section) => _loading.contains(section);
  Object? errorFor(FeedSection section) => _errors[section];
  Map<VideoSource, Object> get externalErrors => Map.unmodifiable(_externalErrors);
  bool get isLoadingMoreExternal => _externalLoadingMore;

  Future<void> load(FeedSection section) async {
    if (_loading.contains(section)) return;
    _loading.add(section);
    _errors.remove(section);
    notifyListeners();
    try {
      if (section == FeedSection.discover) {
        _videos[section] = await discoverRepository.getVideosByPage(1);
        _discoverExternalVideos = await _loadExternalDiscoverVideos();
      } else {
        _videos[section] = switch (section) {
          FeedSection.discover => const [],
          FeedSection.forYou => await forYouRepository.getVideosByPage(1),
          FeedSection.favorites => await favoritesRepository.getVideosByUserId('local'),
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
    if (!_historyLoaded) {
      _seenIds.addAll(await preferencesRepository?.getDiscoverSeenIds() ?? {});
      _unembeddableYouTubeIds.addAll(await preferencesRepository?.getUnembeddableYouTubeIds() ?? {});
      _historyLoaded = true;
    }
    final pages = await Future.wait(_externalSources.map((source) async {
      try {
        final page = await _getPage(repository, source, null);
        if (page.nextPageToken != null) _externalPageTokens[source] = page.nextPageToken!;
        return MapEntry(source, page);
      } catch (error) {
        _externalErrors[source] = error;
        debugPrint('Discover: ${source.name} unavailable (${error.runtimeType}).');
        return MapEntry(source, const ExternalVideoPage([]));
      }
    }));
    final gathered = <ExternalVideo>[];
    for (final entry in pages) { gathered.addAll(entry.value.videos.where((video) => video.source == entry.key)); }
    return _orderInterleaved(gathered);
  }

  Future<ExternalVideoPage> _getPage(ExternalVideoRepository repository, VideoSource source, String? token) async {
    final key = '${source.name}:${token ?? 'first'}';
    final cached = _pageCache[key];
    if (cached != null) return cached;
    for (var attempt = 0; ; attempt++) {
      try {
        final page = await _limiter.run(() => searchExternalVideoPage(repository, source, externalSearchQuery, pageToken: token));
        final videos = _unique(page.videos.where((video) => video.source == source && !(source == VideoSource.youtube && _unembeddableYouTubeIds.contains(video.id))).toList());
        final result = ExternalVideoPage(videos, nextPageToken: page.nextPageToken);
        _pageCache[key] = result;
        return result;
      } catch (error) {
        if (error is ExternalVideoApiException && error.statusCode == 429 && attempt < 2) {
          await Future<void>.delayed(Duration(seconds: attempt == 0 ? 2 : 5));
          continue;
        }
        rethrow;
      }
    }
  }

  List<ExternalVideo> _unique(List<ExternalVideo> videos) {
    final ids = <String>{};
    return videos.where((video) => ids.add('${video.source.name}:${video.id}')).toList();
  }

  List<ExternalVideo> _orderInterleaved(List<ExternalVideo> input) {
    final grouped = <VideoSource, List<ExternalVideo>>{for (final source in _externalSources) source: <ExternalVideo>[]};
    for (final video in _unique(input)) { grouped[video.source]?.add(video); }
    for (final list in grouped.values) { list.shuffle(_random); }
    final unseen = <ExternalVideo>[];
    final seen = <ExternalVideo>[];
    var remaining = true;
    while (remaining) {
      remaining = false;
      for (final source in _externalSources) {
        final list = grouped[source]!;
        if (list.isEmpty) continue;
        remaining = true;
        final video = list.removeLast();
        (_seenIds.contains(video.id) ? seen : unseen).add(video);
      }
    }
    return [...unseen, ...seen];
  }

  Future<void> markExternalVideoSeen(ExternalVideo video) async {
    if (_seenIds.add(video.id)) await preferencesRepository?.saveDiscoverSeenIds(_seenIds);
  }

  Future<void> markYouTubeUnembeddable(String videoId) async {
    final id = videoId.startsWith('youtube:') ? videoId : 'youtube:$videoId';
    if (!_unembeddableYouTubeIds.add(id)) return;
    await preferencesRepository?.saveUnembeddableYouTubeIds(_unembeddableYouTubeIds);
    _discoverExternalVideos = _discoverExternalVideos.where((video) => video.id != id).toList();
    notifyListeners();
  }

  Future<void> loadMoreExternalVideos() async {
    final repository = externalVideoRepository;
    if (repository == null || _externalLoadingMore) return;
    _externalLoadingMore = true;
    notifyListeners();
    try {
      final sources = <VideoSource>[];
      for (var offset = 0; offset < _externalSources.length && sources.length < 2; offset++) {
        final source = _externalSources[(_paginationSourceCursor + offset) % _externalSources.length];
        if (_externalPageTokens.containsKey(source)) sources.add(source);
      }
      _paginationSourceCursor = (_paginationSourceCursor + 2) % _externalSources.length;
      final pages = <MapEntry<VideoSource, ExternalVideoPage>>[];
      for (final source in sources) {
        final token = _externalPageTokens[source]!;
        try {
          pages.add(MapEntry(source, await _getPage(repository, source, token)));
        } catch (error) {
          _externalErrors[source] = error;
          _externalPageTokens.remove(source);
        }
      }
      final currentIds = _discoverExternalVideos.map((video) => video.id).toSet();
      final appended = <ExternalVideo>[];
      for (final entry in pages) {
        if (entry.value.nextPageToken == null) { _externalPageTokens.remove(entry.key); }
        else { _externalPageTokens[entry.key] = entry.value.nextPageToken!; }
        appended.addAll(entry.value.videos.where((video) => video.source == entry.key && currentIds.add(video.id)));
      }
      if (appended.isEmpty && _externalPageTokens.isEmpty && _discoverExternalVideos.isNotEmpty) {
        appended.addAll(_discoverExternalVideos);
      }
      if (appended.isNotEmpty) _discoverExternalVideos = [..._discoverExternalVideos, ..._orderInterleaved(appended)];
    } catch (error) {
      debugPrint('Discover pagination failed (${error.runtimeType}).');
    } finally {
      _externalLoadingMore = false;
      notifyListeners();
    }
  }

  Future<void> loadNextPage() async {
    await Future.wait(FeedSection.values.map(load));
  }
}

class _RequestLimiter {
  _RequestLimiter(this.maximum);
  final int maximum;
  int _active = 0;
  final List<Completer<void>> _waiting = [];
  Future<T> run<T>(Future<T> Function() action) async {
    if (_active >= maximum) { final waiter = Completer<void>(); _waiting.add(waiter); await waiter.future; }
    _active++;
    try { return await action(); }
    finally { _active--; if (_waiting.isNotEmpty) _waiting.removeAt(0).complete(); }
  }
}

enum FeedSection { discover, forYou, favorites }
