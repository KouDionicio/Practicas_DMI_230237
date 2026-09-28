import 'package:dio/dio.dart';
import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/infrastructure/models/yes_no_model.dart';

class GetYesNoAnswer {
  final _dio = Dio();

  Future<Message> getAnswer(AnswerKind answer) async {
    final forcedAnswer = switch (answer) {
      AnswerKind.yes => 'yes',
      AnswerKind.no => 'no',
      AnswerKind.maybe => 'maybe',
    };
    final response = await _dio.get<Map<String, dynamic>>(
      'https://yesno.wtf/api',
      queryParameters: {'force': forcedAnswer},
    );

    final data = response.data;
    if (data == null) {
      throw const FormatException('La API devolvió una respuesta vacía.');
    }

    return YesNoModel.fromJson(data).toMessageEntity();
  }
}