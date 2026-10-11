import 'package:toktik/domain/entities/external_video.dart';

abstract interface class ExternalVideoRepository {
  Future<List<ExternalVideo>> search(VideoSource source, String query);
}
