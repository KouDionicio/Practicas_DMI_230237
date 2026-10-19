import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/domain/entities/external_video_page.dart';

abstract interface class ExternalVideoRepository {
  Future<List<ExternalVideo>> search(VideoSource source, String query);
}

abstract interface class PaginatedExternalVideoRepository
    implements ExternalVideoRepository {
  Future<ExternalVideoPage> searchPage(
    VideoSource source,
    String query, {
    String? pageToken,
  });
}

Future<ExternalVideoPage> searchExternalVideoPage(
  ExternalVideoRepository repository,
  VideoSource source,
  String query, {
  String? pageToken,
}) async {
  if (repository is PaginatedExternalVideoRepository) {
    return repository.searchPage(source, query, pageToken: pageToken);
  }
  return ExternalVideoPage(await repository.search(source, query));
}
