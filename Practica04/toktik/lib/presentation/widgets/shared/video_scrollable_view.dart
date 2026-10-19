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
    this.trackDiscoverViews = false,
  });

  final List<VideoPost> videos;
  final List<ExternalVideo> externalVideos;
  final bool isVisible;
  final bool isMuted;
  final ValueChanged<bool> onMuteChanged;
  final bool trackDiscoverViews;

  @override
  State<VideoScrollableView> createState() => _VideoScrollableViewState();
}

class _VideoScrollableViewState extends State<VideoScrollableView> {
  int _activePage = 0;
  late final PageController _pageController = PageController();

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant VideoScrollableView oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (_activePage >= widget.videos.length + widget.externalVideos.length) {
      _activePage = 0;
    }
    if (widget.trackDiscoverViews) _markActiveExternalAsSeen();
  }

  @override
  Widget build(BuildContext context) {
    final feedItems = _interleaveVideos(widget.videos, widget.externalVideos);
    if (feedItems.isEmpty) return const SizedBox.expand();
    return PageView.builder(
      controller: _pageController,
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      itemCount: feedItems.length,
      onPageChanged: (index) {
        setState(() => _activePage = index);
        final item = feedItems[index];
        if (widget.trackDiscoverViews) {
          final video = item.externalVideo;
          if (video != null) context.read<DiscoverProvider>().markExternalVideoSeen(video);
        }
        if (widget.isVisible && index >= feedItems.length - 3) {
          context.read<DiscoverProvider>().loadMoreExternalVideos();
        }
      },
      itemBuilder: (context, index) {
        final item = feedItems[index];
        final localVideo = item.localVideo;
        final externalVideo = item.externalVideo;
        final isActive = widget.isVisible && index == _activePage;
        final isNext = widget.isVisible && index == _activePage + 1;
        final canPrepareExternal = externalVideo != null &&
            externalVideo.source == VideoSource.youtube &&
            (isActive || isNext);
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
                  onDoubleTap: () => _likeVideo(context, video: localVideo),
                ),
              )
            else if (externalVideo != null &&
                (externalVideo.source != VideoSource.youtube || canPrepareExternal))
              Positioned.fill(
                child: ExternalVideoPlayer(
                  key: ValueKey<String>('external:${externalVideo.id}'),
                  video: externalVideo,
                  isActive: isActive,
                  shouldLoad: externalVideo.source != VideoSource.youtube || canPrepareExternal,
                  isMuted: widget.isMuted,
                  onYouTubeUnembeddable: _skipUnembeddableYouTube,
                  onDoubleTap: () =>
                      _likeVideo(context, externalVideo: externalVideo),
                ),
              ),
            if (externalVideo?.source == VideoSource.youtube && !canPrepareExternal)
              Positioned.fill(child: _YouTubeThumbnail(externalVideo!)),
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
                  externalVideo: externalVideo,
                  isMuted: widget.isMuted,
                  onMuteChanged: widget.onMuteChanged,
                ),
              ),
          ],
        );
      },
    );
  }

  void _markActiveExternalAsSeen() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !widget.isVisible) return;
      final feedItems = _interleaveVideos(widget.videos, widget.externalVideos);
      if (_activePage < feedItems.length) {
        final video = feedItems[_activePage].externalVideo;
        if (video != null) context.read<DiscoverProvider>().markExternalVideoSeen(video);
      }
    });
  }

  void _skipUnembeddableYouTube(String videoId) {
    if (!mounted || ExternalVideoPlayer.canEmbedYouTube(videoId)) return;
    context.read<DiscoverProvider>().markYouTubeUnembeddable(videoId);
    setState(() {});
    final remainingCount = _interleaveVideos(
      widget.videos,
      widget.externalVideos,
    ).length;
    if (remainingCount == 0) return;
    final targetPage = _activePage < remainingCount
        ? _activePage
        : remainingCount - 1;
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted && _pageController.hasClients) {
        _pageController.jumpToPage(targetPage);
      }
    });
  }

  static VideoPost _externalAsVideoPost(ExternalVideo video) => VideoPost(
    id: video.id,
    caption: video.title,
    videoUrl: video.embedUrl.toString(),
    description: video.description,
  );

  static Future<void> _likeVideo(
    BuildContext context, {
    VideoPost? video,
    ExternalVideo? externalVideo,
  }) async {
    final likes = context.read<LikesProvider>();
    final discover = context.read<DiscoverProvider>();
    try {
      if (externalVideo == null) {
        final value = video!;
        if (!likes.isLiked(value)) await likes.toggleLike(value);
      } else if (!likes.likedVideoIds.contains(externalVideo.id)) {
        await likes.toggleExternalLike(externalVideo);
      }
      await discover.load(FeedSection.favorites);
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
    final localIds = localVideos.map((video) => video.id).toSet();
    final uniqueExternal = <ExternalVideo>[];
    final seenIds = <String>{...localIds};
    for (final video in externalVideos) {
      if (video.source == VideoSource.youtube &&
          !ExternalVideoPlayer.canEmbedYouTube(
            video.id.substring('youtube:'.length),
          )) {
        continue;
      }
      if (seenIds.add(video.id)) uniqueExternal.add(video);
    }
    final length = localVideos.length > uniqueExternal.length
        ? localVideos.length
        : uniqueExternal.length;
    for (var index = 0; index < length; index++) {
      if (index < localVideos.length) {
        items.add(_FeedVideo.local(localVideos[index]));
      }
      if (index < uniqueExternal.length) {
        items.add(_FeedVideo.external(uniqueExternal[index]));
      }
    }
    return items;
  }
}

class _YouTubeThumbnail extends StatelessWidget {
  const _YouTubeThumbnail(this.video);
  final ExternalVideo video;

  @override
  Widget build(BuildContext context) {
    final id = video.id.substring('youtube:'.length);
    return Image.network(
      'https://img.youtube.com/vi/$id/hqdefault.jpg',
      fit: BoxFit.cover,
      errorBuilder: (_, _, _) => const ColoredBox(color: Colors.black),
    );
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
