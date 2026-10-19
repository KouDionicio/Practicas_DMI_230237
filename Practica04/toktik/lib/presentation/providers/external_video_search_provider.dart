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
  bool isLoadingMore = false;
  bool get hasMore => _nextPageToken != null;
  String? _nextPageToken;
  int _requestId = 0;
  bool _isDisposed = false;

  void selectSource(VideoSource value) {
    if (_isDisposed || source == value) return;
    _requestId++;
    source = value;
    results = const [];
    _nextPageToken = null;
    error = null;
    isLoading = false;
    isLoadingMore = false;
    notifyListeners();
  }

  Future<void> search(String query) async {
    if (_isDisposed) return;
    final requestId = ++_requestId;
    final selectedSource = source;
    final normalizedQuery = query.trim();
    _lastQuery = normalizedQuery;
    _nextPageToken = null;
    if (normalizedQuery.isEmpty) {
      results = const [];
      _nextPageToken = null;
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
      final page = await searchExternalVideoPage(
        _repository,
        selectedSource,
        normalizedQuery,
      );
      if (_isDisposed || requestId != _requestId) return;
      if (page.videos.any((video) => video.source != selectedSource)) {
        throw FormatException(
          'El repositorio devolvió resultados de otra fuente.',
        );
      }
      results = page.videos;
      _nextPageToken = page.nextPageToken;
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

  Future<void> loadMore() async {
    final token = _nextPageToken;
    if (_isDisposed || isLoading || isLoadingMore || token == null) return;
    final requestId = _requestId;
    isLoadingMore = true;
    notifyListeners();
    try {
      final page = await searchExternalVideoPage(
        _repository,
        source,
        _lastQuery,
        pageToken: token,
      );
      if (_isDisposed || requestId != _requestId) return;
      final existingIds = results.map((video) => video.id).toSet();
      results = [
        ...results,
        ...page.videos.where(
          (video) => video.source == source && existingIds.add(video.id),
        ),
      ];
      _nextPageToken = page.nextPageToken;
    } catch (exception) {
      if (!_isDisposed && requestId == _requestId) error = exception;
    } finally {
      if (!_isDisposed && requestId == _requestId) {
        isLoadingMore = false;
        notifyListeners();
      }
    }
  }

  String _lastQuery = '';

  @override
  void dispose() {
    _isDisposed = true;
    _requestId++;
    super.dispose();
  }
}
