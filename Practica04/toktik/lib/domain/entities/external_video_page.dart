import 'package:toktik/domain/entities/external_video.dart';

class ExternalVideoPage {
  const ExternalVideoPage(this.videos, {this.nextPageToken});

  final List<ExternalVideo> videos;
  final String? nextPageToken;
}
