import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/presentation/providers/season_provider.dart';
import 'package:toktik/presentation/widgets/video/local_video_asset_path.dart';
import 'package:toktik/presentation/widgets/video/video_background.dart';
import 'package:toktik/presentation/widgets/video/video_description.dart';
import 'package:video_player/video_player.dart';

class FullScreenPlayer extends StatefulWidget {
  const FullScreenPlayer({
    super.key,
    required this.videoUrl,
    required this.caption,
    required this.description,
    required this.isActive,
    required this.isMuted,
    this.onDoubleTap,
  });

  final String videoUrl;
  final String caption;
  final String description;
  final bool isActive;
  final bool isMuted;
  final VoidCallback? onDoubleTap;

  @override
  State<FullScreenPlayer> createState() => _FullScreenPlayerState();
}

class _FullScreenPlayerState extends State<FullScreenPlayer>
    with WidgetsBindingObserver {
  VideoPlayerController? _controller;
  Object? _error;
  bool _isPlaying = true;
  bool _isExpanded = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    if (widget.isActive) _initialize();
  }

  @override
  void didUpdateWidget(covariant FullScreenPlayer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.videoUrl != widget.videoUrl) {
      _releaseController();
      _error = null;
      _isPlaying = true;
      if (widget.isActive) _initialize();
    } else if (oldWidget.isActive != widget.isActive) {
      if (widget.isActive) {
        _isPlaying = true;
        _initialize();
      } else {
        _releaseController();
      }
    }
    if (oldWidget.isMuted != widget.isMuted && _controller != null) {
      _controller!.setVolume(widget.isMuted ? 0 : 1);
    }
  }

  Future<void> _initialize() async {
    if (_controller != null || !widget.isActive) return;
    final controller = VideoPlayerController.asset(
      localVideoAssetForPlatform(widget.videoUrl, defaultTargetPlatform),
    );
    _controller = controller;
    try {
      await controller.initialize();
      await controller.setLooping(true);
      await controller.setVolume(widget.isMuted ? 0 : 1);
      if (widget.isActive && _isPlaying) await controller.play();
      if (mounted) setState(() {});
    } catch (error) {
      await controller.dispose();
      if (identical(_controller, controller)) _controller = null;
      if (mounted) setState(() => _error = error);
    }
  }

  void _releaseController() {
    final controller = _controller;
    _controller = null;
    if (controller != null) controller.dispose();
  }

  Future<void> _togglePlayback() async {
    final controller = _controller;
    if (controller == null) return;
    setState(() => _isPlaying = !_isPlaying);
    if (_isPlaying) {
      await controller.play();
    } else {
      await controller.pause();
    }
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final controller = _controller;
    if (controller == null) return;
    if (state == AppLifecycleState.resumed && _isPlaying && widget.isActive) {
      controller.play();
    } else if (state != AppLifecycleState.resumed) {
      controller.pause();
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _releaseController();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final season = context.watch<SeasonProvider>().season;
    final controller = _controller;
    if (!widget.isActive) return const SizedBox.expand();
    if (_error != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('No se pudo reproducir este video: $_error'),
              const SizedBox(height: 8),
              TextButton(
                onPressed: () {
                  setState(() => _error = null);
                  _initialize();
                },
                child: const Text('Reintentar'),
              ),
            ],
          ),
        ),
      );
    }
    if (controller == null || !controller.value.isInitialized) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }

    return GestureDetector(
      onTap: _togglePlayback,
      onDoubleTap: widget.onDoubleTap,
      child: Stack(
        fit: StackFit.expand,
        children: [
          FittedBox(
            fit: BoxFit.cover,
            clipBehavior: Clip.hardEdge,
            child: SizedBox(
              width: controller.value.size.width,
              height: controller.value.size.height,
              child: VideoPlayer(controller),
            ),
          ),
          VideoBackground(stops: const [0.45, 1]),
          Positioned(
            bottom: 44,
            left: 20,
            right: 86,
            child: VideoDescription(
              caption: widget.caption,
              description: widget.description,
              isExpanded: _isExpanded,
              onExpansionChanged: (value) =>
                  setState(() => _isExpanded = value),
            ),
          ),
          if (!_isPlaying)
            Center(
              child: Icon(
                Icons.play_arrow,
                size: 72,
                color: season.primaryColor,
              ),
            ),
        ],
      ),
    );
  }
}
