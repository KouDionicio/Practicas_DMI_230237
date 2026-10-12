enum VideoSource { youtube, vimeo, peertube }

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
}
