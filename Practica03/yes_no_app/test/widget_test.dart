import 'package:flutter_test/flutter_test.dart';
import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/infrastructure/models/yes_no_model.dart';
import 'package:yes_no_app/main.dart';
import 'package:yes_no_app/presentation/providers/chat_provider.dart';

void main() {
  testWidgets('muestra el chat de respuestas automáticas', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('Sí, No, Maybe'), findsOneWidget);
    expect(find.text('Escribe una pregunta…'), findsOneWidget);
    expect(find.textContaining('Pregúntame algo'), findsOneWidget);
  });

  test('la selección respeta exactamente 40/40/20 en 100 resultados', () {
    final results = List.generate(100, weightedAnswerForRoll);

    expect(results.where((answer) => answer == AnswerKind.yes), hasLength(40));
    expect(results.where((answer) => answer == AnswerKind.no), hasLength(40));
    expect(
      results.where((answer) => answer == AnswerKind.maybe),
      hasLength(20),
    );
  });

  test('el modelo de la API convierte las tres respuestas', () {
    final messages = ['yes', 'no', 'maybe'].map(
      (answer) => YesNoModel.fromJson({
        'answer': answer,
        'image': 'https://yesno.wtf/assets/$answer/1.gif',
        'forced': true,
      }).toMessageEntity(),
    );

    expect(messages.map((message) => message.text), ['Sí', 'No', 'Tal vez']);
    expect(messages.map((message) => message.answerKind), [
      AnswerKind.yes,
      AnswerKind.no,
      AnswerKind.maybe,
    ]);
  });
}