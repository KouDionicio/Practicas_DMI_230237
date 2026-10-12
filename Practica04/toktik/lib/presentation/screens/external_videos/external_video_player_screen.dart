import 'package:flutter/material.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/presentation/widgets/video/external_video_player.dart';

class ExternalVideoPlayerScreen extends StatelessWidget {
  const ExternalVideoPlayerScreen({super.key, required this.video});

  final ExternalVideo video;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(video.title, maxLines: 1)),
    body: ExternalVideoPlayer(video: video),
  );
}
