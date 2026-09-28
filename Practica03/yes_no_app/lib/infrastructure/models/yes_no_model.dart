import 'package:yes_no_app/domain/entities/message.dart';

class YesNoModel {
  final String answer;
  final String image;
  final String forced;

  YesNoModel({required this.answer, required this.image, required this.forced});

  factory YesNoModel.fromJson(Map<String, dynamic> json) => YesNoModel(
    answer: json['answer'],
    image: json['image'],
    forced: json['forced'] ?? '',
  );

  Map<String, dynamic> toJson() => {
    'answer': answer,
    'image': image,
    'forced': forced,
  };

  Message toMessageEntity() => Message(
    text: answer == 'yes' ? 'Sí' : 'No',
    imageUrl: image,
    fromWho: FromWho.hers,
  );
}
