class VideoPost {

  final String caption;
  final String videoUrl;
  final String description;
  final int likes;
  final int views;

  VideoPost({
    required this.caption,
    required this.videoUrl,
    required this.description,
    this.likes = 0,
    this.views = 0
  });

}