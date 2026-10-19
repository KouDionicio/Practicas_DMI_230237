import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/domain/repositories/app_preferences_repository.dart';

class LikesProvider extends ChangeNotifier {
  LikesProvider(this._repository, {this.validVideoIds});

  final AppPreferencesRepository _repository;
  final Set<String>? validVideoIds;
  final Set<String> _likedVideoIds = {};
  final Map<String, int> _videoLikeCounts = {};
  final Map<String, ExternalVideo> _likedExternalVideos = {};
  Future<void> _writes = Future.value();
  bool isLoaded = false;
  Object? error;

  Set<String> get likedVideoIds => Set.unmodifiable(_likedVideoIds);
  bool isLiked(VideoPost video) => _likedVideoIds.contains(video.id);
  int likeCount(VideoPost video) => _videoLikeCounts[video.id] ?? video.likes;
  Map<String, int> get videoLikeCounts => Map.unmodifiable(_videoLikeCounts);
  List<ExternalVideo> get likedExternalVideos =>
      List.unmodifiable(_likedExternalVideos.values);

  static bool _isExternalId(String id) =>
      RegExp(r'^youtube:[A-Za-z0-9_-]{1,128}$').hasMatch(id) ||
      RegExp(r'^vimeo:[0-9]{1,128}$').hasMatch(id) ||
      RegExp(r'^peertube:[0-9a-fA-F]{8}-(?:[0-9a-fA-F]{4}-){3}[0-9a-fA-F]{12}$')
          .hasMatch(id);

  Future<void> load() async {
    try {
      final savedIds = await _repository.getLikedVideoIds();
      final savedCounts = await _repository.getVideoLikeCounts();
      final savedExternal = await _repository.getLikedExternalVideos();
      final allowedIds = validVideoIds;
      final filteredIds = allowedIds == null
          ? savedIds
          : savedIds
                .where((id) => allowedIds.contains(id) || _isExternalId(id))
                .toSet();
      final filteredCounts = allowedIds == null
          ? savedCounts
          : Map<String, int>.fromEntries(
              savedCounts.entries.where(
                (entry) =>
                    allowedIds.contains(entry.key) || _isExternalId(entry.key),
              ),
            );
      _likedVideoIds
        ..clear()
        ..addAll(filteredIds);
      _videoLikeCounts
        ..clear()
        ..addAll(filteredCounts);
      _likedExternalVideos
        ..clear()
        ..addEntries(
          savedExternal.entries
              .map(
                (entry) =>
                    MapEntry(entry.key, ExternalVideo.fromJson(entry.value)),
              )
              .where((entry) => filteredIds.contains(entry.key)),
        );
      if (filteredIds.length != savedIds.length ||
          filteredCounts.length != savedCounts.length) {
        await _repository.saveLikedVideoIds(filteredIds);
        await _repository.saveVideoLikeCounts(filteredCounts);
      }
      error = null;
    } catch (exception) {
      error = exception;
    } finally {
      isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> toggleLike(VideoPost video) {
    final nextLiked = !isLiked(video);
    final currentCount = likeCount(video);
    if (!nextLiked) {
      _likedVideoIds.remove(video.id);
      _videoLikeCounts[video.id] = currentCount > 0 ? currentCount - 1 : 0;
    } else {
      _likedVideoIds.add(video.id);
      _videoLikeCounts[video.id] = currentCount + 1;
    }
    final likedIdsSnapshot = Set<String>.of(_likedVideoIds);
    final countsSnapshot = Map<String, int>.of(_videoLikeCounts);
    notifyListeners();
    return _persist(likedIdsSnapshot, countsSnapshot);
  }

  Future<void> toggleExternalLike(ExternalVideo video) {
    final wasLiked = _likedVideoIds.contains(video.id);
    final currentCount = _videoLikeCounts[video.id] ?? 0;
    if (wasLiked) {
      _likedVideoIds.remove(video.id);
      _likedExternalVideos.remove(video.id);
      _videoLikeCounts[video.id] = currentCount > 0 ? currentCount - 1 : 0;
    } else {
      _likedVideoIds.add(video.id);
      _likedExternalVideos[video.id] = video;
      _videoLikeCounts[video.id] = currentCount + 1;
    }
    final ids = Set<String>.of(_likedVideoIds);
    final counts = Map<String, int>.of(_videoLikeCounts);
    final externals = <String, Map<String, Object?>>{
      for (final entry in _likedExternalVideos.entries)
        entry.key: entry.value.toJson(),
    };
    notifyListeners();
    return _persist(ids, counts, externals);
  }

  Future<void> _persist(
    Set<String> likedIdsSnapshot,
    Map<String, int> countsSnapshot, [
    Map<String, Map<String, Object?>>? externalSnapshot,
  ]) {
    final write = _writes.then((_) async {
      await _repository.saveLikedVideoIds(likedIdsSnapshot);
      await _repository.saveVideoLikeCounts(countsSnapshot);
      if (externalSnapshot != null) {
        await _repository.saveLikedExternalVideos(externalSnapshot);
      }
    });
    _writes = write.then<void>((_) {}, onError: (Object error) {});
    return write;
  }
}
