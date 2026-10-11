import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:toktik/presentation/providers/season_provider.dart';
import 'package:toktik/presentation/providers/seasonal_audio_provider.dart';

class SeasonSettingsSheet extends StatelessWidget {
  const SeasonSettingsSheet({super.key});

  @override
  Widget build(BuildContext context) {
    final seasons = context.watch<SeasonProvider>();
    final ambience = context.watch<SeasonalAudioProvider>();

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Tema de temporada',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 4),
            Text('Actual: ${seasons.season.label}'),
            const SizedBox(height: 16),
            SegmentedButton<SeasonMode>(
              segments: const [
                ButtonSegment(
                  value: SeasonMode.automatic,
                  label: Text('Automático'),
                  icon: Icon(Icons.calendar_month),
                ),
                ButtonSegment(
                  value: SeasonMode.manual,
                  label: Text('Manual'),
                  icon: Icon(Icons.tune),
                ),
              ],
              selected: {seasons.mode},
              onSelectionChanged: (selection) async {
                try {
                  await seasons.setMode(selection.first);
                } catch (error) {
                  if (context.mounted) {
                    _showError(context, 'No se pudo guardar el modo: $error');
                  }
                }
              },
            ),
            if (seasons.mode == SeasonMode.manual) ...[
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: Season.values
                    .map(
                      (season) => ChoiceChip(
                        label: Text(season.label),
                        selected: seasons.manualSeason == season,
                        onSelected: (_) async {
                          try {
                            await seasons.setManualSeason(season);
                          } catch (error) {
                            if (context.mounted) {
                              _showError(
                                context,
                                'No se pudo guardar la temporada: $error',
                              );
                            }
                          }
                        },
                      ),
                    )
                    .toList(),
              ),
            ],
            if (seasons.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'No se pudieron leer o guardar algunas preferencias: '
                  '${seasons.error}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            if (ambience.error != null)
              Padding(
                padding: const EdgeInsets.only(top: 8),
                child: Text(
                  'No se pudo sincronizar el audio: ${ambience.error}',
                  style: TextStyle(color: Theme.of(context).colorScheme.error),
                ),
              ),
            const Divider(height: 28),
            Row(
              children: [
                Expanded(
                  child: Text(
                    ambience.hasAudio
                        ? 'Audio ambiental'
                        : 'Esta temporada no tiene un audio disponible.',
                  ),
                ),
                IconButton(
                  tooltip: ambience.isEnabled
                      ? 'Silenciar ambiente'
                      : 'Reproducir ambiente',
                  onPressed: ambience.hasAudio
                      ? () async {
                          try {
                            await ambience.toggleEnabled();
                          } catch (error) {
                            if (context.mounted) {
                              _showError(
                                context,
                                'No se pudo reproducir el audio: $error',
                              );
                            }
                          }
                        }
                      : null,
                  icon: Icon(
                    ambience.isEnabled && ambience.hasAudio
                        ? Icons.volume_up
                        : Icons.volume_off,
                  ),
                ),
              ],
            ),
            const Text(
              'El icono mostrado pertenece a la interfaz; no cambia el icono '
              'nativo del launcher.',
              style: TextStyle(fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }

  static void _showError(BuildContext context, String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }
}
