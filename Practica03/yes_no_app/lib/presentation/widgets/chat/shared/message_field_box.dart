import 'package:flutter/material.dart';

class MessageFieldBox extends StatefulWidget {
  const MessageFieldBox({super.key, required this.onValue});

  final ValueChanged<String> onValue;

  @override
  State<MessageFieldBox> createState() => _MessageFieldBoxState();
}

class _MessageFieldBoxState extends State<MessageFieldBox> {
  final _textController = TextEditingController();
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _textController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _textController.text.trim();
    if (text.isEmpty) return;
    _textController.clear();
    widget.onValue(text);
  }

  @override
  Widget build(BuildContext context) {
    final colors = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 8, 14, 14),
      child: TextField(
        controller: _textController,
        focusNode: _focusNode,
        textCapitalization: TextCapitalization.sentences,
        textInputAction: TextInputAction.send,
        onSubmitted: (_) => _sendMessage(),
        onTapOutside: (_) => _focusNode.unfocus(),
        decoration: InputDecoration(
          hintText: 'Pregúntale algo a BTS…',
          filled: true,
          fillColor: colors.surfaceContainerHighest,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 14,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(30),
            borderSide: BorderSide.none,
          ),
          suffixIcon: Padding(
            padding: const EdgeInsets.all(5),
            child: IconButton.filled(
              tooltip: 'Enviar mensaje',
              onPressed: _sendMessage,
              icon: const Icon(Icons.arrow_upward_rounded),
            ),
          ),
        ),
      ),
    );
  }
}
