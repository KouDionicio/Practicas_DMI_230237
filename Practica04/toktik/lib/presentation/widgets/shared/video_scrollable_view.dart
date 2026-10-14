import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';
import 'package:toktik/presentation/providers/likes_provider.dart';
import 'package:toktik/presentation/widgets/shared/video_buttons.dart';
import 'package:toktik/presentation/widgets/video/external_video_player.dart';
import 'package:toktik/presentation/widgets/video/fullscreen_player.dart';

class VideoScrollableView extends StatefulWidget {
  const VideoScrollableView({
    super.key,
    required this.videos,
    this.externalVideos = const [],
    required this.isVisible,
    required this.isMuted,
    required this.onMuteChanged,
  });

  final List<VideoPost> videos;
  final List<ExternalVideo> externalVideos;
  final bool isVisible;
  final bool isMuted;
  final ValueChanged<bool> onMuteChanged;

  @override
  State<VideoScrollableView> createState() => _VideoScrollableViewState();
}

class _VideoScrollableViewState extends State<VideoScrollableView> {
  int _activePage = 0;

  @override
  void didUpdateWidget(covariant VideoScrollableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_activePage >= widget.videos.length + widget.externalVideos.length) {
      _activePage = 0;
    }
  }

  @override
  Widget build(BuildContext context) {
    final feedItems = _interleaveVideos(widget.videos, widget.externalVideos);
    if (feedItems.isEmpty) return const SizedBox.expand();
    return PageView.builder(
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      itemCount: feedItems.length,
      onPageChanged: (index) => setState(() => _activePage = index),
      itemBuilder: (context, index) {
        final item = feedItems[index];
        final localVideo = item.localVideo;
        final externalVideo = item.externalVideo;
        final isActive = widget.isVisible && index == _activePage;
        return Stack(
          children: [
            if (localVideo != null)
              Positioned.fill(
                child: FullScreenPlayer(
                  caption: localVideo.caption,
                  description: localVideo.description,
                  videoUrl: localVideo.videoUrl,
                  isActive: isActive,
                  isMuted: widget.isMuted,
                  onDoubleTap: () => _likeVideo(context, localVideo),
                ),
              )
            else if (externalVideo != null)
              Positioned.fill(
                child: ExternalVideoPlayer(
                  video: externalVideo,
                  isActive: isActive,
                  isMuted: widget.isMuted,
                  onDoubleTap: () =>
                      _likeVideo(context, _externalAsVideoPost(externalVideo)),
                ),
              ),
            if (widget.isVisible && localVideo != null)
              Positioned(
                bottom: 36,
                right: 12,
                child: VideoButtons(
                  video: localVideo,
                  isMuted: widget.isMuted,
                  onMuteChanged: widget.onMuteChanged,
                ),
              ),
            if (widget.isVisible && externalVideo != null)
              Positioned(
                left: 20,
                right: 20,
                bottom: 28,
                child: IgnorePointer(
                  child: Text(
                    externalVideo.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      shadows: [Shadow(color: Colors.black, blurRadius: 8)],
                    ),
                  ),
                ),
              ),
            if (widget.isVisible && externalVideo != null)
              Positioned(
                bottom: 36,
                right: 12,
                child: VideoButtons(
                  video: _externalAsVideoPost(externalVideo),
                  isMuted: widget.isMuted,
                  onMuteChanged: widget.onMuteChanged,
                ),
              ),
          ],
        );
      },
    );
  }

  static VideoPost _externalAsVideoPost(ExternalVideo video) => VideoPost(
    id: video.id,
    caption: video.title,
    videoUrl: video.embedUrl.toString(),
    description: video.description,
  );

  static Future<void> _likeVideo(BuildContext context, VideoPost video) async {
    final likes = context.read<LikesProvider>();
    final discover = context.read<DiscoverProvider>();
    try {
      if (!likes.isLiked(video)) {
        await likes.toggleLike(video);
        await discover.load(FeedSection.favorites);
      }
    } catch (error) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo guardar el Me gusta: $error')),
        );
      }
    }
  }

  static List<_FeedVideo> _interleaveVideos(
    List<VideoPost> localVideos,
    List<ExternalVideo> externalVideos,
  ) {
    final items = <_FeedVideo>[];
    final length = localVideos.length > externalVideos.length
        ? localVideos.length
        : externalVideos.length;
    for (var index = 0; index < length; index++) {
      if (index < localVideos.length) {
        items.add(_FeedVideo.local(localVideos[index]));
      }
      if (index < externalVideos.length) {
        items.add(_FeedVideo.external(externalVideos[index]));
      }
    }
    return items;
  }
}

class _FeedVideo {
  const _FeedVideo.local(VideoPost video)
    : localVideo = video,
      externalVideo = null;

  const _FeedVideo.external(ExternalVideo video)
    : localVideo = null,
      externalVideo = video;

  final VideoPost? localVideo;
  final ExternalVideo? externalVideo;
}
