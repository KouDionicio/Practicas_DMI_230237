import 'package:flutter/material.dart';
import 'package:yes_no_app/domain/entities/message.dart';

class HerMessageBubble extends StatelessWidget {
  final Message message;

  const HerMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.fromLTRB(16, 11, 12, 7),
          decoration: BoxDecoration(
            color: colors.secondaryContainer,
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(5),
              bottomRight: Radius.circular(20),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                message.text,
                style: TextStyle(
                  color: colors.onSecondaryContainer,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 3),
              _MessageTime(message: message, color: colors.onSurfaceVariant),
            ],
          ),
        ),
        if (message.imageUrl != null) ...[
          const SizedBox(height: 6),
          _ImageBubble(message.imageUrl!),
        ],
        const SizedBox(height: 12),
      ],
    );
  }
}

class _MessageTime extends StatelessWidget {
  const _MessageTime({required this.message, required this.color});

  final Message message;
  final Color color;

  @override
  Widget build(BuildContext context) {
    final time = message.sentAt;
    final formatted =
        '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}';
    return Text(formatted, style: TextStyle(fontSize: 10, color: color));
  }
}

class _ImageBubble extends StatelessWidget {
  final String imageUrl;
  const _ImageBubble(this.imageUrl);

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(16),
      child: Image.network(
        imageUrl,
        width: 260,
        height: 170,
        fit: BoxFit.cover,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return Container(
            width: 260,
            height: 170,
            color: Theme.of(context).colorScheme.secondaryContainer,
            alignment: Alignment.center,
            child: const CircularProgressIndicator(),
          );
        },
        errorBuilder: (context, error, stackTrace) => Container(
          width: 260,
          height: 100,
          color: Theme.of(context).colorScheme.secondaryContainer,
          alignment: Alignment.center,
          child: const Text('No se pudo cargar el GIF'),
        ),
      ),
    );
  }
}
