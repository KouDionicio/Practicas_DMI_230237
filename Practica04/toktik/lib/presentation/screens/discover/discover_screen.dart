import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/presentation/providers/discover_provider.dart';
import 'package:toktik/presentation/providers/likes_provider.dart';
import 'package:toktik/presentation/providers/season_provider.dart';
import 'package:toktik/presentation/providers/seasonal_audio_provider.dart';
import 'package:toktik/presentation/screens/external_videos/external_videos_screen.dart';
import 'package:toktik/presentation/widgets/season_settings_sheet.dart';
import 'package:toktik/presentation/widgets/shared/video_scrollable_view.dart';

class DiscoverScreen extends StatefulWidget {
  const DiscoverScreen({super.key});

  @override
  State<DiscoverScreen> createState() => _DiscoverScreenState();
}

class _DiscoverScreenState extends State<DiscoverScreen> {
  final PageController _sectionController = PageController();
  int _activeSection = 0;
  bool _isMuted = true;
  bool _isExternalSearchOpen = false;

  @override
  void dispose() {
    _sectionController.dispose();
    super.dispose();
  }

  void _setMuted(bool value) => setState(() => _isMuted = value);

  Future<void> _showSettings() async {
    await showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      builder: (_) => const SeasonSettingsSheet(),
    );
  }

  Future<void> _openExternalVideos() async {
    setState(() => _isExternalSearchOpen = true);
    final audio = context.read<SeasonalAudioProvider>();
    final navigator = Navigator.of(context);
    try {
      await audio.setVideoHasSound(true);
      await navigator.push(
        MaterialPageRoute<void>(builder: (_) => const ExternalVideosScreen()),
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('No se pudo abrir la búsqueda: $error')),
        );
      }
    } finally {
      if (mounted) setState(() => _isExternalSearchOpen = false);
      try {
        await audio.setVideoHasSound(false);
      } catch (error) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('No se pudo restaurar el audio: $error')),
          );
        }
      }
    }
  }

  Future<void> _toggleAmbientAudio() async {
    try {
      await context.read<SeasonalAudioProvider>().toggleEnabled();
    } catch (error) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('No se pudo cambiar el audio ambiental: $error'),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final season = context.watch<SeasonProvider>().season;
    final audio = context.watch<SeasonalAudioProvider>();
    final likesError = context.watch<LikesProvider>().error;
    final compactHeader = MediaQuery.sizeOf(context).width < 480;
    final sectionTabs = [
      for (var index = 0; index < FeedSection.values.length; index++)
        TextButton(
          onPressed: () => _sectionController.animateToPage(
            index,
            duration: const Duration(milliseconds: 260),
            curve: Curves.easeOut,
          ),
          style: TextButton.styleFrom(
            foregroundColor: _activeSection == index
                ? Colors.white
                : Colors.white70,
            textStyle: TextStyle(
              fontWeight: _activeSection == index
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          child: Text(switch (FeedSection.values[index]) {
            FeedSection.discover => 'Discover',
            FeedSection.forYou => 'For You',
            FeedSection.favorites => 'Favorites',
          }),
        ),
    ];
    final headerActions = [
      IconButton(
        tooltip: 'Configuración de temporada',
        onPressed: _showSettings,
        icon: Image.asset(
          season.iconAsset,
          width: 32,
          height: 32,
          fit: BoxFit.contain,
          errorBuilder: (_, error, _) => const Icon(Icons.palette),
        ),
      ),
      PopupMenuButton<_DiscoverMenuAction>(
        tooltip: 'Más opciones',
        onSelected: (action) {
          switch (action) {
            case _DiscoverMenuAction.externalVideos:
              _openExternalVideos();
            case _DiscoverMenuAction.toggleAmbientAudio:
              _toggleAmbientAudio();
          }
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: _DiscoverMenuAction.externalVideos,
            child: ListTile(
              leading: Icon(Icons.travel_explore),
              title: Text('Buscar videos externos'),
              contentPadding: EdgeInsets.zero,
            ),
          ),
          PopupMenuItem(
            value: _DiscoverMenuAction.toggleAmbientAudio,
            enabled: audio.hasAudio,
            child: ListTile(
              leading: Icon(
                audio.isEnabled ? Icons.music_off : Icons.music_note,
              ),
              title: Text(
                audio.isEnabled
                    ? 'Silenciar audio ambiental'
                    : 'Reproducir audio ambiental',
              ),
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
        icon: Icon(audio.isAudible ? Icons.music_note : Icons.more_vert),
      ),
    ];

    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _sectionController,
            itemCount: FeedSection.values.length,
            onPageChanged: (index) => setState(() => _activeSection = index),
            itemBuilder: (context, index) {
              final section = FeedSection.values[index];
              return _FeedPage(
                key: ValueKey(section),
                section: section,
                isVisible: index == _activeSection && !_isExternalSearchOpen,
                isMuted: _isMuted,
                onMuteChanged: _setMuted,
              );
            },
          ),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(12, 4, 12, 0),
              child: LayoutBuilder(
                builder: (context, constraints) {
                  if (constraints.maxWidth < 480) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SingleChildScrollView(
                          scrollDirection: Axis.horizontal,
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: sectionTabs,
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: headerActions,
                        ),
                      ],
                    );
                  }

                  return Row(
                    children: [
                      ...sectionTabs,
                      const Spacer(),
                      ...headerActions,
                    ],
                  );
                },
              ),
            ),
          ),
          if (likesError != null)
            Positioned(
              top:
                  MediaQuery.paddingOf(context).top +
                  (compactHeader ? 112 : 58),
              left: 12,
              right: 12,
              child: Card(
                color: Theme.of(context).colorScheme.errorContainer,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 4,
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: Text(
                          'No se pudieron cargar tus Me gusta: $likesError',
                        ),
                      ),
                      TextButton(
                        onPressed: context.read<LikesProvider>().load,
                        child: const Text('Reintentar'),
                      ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}

enum _DiscoverMenuAction { externalVideos, toggleAmbientAudio }

class _FeedPage extends StatelessWidget {
  const _FeedPage({
    super.key,
    required this.section,
    required this.isVisible,
    required this.isMuted,
    required this.onMuteChanged,
  });

  final FeedSection section;
  final bool isVisible;
  final bool isMuted;
  final ValueChanged<bool> onMuteChanged;

  @override
  Widget build(BuildContext context) {
    final discover = context.watch<DiscoverProvider>();
    final videos = discover.videosFor(section);
    final externalVideos = discover.externalVideosFor(section);

    if (discover.isLoading(section) && videos.isEmpty) {
      return const Center(child: CircularProgressIndicator(strokeWidth: 2));
    }
    final error = discover.errorFor(section);
    if (error != null && videos.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('No se pudieron cargar estos videos.'),
            Padding(
              padding: const EdgeInsets.all(8),
              child: Text('$error', textAlign: TextAlign.center),
            ),
            TextButton(
              onPressed: () => discover.load(section),
              child: const Text('Reintentar'),
            ),
          ],
        ),
      );
    }
    if (videos.isEmpty && externalVideos.isEmpty) {
      return Center(
        child: Text(
          section == FeedSection.favorites
              ? 'Aún no tienes videos favoritos.'
              : 'No hay videos disponibles.',
        ),
      );
    }
    return VideoScrollableView(
      videos: videos,
      externalVideos: externalVideos,
      isVisible: isVisible,
      isMuted: isMuted,
      onMuteChanged: onMuteChanged,
    );
  }
}
