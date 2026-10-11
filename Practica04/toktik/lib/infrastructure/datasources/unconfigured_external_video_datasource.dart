import 'package:toktik/domain/datasources/external_video_datasource.dart';
import 'package:toktik/domain/entities/external_video.dart';

class UnconfiguredExternalVideoDatasource implements ExternalVideoDatasource {
  const UnconfiguredExternalVideoDatasource({
    required this.providerName,
    required this.configurationRequirement,
  });

  final String providerName;
  final String configurationRequirement;

  @override
  Future<List<ExternalVideo>> search(String query) {
    throw UnsupportedError(
      '$providerName no está configurado. $configurationRequirement',
    );
  }
}

class YouTubeVideoDatasource extends UnconfiguredExternalVideoDatasource {
  const YouTubeVideoDatasource()
    : super(
        providerName: 'YouTube',
        configurationRequirement:
            'Configure el acceso autorizado a YouTube Data API v3 y use el '
            'reproductor IFrame oficial.',
      );
}

class VimeoVideoDatasource extends UnconfiguredExternalVideoDatasource {
  const VimeoVideoDatasource()
    : super(
        providerName: 'Vimeo',
        configurationRequirement:
            'Configure credenciales con alcance de lectura y use el '
            'reproductor integrado de Vimeo.',
      );
}

class DailymotionVideoDatasource extends UnconfiguredExternalVideoDatasource {
  const DailymotionVideoDatasource()
    : super(
        providerName: 'Dailymotion',
        configurationRequirement:
            'Configure API v2 y un reproductor de Dailymotion autorizado.',
      );
}
