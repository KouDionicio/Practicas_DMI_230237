import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/domain/repositories/external_video_repository.dart';
import 'package:toktik/presentation/providers/external_video_search_provider.dart';

class _FakeRepository implements ExternalVideoRepository {
  final requests = <Completer<List<ExternalVideo>>>[];

  @override
  Future<List<ExternalVideo>> search(VideoSource source, String query) {
    final completer = Completer<List<ExternalVideo>>();
    requests.add(completer);
    return completer.future;
  }
}

ExternalVideo _video(VideoSource source, String id) => ExternalVideo(
  id: '${source.name}:$id',
  source: source,
  title: id,
  description: '',
  thumbnailUrl: '',
  watchUrl: Uri.https('example.com', '/watch'),
  embedUrl: Uri.https('example.com', '/embed'),
);

void main() {
  test('empty search clears results without calling the repository', () async {
    final repository = _FakeRepository();
    final provider = ExternalVideoSearchProvider(repository);
    provider.results = [_video(VideoSource.youtube, 'old')];
    provider.error = Exception('old error');

    await provider.search('   ');

    expect(repository.requests, isEmpty);
    expect(provider.results, isEmpty);
    expect(provider.error, isNull);
    expect(provider.isLoading, isFalse);
    provider.dispose();
  });

  test('changing source invalidates an older pending search', () async {
    final repository = _FakeRepository();
    final provider = ExternalVideoSearchProvider(repository);

    final oldSearch = provider.search('first');
    provider.selectSource(VideoSource.vimeo);
    final currentSearch = provider.search('second');

    repository.requests[0].complete([_video(VideoSource.youtube, 'old')]);
    repository.requests[1].complete([_video(VideoSource.vimeo, 'new')]);
    await Future.wait([oldSearch, currentSearch]);

    expect(provider.source, VideoSource.vimeo);
    expect(provider.results.map((video) => video.id), ['vimeo:new']);
    expect(provider.isLoading, isFalse);
    provider.dispose();
  });

  test('a newer query wins when earlier requests complete last', () async {
    final repository = _FakeRepository();
    final provider = ExternalVideoSearchProvider(repository);

    final earlierSearch = provider.search('earlier');
    final newerSearch = provider.search('newer');
    repository.requests[1].complete([_video(VideoSource.youtube, 'newer')]);
    await newerSearch;
    repository.requests[0].complete([_video(VideoSource.youtube, 'earlier')]);
    await earlierSearch;

    expect(provider.results.map((video) => video.id), ['youtube:newer']);
    provider.dispose();
  });
}
