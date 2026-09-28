
enum FromWho { me, hers }

enum AnswerKind { yes, no, maybe }

class Message {
  final String text;
  final String? imageUrl;
  final FromWho fromWho;
  final DateTime sentAt;
  final AnswerKind? answerKind;

  Message({
    required this.text,
    this.imageUrl,
    required this.fromWho,
    DateTime? sentAt,
    this.answerKind,
  }) : sentAt = sentAt ?? DateTime.now();
}