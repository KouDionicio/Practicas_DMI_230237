enum VideoSource {
  local,
  youtube,
  vimeo,
  peertube;

  static VideoSource? fromUrl(String rawUrl) {
    final value = rawUrl.trim();
    if (value.isEmpty) return null;

    if (value.startsWith('assets/') ||
        value.startsWith('lib/') ||
        value.startsWith('./') ||
        value.startsWith('../') ||
        value.startsWith('file://') ||
        value.startsWith('/')) {
      return VideoSource.local;
    }

    final uri = Uri.tryParse(value);
    if (uri == null) return null;
    final host = uri.host.toLowerCase();

    if (uri.scheme.isEmpty) {
      return null;
    }

    if (host == 'youtu.be' ||
        host == 'youtube.com' ||
        host == 'www.youtube.com' ||
        host == 'm.youtube.com' ||
        host.endsWith('.youtube.com')) {
      return VideoSource.youtube;
    }

    if (host == 'vimeo.com' ||
        host == 'www.vimeo.com' ||
        host == 'player.vimeo.com' ||
        host.endsWith('.vimeocdn.com')) {
      return VideoSource.vimeo;
    }

    final segments = uri.pathSegments;
    final hasPeerTubeWatchPattern =
        segments.length >= 3 &&
        segments[segments.length - 3] == 'videos' &&
        (segments[segments.length - 2] == 'watch' ||
            segments[segments.length - 2] == 'embed');
    final hasPeerTubeShortPattern =
        segments.length >= 2 && segments.first == 'w';

    if (host.isNotEmpty &&
        (hasPeerTubeWatchPattern || hasPeerTubeShortPattern)) {
      return VideoSource.peertube;
    }

    return null;
  }

  bool get isExternal => this != VideoSource.local;
}

class ExternalVideo {
  const ExternalVideo({
    required this.id,
    required this.source,
    required this.title,
    required this.description,
    required this.thumbnailUrl,
    required this.watchUrl,
    required this.embedUrl,
    this.durationSeconds,
  });

  final String id;
  final VideoSource source;
  final String title;
  final String description;
  final String thumbnailUrl;
  final Uri watchUrl;
  final Uri embedUrl;
  final int? durationSeconds;

  Map<String, Object?> toJson() => {
    'id': id,
    'source': source.name,
    'title': title,
    'description': description,
    'thumbnailUrl': thumbnailUrl,
    'watchUrl': watchUrl.toString(),
    'embedUrl': embedUrl.toString(),
    'durationSeconds': durationSeconds,
  };

  factory ExternalVideo.fromJson(Map<String, dynamic> json) {
    final sourceName = json['source'];
    final source = VideoSource.values
        .where((value) => value.name == sourceName)
        .firstOrNull;
    final id = json['id'];
    final watchUrl = Uri.tryParse(json['watchUrl'] as String? ?? '');
    final embedUrl = Uri.tryParse(json['embedUrl'] as String? ?? '');
    if (source == null ||
        !source.isExternal ||
        id is! String ||
        !id.startsWith('${source.name}:') ||
        watchUrl == null ||
        embedUrl == null) {
      throw const FormatException('Invalid saved external video.');
    }
    return ExternalVideo(
      id: id,
      source: source,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      thumbnailUrl: json['thumbnailUrl'] as String? ?? '',
      watchUrl: watchUrl,
      embedUrl: embedUrl,
      durationSeconds: json['durationSeconds'] as int?,
    );
  }
}
