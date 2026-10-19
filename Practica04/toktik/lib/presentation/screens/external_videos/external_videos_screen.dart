import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/presentation/providers/external_video_search_provider.dart';
import 'package:toktik/presentation/screens/external_videos/external_video_player_screen.dart';

class ExternalVideosScreen extends StatefulWidget {
  const ExternalVideosScreen({super.key});

  @override
  State<ExternalVideosScreen> createState() => _ExternalVideosScreenState();
}

class _ExternalVideosScreenState extends State<ExternalVideosScreen> {
  final _queryController = TextEditingController();
  final _resultsController = ScrollController();

  @override
  void initState() {
    super.initState();
    _resultsController.addListener(() {
      if (_resultsController.hasClients &&
          _resultsController.position.extentAfter < 500) {
        context.read<ExternalVideoSearchProvider>().loadMore();
      }
    });
  }

  @override
  void dispose() {
    _queryController.dispose();
    _resultsController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final search = context.watch<ExternalVideoSearchProvider>();
    return Scaffold(
      appBar: AppBar(title: const Text('Videos externos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
            child: DropdownButtonFormField<VideoSource>(
              initialValue: search.source,
              decoration: const InputDecoration(labelText: 'Proveedor'),
              items: VideoSource.values
                  .where((source) => source != VideoSource.local)
                  .map(
                    (source) => DropdownMenuItem(
                      value: source,
                      child: Text(_sourceName(source)),
                    ),
                  )
                  .toList(),
              onChanged: (source) {
                if (source != null) search.selectSource(source);
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: TextField(
              controller: _queryController,
              textInputAction: TextInputAction.search,
              onSubmitted: search.search,
              decoration: InputDecoration(
                labelText: 'Buscar videos',
                suffixIcon: IconButton(
                  tooltip: 'Buscar',
                  onPressed: () => search.search(_queryController.text),
                  icon: const Icon(Icons.search),
                ),
              ),
            ),
          ),
          if (search.environmentFileLoadFailed)
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                'No se pudo leer .env. Revisa el formato del archivo; '
                'los proveedores sin configuración mostrarán un error '
                'específico y el feed local seguirá disponible.',
                textAlign: TextAlign.center,
              ),
            ),
          if (search.isLoading) const LinearProgressIndicator(),
          if (search.error != null)
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  Text(
                    'No se pudo consultar ${_sourceName(search.source)}: '
                    '${search.error}',
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),
                  FilledButton.icon(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.video_library),
                    label: const Text('Volver a los videos locales'),
                  ),
                ],
              ),
            ),
          if (!search.isLoading &&
              search.error == null &&
              search.results.isEmpty)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Text('Busca un video para ver los resultados.'),
            ),
          Expanded(
            child: ListView.builder(
              controller: _resultsController,
              itemCount:
                  search.results.length +
                  (search.hasMore || search.isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == search.results.length) {
                  return search.isLoadingMore
                      ? const Padding(
                          padding: EdgeInsets.all(16),
                          child: Center(child: CircularProgressIndicator()),
                        )
                      : const SizedBox(height: 48);
                }
                final video = search.results[index];
                return ListTile(
                  leading: video.thumbnailUrl.isEmpty
                      ? const SizedBox(
                          width: 80,
                          child: Icon(Icons.ondemand_video),
                        )
                      : Image.network(
                          video.thumbnailUrl,
                          width: 80,
                          height: 56,
                          fit: BoxFit.cover,
                          errorBuilder: (_, _, _) =>
                              const Icon(Icons.broken_image),
                        ),
                  title: Text(video.title, maxLines: 2),
                  subtitle: Text(
                    video.description,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: video.durationSeconds == null
                      ? null
                      : Text(_formatDuration(video.durationSeconds!)),
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => ExternalVideoPlayerScreen(video: video),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  static String _sourceName(VideoSource source) => switch (source) {
    VideoSource.local => 'Local',
    VideoSource.youtube => 'YouTube',
    VideoSource.vimeo => 'Vimeo',
    VideoSource.peertube => 'PeerTube',
  };

  static String _formatDuration(int seconds) {
    final duration = Duration(seconds: seconds);
    final minutes = duration.inMinutes.remainder(60).toString().padLeft(2, '0');
    final remainingSeconds = duration.inSeconds
        .remainder(60)
        .toString()
        .padLeft(2, '0');
    if (duration.inHours > 0) {
      return '${duration.inHours}:$minutes:$remainingSeconds';
    }
    return '${duration.inMinutes}:$remainingSeconds';
  }
}
