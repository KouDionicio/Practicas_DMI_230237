import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toktik/presentation/widgets/video/video_description.dart';

void main() {
  testWidgets('long descriptions expand and collapse', (tester) async {
    const description =
        'Esta descripción extensa permite comprobar que el usuario puede '
        'consultar el texto completo y volver a la vista previa sin perder '
        'el contexto de la publicación.';
    var isExpanded = false;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) => VideoDescription(
              caption: 'Publicación de prueba',
              description: description,
              isExpanded: isExpanded,
              onExpansionChanged: (value) => setState(() => isExpanded = value),
            ),
          ),
        ),
      ),
    );

    expect(find.text('... más'), findsOneWidget);
    expect(tester.widget<Text>(find.text(description)).maxLines, 3);
    await tester.tap(find.text('... más'));
    await tester.pumpAndSettle();
    expect(find.text('menos'), findsOneWidget);
    expect(find.byType(SingleChildScrollView), findsOneWidget);

    await tester.tap(find.text('menos'));
    await tester.pumpAndSettle();
    expect(find.text('... más'), findsOneWidget);
  });

  testWidgets('short descriptions do not show an expand control', (
    tester,
  ) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: VideoDescription(
            caption: 'Clip',
            description: 'Descripción breve.',
            isExpanded: false,
            onExpansionChanged: _ignoreExpansion,
          ),
        ),
      ),
    );

    expect(find.text('Descripción breve.'), findsOneWidget);
    expect(find.text('... más'), findsNothing);
  });
}

void _ignoreExpansion(bool _) {}
