import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:yes_no_app/domain/entities/message.dart';

import 'package:yes_no_app/presentation/widgets/chat/my_message_bubble.dart';
import 'package:yes_no_app/presentation/widgets/chat/her_message_bubble.dart';
import 'package:yes_no_app/presentation/providers/chat_provider.dart';
import 'package:yes_no_app/presentation/widgets/chat/shared/message_field_box.dart';

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surface,
        surfaceTintColor: Colors.transparent,
        leadingWidth: 62,
        leading: Padding(
          padding: const EdgeInsets.only(left: 14),
          child: Semantics(
            label: 'Emblema ARMY',
            child: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: CustomPaint(
                size: const Size(22, 24),
                painter: _ArmyMarkPainter(
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
              ),
            ),
          ),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('BTS ARMY', style: Theme.of(context).textTheme.titleLarge),
            Text(
              'Jungkook · V · RM',
              style: TextStyle(
                color: Color(0xFF766C7F),
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
        actions: [
          if (MediaQuery.sizeOf(context).width >= 400)
            const Padding(
              padding: EdgeInsets.only(right: 14),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _MemberAvatar(
                    initials: 'JK',
                    label: 'Jungkook',
                    color: Color(0xFFD87991),
                  ),
                  SizedBox(width: 5),
                  _MemberAvatar(
                    initials: 'V',
                    label: 'V',
                    color: Color(0xFF438C83),
                  ),
                  SizedBox(width: 5),
                  _MemberAvatar(
                    initials: 'RM',
                    label: 'RM',
                    color: Color(0xFF8170A5),
                  ),
                ],
              ),
            ),
        ],
        centerTitle: false,
      ),
      body: const _ChatView(),
    );
  }
}

class _MemberAvatar extends StatelessWidget {
  const _MemberAvatar({
    required this.initials,
    required this.label,
    required this.color,
  });

  final String initials;
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: label,
      child: CircleAvatar(
        radius: 14,
        backgroundColor: color,
        child: Text(
          initials,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 9,
            fontWeight: FontWeight.w800,
          ),
        ),
      ),
    );
  }
}

class _ArmyMarkPainter extends CustomPainter {
  const _ArmyMarkPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color;
    final leftPanel = Path()
      ..moveTo(size.width * 0.08, size.height * 0.06)
      ..lineTo(size.width * 0.43, size.height * 0.2)
      ..lineTo(size.width * 0.43, size.height * 0.8)
      ..lineTo(size.width * 0.08, size.height * 0.94)
      ..close();
    final rightPanel = Path()
      ..moveTo(size.width * 0.92, size.height * 0.06)
      ..lineTo(size.width * 0.57, size.height * 0.2)
      ..lineTo(size.width * 0.57, size.height * 0.8)
      ..lineTo(size.width * 0.92, size.height * 0.94)
      ..close();

    canvas.drawPath(leftPanel, paint);
    canvas.drawPath(rightPanel, paint);
  }

  @override
  bool shouldRepaint(covariant _ArmyMarkPainter oldDelegate) =>
      oldDelegate.color != color;
}

class _ChatView extends StatelessWidget {
  const _ChatView();

  @override
  Widget build(BuildContext context) {
    final chatProvider = context.watch<ChatProvider>();

    final colors = Theme.of(context).colorScheme;

    return SafeArea(
      child: Column(
        children: [
          Expanded(
            child: ListView.builder(
              controller: chatProvider.chatScrollController,
              padding: const EdgeInsets.fromLTRB(16, 20, 16, 8),
              itemCount:
                  chatProvider.messageList.length +
                  (chatProvider.isReplying ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == chatProvider.messageList.length) {
                  return Align(
                    alignment: Alignment.centerLeft,
                    child: Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 12,
                      ),
                      decoration: BoxDecoration(
                        color: colors.secondaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: const SizedBox(
                        width: 38,
                        height: 16,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _TypingDot(delay: 0),
                            _TypingDot(delay: 150),
                            _TypingDot(delay: 300),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                final message = chatProvider.messageList[index];
                return message.fromWho == FromWho.hers
                    ? HerMessageBubble(message: message)
                    : MyMessageBubble(message: message);
              },
            ),
          ),
          MessageFieldBox(onValue: chatProvider.sendMessage),
        ],
      ),
    );
  }
}

class _TypingDot extends StatefulWidget {
  const _TypingDot({required this.delay});

  final int delay;

  @override
  State<_TypingDot> createState() => _TypingDotState();
}

class _TypingDotState extends State<_TypingDot>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(
          vsync: this,
          duration: const Duration(milliseconds: 550),
        )..repeat(
          reverse: true,
          period: Duration(milliseconds: 550 + widget.delay),
        );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => FadeTransition(
    opacity: Tween<double>(begin: 0.3, end: 1).animate(_controller),
    child: CircleAvatar(
      radius: 3,
      backgroundColor: Theme.of(context).colorScheme.tertiary,
    ),
  );
}
