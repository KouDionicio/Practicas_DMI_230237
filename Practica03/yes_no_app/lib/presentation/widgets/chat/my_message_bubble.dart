import 'package:flutter/material.dart';
import 'package:yes_no_app/domain/entities/message.dart';

class MyMessageBubble extends StatelessWidget {
  final Message message;
  const MyMessageBubble({super.key, required this.message});

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        Container(
          constraints: const BoxConstraints(maxWidth: 300),
          padding: const EdgeInsets.fromLTRB(16, 11, 12, 7),
          decoration: BoxDecoration(
            color: colors.primary,
            boxShadow: [
              BoxShadow(
                color: colors.primary.withValues(alpha: 0.16),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(20),
              topRight: Radius.circular(20),
              bottomLeft: Radius.circular(20),
              bottomRight: Radius.circular(5),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(message.text, style: const TextStyle(color: Colors.white)),
              const SizedBox(height: 3),
              _MessageTime(message: message, color: Colors.white70),
            ],
          ),
        ),
        const SizedBox(height: 10),
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
