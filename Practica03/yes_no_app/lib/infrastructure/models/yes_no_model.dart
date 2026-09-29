import 'package:yes_no_app/domain/entities/message.dart';

class YesNoModel {
  final String answer;
  final String image;
  final bool forced;

  YesNoModel({required this.answer, required this.image, required this.forced});

  factory YesNoModel.fromJson(Map<String, dynamic> json) => YesNoModel(
        answer: json['answer'] as String,
        image: json['image'] as String,
        forced: json['forced'] as bool? ?? false,
      );

  Map<String, dynamic> toJson() => {
        'answer': answer,
        'image': image,
        'forced': forced,
      };

  Message toMessageEntity() {
    final answerKind = switch (answer) {
      'yes' => AnswerKind.yes,
      'no' => AnswerKind.no,
      _ => AnswerKind.maybe,
    };
    final label = switch (answerKind) {
      AnswerKind.yes => 'Sí',
      AnswerKind.no => 'No',
      AnswerKind.maybe => 'Tal vez',
    };

    return Message(
      text: label,
      imageUrl: image,
      fromWho: FromWho.hers,
      answerKind: answerKind,
    );
  }
}
