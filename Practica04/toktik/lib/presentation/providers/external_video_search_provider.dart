import 'package:flutter/foundation.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/domain/repositories/external_video_repository.dart';

class ExternalVideoSearchProvider extends ChangeNotifier {
  ExternalVideoSearchProvider(
    this._repository, {
    this.environmentFileLoadFailed = false,
  });

  final ExternalVideoRepository _repository;
  final bool environmentFileLoadFailed;
  VideoSource source = VideoSource.youtube;
  List<ExternalVideo> results = const [];
  Object? error;
  bool isLoading = false;
  int _requestId = 0;
  bool _isDisposed = false;

  void selectSource(VideoSource value) {
    if (_isDisposed || source == value) return;
    _requestId++;
    source = value;
    results = const [];
    error = null;
    isLoading = false;
    notifyListeners();
  }

  Future<void> search(String query) async {
    if (_isDisposed) return;
    final requestId = ++_requestId;
    final selectedSource = source;
    final normalizedQuery = query.trim();
    if (normalizedQuery.isEmpty) {
      results = const [];
      error = null;
      isLoading = false;
      notifyListeners();
      return;
    }

    isLoading = true;
    error = null;
    results = const [];
    notifyListeners();
    try {
      final videos = await _repository.search(selectedSource, normalizedQuery);
      if (_isDisposed || requestId != _requestId) return;
      if (videos.any((video) => video.source != selectedSource)) {
        throw FormatException(
          'El repositorio devolvió resultados de otra fuente.',
        );
      }
      results = videos;
    } catch (exception) {
      if (_isDisposed || requestId != _requestId) return;
      error = exception;
    } finally {
      if (!_isDisposed && requestId == _requestId) {
        isLoading = false;
        notifyListeners();
      }
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _requestId++;
    super.dispose();
  }
}
