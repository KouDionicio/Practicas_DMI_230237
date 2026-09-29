import 'dart:math';

import 'package:flutter/material.dart';

import 'package:yes_no_app/config/helpers/get_yes_no_answer.dart';
import 'package:yes_no_app/domain/entities/message.dart';

class ChatProvider extends ChangeNotifier {
  ChatProvider({Random? random}) : _random = random ?? Random();

  final ScrollController chatScrollController = ScrollController();
  final GetYesNoAnswer getYesNoAnswer = GetYesNoAnswer();
  final Random _random;

  final List<Message> messageList = [
    Message(
      text: '¡Hola, ARMY! Este chat tiene la energía de Jungkook, V y RM. Haz una pregunta y BT21 te acompaña con la respuesta.',
      fromWho: FromWho.hers,
    ),
  ];
  bool isReplying = false;

  Future<void> sendMessage(String text) async {
    final cleanText = text.trim();
    if (cleanText.isEmpty) return;

    messageList.add(Message(text: cleanText, fromWho: FromWho.me));
    notifyListeners();
    _scrollToBottom();

    if (cleanText.endsWith('?')) {
      await herReply();
    }
  }

  Future<void> herReply() async {
    isReplying = true;
    notifyListeners();

    try {
      final answer = await getYesNoAnswer.getAnswer(_selectAnswer());
      messageList.add(
        Message(
          text: answer.text,
          imageUrl: bt21GifFor(answer.answerKind!),
          fromWho: FromWho.hers,
          answerKind: answer.answerKind,
        ),
      );
    } catch (_) {
      messageList.add(
        Message(
          text: 'No pude consultar la API. Inténtalo de nuevo en un momento.',
          fromWho: FromWho.hers,
        ),
      );
    } finally {
      isReplying = false;
      notifyListeners();
      _scrollToBottom();
    }
  }

  AnswerKind _selectAnswer() {
    return weightedAnswerForRoll(_random.nextInt(100));
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!chatScrollController.hasClients) return;
      chatScrollController.animateTo(
        chatScrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    });
  }

  @override
  void dispose() {
    chatScrollController.dispose();
    super.dispose();
  }
}

String bt21GifFor(AnswerKind answer) => switch (answer) {
  AnswerKind.yes => 'https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExbHM0bXhmczczaTBuZDVicDc5OXlrMG9qYmNnNGp0dWQ2cnA3c294YiZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/P83JV3ctyuBcOjOIDa/giphy.webp',
  AnswerKind.no => 'https://media0.giphy.com/media/v1.Y2lkPTc5MGI3NjExMW1jYW5rMWYzMmM3cWY2YXNpNnU5Z2pydmdvMnV5ZHJ1cXhva3RmdSZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/Qe8VvmxsngxBDZ5n3b/giphy.webp',
  AnswerKind.maybe => 'https://media2.giphy.com/media/v1.Y2lkPTc5MGI3NjExZG55dG8wdzBuY2l4MHM0Zndqa240cnJsdGhxMnVyMnF2aXFmdDQ5biZlcD12MV9pbnRlcm5hbF9naWZfYnlfaWQmY3Q9Zw/fQ77KoM6GPYzTd8MSo/giphy.webp',
};

AnswerKind weightedAnswerForRoll(int roll) {
  assert(roll >= 0 && roll < 100);
  if (roll < 40) return AnswerKind.yes;
  if (roll < 80) return AnswerKind.no;
  return AnswerKind.maybe;
}
