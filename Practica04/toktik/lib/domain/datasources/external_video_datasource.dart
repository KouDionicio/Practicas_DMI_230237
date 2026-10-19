import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/domain/entities/external_video_page.dart';

abstract interface class ExternalVideoDatasource {
  Future<List<ExternalVideo>> search(String query);
}

abstract interface class PaginatedExternalVideoDatasource
    implements ExternalVideoDatasource {
  Future<ExternalVideoPage> searchPage(String query, {String? pageToken});
}
