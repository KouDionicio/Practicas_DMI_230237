import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/domain/repositories/app_preferences_repository.dart';

class LikesProvider extends ChangeNotifier {
  LikesProvider(this._repository);

  final AppPreferencesRepository _repository;
  final Set<String> _likedVideoIds = {};
  Future<void> _writes = Future.value();
  bool isLoaded = false;
  Object? error;

  Set<String> get likedVideoIds => Set.unmodifiable(_likedVideoIds);
  bool isLiked(VideoPost video) => _likedVideoIds.contains(video.id);

  Future<void> load() async {
    try {
      final savedIds = await _repository.getLikedVideoIds();
      _likedVideoIds
        ..clear()
        ..addAll(savedIds);
      error = null;
    } catch (exception) {
      error = exception;
    } finally {
      isLoaded = true;
      notifyListeners();
    }
  }

  Future<void> toggleLike(VideoPost video) {
    if (isLiked(video)) {
      _likedVideoIds.remove(video.id);
    } else {
      _likedVideoIds.add(video.id);
    }
    final snapshot = Set<String>.of(_likedVideoIds);
    notifyListeners();
    final write = _writes.then((_) => _repository.saveLikedVideoIds(snapshot));
    _writes = write.then<void>((_) {}, onError: (Object error) {});
    return write;
  }
}
