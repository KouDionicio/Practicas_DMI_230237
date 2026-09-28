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
      text: '¡Hola! Pregúntame algo y te responderé con un sí, un no o un tal vez.',
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
      final herMessage = await getYesNoAnswer.getAnswer(_selectAnswer());
      messageList.add(herMessage);
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

AnswerKind weightedAnswerForRoll(int roll) {
  assert(roll >= 0 && roll < 100);
  if (roll < 40) return AnswerKind.yes;
  if (roll < 80) return AnswerKind.no;
  return AnswerKind.maybe;
}