import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/config/helpers/human_formats.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';
import 'package:toktik/presentation/providers/likes_provider.dart';
import 'package:toktik/presentation/providers/seasonal_audio_provider.dart';

class VideoButtons extends StatelessWidget {
  const VideoButtons({
    super.key,
    required this.video,
    required this.isMuted,
    required this.onMuteChanged,
  });

  final VideoPost video;
  final bool isMuted;
  final ValueChanged<bool> onMuteChanged;

  @override
  Widget build(BuildContext context) {
    final likesProvider = context.watch<LikesProvider>();
    final isLiked = likesProvider.isLiked(video);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CustomIconButton(
          value: video.likes + (isLiked ? 1 : 0),
          iconColor: isLiked ? Colors.redAccent : Colors.white,
          iconData: isLiked ? Icons.favorite : Icons.favorite_border,
          semanticLabel: isLiked ? 'Quitar Me gusta' : 'Me gusta',
          onPressed: () async {
            final discoverProvider = context.read<DiscoverProvider>();
            try {
              await likesProvider.toggleLike(video);
              await discoverProvider.load(FeedSection.favorites);
            } catch (error) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('No se pudo guardar el Me gusta: $error'),
                  ),
                );
              }
            }
          },
        ),
        const SizedBox(height: 16),
        _CustomIconButton(
          value: video.views,
          iconData: Icons.remove_red_eye_outlined,
          semanticLabel: 'Visualizaciones',
        ),
        const SizedBox(height: 16),
        _CustomIconButton(
          value: 0,
          iconData: isMuted ? Icons.volume_off : Icons.volume_up,
          semanticLabel: isMuted
              ? 'Activar sonido del video'
              : 'Silenciar video',
          onPressed: () async {
            final nextMuted = !isMuted;
            onMuteChanged(nextMuted);
            try {
              await context.read<SeasonalAudioProvider>().setVideoHasSound(
                !nextMuted,
              );
            } catch (error) {
              if (context.mounted) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('No se pudo cambiar el audio: $error'),
                  ),
                );
              }
            }
          },
        ),
        const SizedBox(height: 16),
        SpinPerfect(
          infinite: true,
          duration: const Duration(seconds: 5),
          child: const _CustomIconButton(
            value: 0,
            iconData: Icons.play_circle_outline,
            semanticLabel: 'Reproduciendo',
          ),
        ),
      ],
    );
  }
}

class _CustomIconButton extends StatelessWidget {
  const _CustomIconButton({
    required this.value,
    required this.iconData,
    required this.semanticLabel,
    this.iconColor,
    this.onPressed,
  });

  final int value;
  final IconData iconData;
  final String semanticLabel;
  final Color? iconColor;
  final VoidCallback? onPressed;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        IconButton(
          tooltip: semanticLabel,
          onPressed: onPressed,
          icon: Icon(iconData, color: iconColor ?? Colors.white, size: 30),
        ),
        if (value > 0) Text(HumanFormats.humanReadbleNumber(value.toDouble())),
      ],
    );
  }
}
