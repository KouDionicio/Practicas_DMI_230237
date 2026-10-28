import 'package:flutter/material.dart';

final Stream<double> _progressStream = Stream.periodic(
  const Duration(milliseconds: 300),
  (tick) => (tick % 101) / 100,
);

class ProgressScreen extends StatelessWidget {
  static const name = 'progress_screen';

  const ProgressScreen({super.key});

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Indicadores de progreso')),
    body: const _ProgressView(),
  );
}

class _ProgressView extends StatelessWidget {
  const _ProgressView();

  @override
  Widget build(BuildContext context) => Center(
    child: SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: const [
          Text('Progreso circular indeterminado'),
          SizedBox(height: 12),
          CircularProgressIndicator(strokeWidth: 3),
          SizedBox(height: 24),
          Text('Progreso circular y lineal determinado'),
          SizedBox(height: 12),
          _ControlledProgressIndicator(),
          SizedBox(height: 24),
          Text('Progreso lineal indeterminado'),
          SizedBox(height: 12),
          LinearProgressIndicator(),
        ],
      ),
    ),
  );
}

class _ControlledProgressIndicator extends StatelessWidget {
  const _ControlledProgressIndicator();

  @override
  Widget build(BuildContext context) => StreamBuilder<double>(
    stream: _progressStream,
    builder: (context, snapshot) {
      final progress = snapshot.data ?? 0.0;
      return Row(
        children: [
          CircularProgressIndicator(value: progress, strokeWidth: 3),
          const SizedBox(width: 20),
          Expanded(child: LinearProgressIndicator(value: progress)),
          const SizedBox(width: 12),
          Text('${(progress * 100).round()}%'),
        ],
      );
    },
  );
}
