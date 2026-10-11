import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/presentation/widgets/shared/video_buttons.dart';
import 'package:toktik/presentation/widgets/video/fullscreen_player.dart';

class VideoScrollableView extends StatefulWidget {
  const VideoScrollableView({
    super.key,
    required this.videos,
    required this.isVisible,
    required this.isMuted,
    required this.onMuteChanged,
  });

  final List<VideoPost> videos;
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
    if (_activePage >= widget.videos.length) _activePage = 0;
  }

  @override
  Widget build(BuildContext context) {
    if (widget.videos.isEmpty) return const SizedBox.expand();
    return PageView.builder(
      scrollDirection: Axis.vertical,
      physics: const BouncingScrollPhysics(),
      itemCount: widget.videos.length,
      onPageChanged: (index) => setState(() => _activePage = index),
      itemBuilder: (context, index) {
        final video = widget.videos[index];
        final isActive = widget.isVisible && index == _activePage;
        return Stack(
          children: [
            Positioned.fill(
              child: FullScreenPlayer(
                caption: video.caption,
                description: video.description,
                videoUrl: video.videoUrl,
                isActive: isActive,
                isMuted: widget.isMuted,
              ),
            ),
            if (widget.isVisible)
              Positioned(
                bottom: 36,
                right: 12,
                child: VideoButtons(
                  video: video,
                  isMuted: widget.isMuted,
                  onMuteChanged: widget.onMuteChanged,
                ),
              ),
          ],
        );
      },
    );
  }
}
