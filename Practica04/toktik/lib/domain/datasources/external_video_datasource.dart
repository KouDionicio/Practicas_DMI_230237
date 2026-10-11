import 'package:toktik/domain/entities/external_video.dart';

abstract interface class ExternalVideoDatasource {
  Future<List<ExternalVideo>> search(String query);
}
