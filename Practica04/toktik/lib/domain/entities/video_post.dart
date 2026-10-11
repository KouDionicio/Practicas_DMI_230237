class VideoPost {
  final String id;
  final String caption;
  final String videoUrl;
  final String description;
  final int likes;
  final int views;

  const VideoPost({
    String? id,
    required this.caption,
    required this.videoUrl,
    required this.description,
    this.likes = 0,
    this.views = 0,
  }) : id = id ?? videoUrl;
}
