import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/domain/repositories/app_preferences_repository.dart';

class LikesProvider extends ChangeNotifier {
  LikesProvider(this._repository, {this.validVideoIds});

  final AppPreferencesRepository _repository;
  final Set<String>? validVideoIds;
  final Set<String> _likedVideoIds = {};
  final Map<String, int> _videoLikeCounts = {};
  Future<void> _writes = Future.value();
  bool isLoaded = false;
  Object? error;

  Set<String> get likedVideoIds => Set.unmodifiable(_likedVideoIds);
  bool isLiked(VideoPost video) => _likedVideoIds.contains(video.id);
  int likeCount(VideoPost video) => _videoLikeCounts[video.id] ?? video.likes;
  Map<String, int> get videoLikeCounts => Map.unmodifiable(_videoLikeCounts);

  Future<void> load() async {
    try {
      final savedIds = await _repository.getLikedVideoIds();
      final savedCounts = await _repository.getVideoLikeCounts();
      final allowedIds = validVideoIds;
      final filteredIds = allowedIds == null
          ? savedIds
          : savedIds.intersection(allowedIds);
      final filteredCounts = allowedIds == null
          ? savedCounts
          : Map<String, int>.fromEntries(
              savedCounts.entries.where(
                (entry) => allowedIds.contains(entry.key),
              ),
            );
      _likedVideoIds
        ..clear()
        ..addAll(filteredIds);
      _videoLikeCounts
        ..clear()
        ..addAll(filteredCounts);
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
    final write = _writes.then((_) async {
      await _repository.saveLikedVideoIds(likedIdsSnapshot);
      await _repository.saveVideoLikeCounts(countsSnapshot);
    });
    _writes = write.then<void>((_) {}, onError: (Object error) {});
    return write;
  }
}
