import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/config/helpers/human_formats.dart';
import 'package:toktik/domain/entities/video_post.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';
import 'package:toktik/presentation/providers/likes_provider.dart';
import 'package:toktik/presentation/providers/season_provider.dart';
import 'package:toktik/presentation/providers/seasonal_audio_provider.dart';

class VideoButtons extends StatelessWidget {
  const VideoButtons({
    super.key,
    required this.video,
    this.externalVideo,
    required this.isMuted,
    required this.onMuteChanged,
  });

  final VideoPost video;
  final ExternalVideo? externalVideo;
  final bool isMuted;
  final ValueChanged<bool> onMuteChanged;

  @override
  Widget build(BuildContext context) {
    final likesProvider = context.watch<LikesProvider>();
    final season = context.watch<SeasonProvider>().season;
    final isLiked = likesProvider.isLiked(video);

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        _CustomIconButton(
          value: likesProvider.likeCount(video),
          iconColor: season.primaryColor,
          iconData: isLiked ? Icons.favorite : Icons.favorite_border,
          semanticLabel: isLiked ? 'Quitar Me gusta' : 'Me gusta',
          onPressed: () async {
            final discoverProvider = context.read<DiscoverProvider>();
            try {
              if (externalVideo == null) {
                await likesProvider.toggleLike(video);
              } else {
                await likesProvider.toggleExternalLike(externalVideo!);
              }
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
          iconColor: season.primaryColor,
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
          child: _CustomIconButton(
            value: 0,
            iconData: Icons.play_circle_outline,
            semanticLabel: 'Reproduciendo',
            iconColor: season.primaryColor,
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
          icon: Icon(
            iconData,
            color: iconColor ?? Theme.of(context).iconTheme.color,
            size: 30,
          ),
        ),
        if (value > 0) Text(HumanFormats.humanReadbleNumber(value.toDouble())),
      ],
    );
  }
}
