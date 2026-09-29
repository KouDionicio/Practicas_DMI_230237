import 'package:flutter_test/flutter_test.dart';
import 'package:yes_no_app/domain/entities/message.dart';
import 'package:yes_no_app/infrastructure/models/yes_no_model.dart';
import 'package:yes_no_app/main.dart';
import 'package:yes_no_app/presentation/providers/chat_provider.dart';

void main() {
  testWidgets('muestra la identidad BTS ARMY del chat', (tester) async {
    await tester.pumpWidget(const MyApp());

    expect(find.text('BTS ARMY'), findsOneWidget);
    expect(find.text('Jungkook · V · RM'), findsOneWidget);
    expect(find.byTooltip('Jungkook'), findsOneWidget);
    expect(find.byTooltip('V'), findsOneWidget);
    expect(find.byTooltip('RM'), findsOneWidget);
    expect(find.text('Pregúntale algo a BTS…'), findsOneWidget);
    expect(find.textContaining('¡Hola, ARMY!'), findsOneWidget);
  });

  test('cada respuesta elige un GIF BT21 distinto', () {
    final gifUrls = AnswerKind.values.map(bt21GifFor).toList();

    expect(gifUrls.toSet(), hasLength(3));
    expect(gifUrls, everyElement(contains('giphy.com/media/')));
    expect(gifUrls, everyElement(endsWith('/giphy.webp')));
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
