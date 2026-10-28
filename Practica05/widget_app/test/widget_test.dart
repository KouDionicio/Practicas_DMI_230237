import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:widget_app/config/router/app_router.dart';
import 'package:widget_app/main.dart';

void main() {
  Future<void> openApp(WidgetTester tester) async {
    appRouter.go('/');
    await tester.pumpWidget(const ProviderScope(child: MainApp()));
  }

  testWidgets('home navigates to the buttons demonstration', (tester) async {
    await openApp(tester);

    await tester.tap(find.text('Botones'));
    await tester.pumpAndSettle();

    expect(find.text('Buttons Screen'), findsOneWidget);
    expect(find.byType(ElevatedButton), findsWidgets);
    expect(find.byType(FilledButton), findsWidgets);
  });

  testWidgets('counter updates reactively with Riverpod', (tester) async {
    await openApp(tester);

    await tester.tap(find.text('Riverpod Counter'));
    await tester.pumpAndSettle();
    expect(find.text('Valor: 5'), findsOneWidget);

    await tester.tap(find.byIcon(Icons.add));
    await tester.pump();
    expect(find.text('Valor: 6'), findsOneWidget);
  });

  testWidgets('theme screen can change the selected color', (tester) async {
    await openApp(tester);
    await tester.scrollUntilVisible(find.text('Cambiar tema'), 250);
    await tester.tap(find.text('Cambiar tema'));
    await tester.pumpAndSettle();

    expect(find.text('Theme changer'), findsOneWidget);
    final visibleColors = tester
        .widgetList<RadioListTile<int>>(find.byType(RadioListTile<int>))
        .toList();
    final selectedIndex = visibleColors.last.value;
    await tester.tap(find.text('Este color').last);
    await tester.pumpAndSettle();
    expect(find.byType(RadioListTile<int>), findsWidgets);
    expect(
      tester.widget<RadioGroup<int>>(find.byType(RadioGroup<int>)).groupValue,
      selectedIndex,
    );
  });

  testWidgets('animated container changes size after tapping its action', (
    tester,
  ) async {
    await openApp(tester);
    await tester.tap(find.text('Animated container'));
    await tester.pumpAndSettle();

    final initial = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    expect(initial.constraints?.maxWidth, 50);

    await tester.tap(find.byIcon(Icons.play_arrow_rounded));
    await tester.pump(const Duration(milliseconds: 100));
    final animated = tester.widget<AnimatedContainer>(
      find.byType(AnimatedContainer),
    );
    expect(animated.constraints?.maxWidth, greaterThan(50));
  });

  testWidgets('remote card images define loading and error fallbacks', (
    tester,
  ) async {
    await openApp(tester);
    await tester.tap(find.text('Tarjetas'));
    await tester.pumpAndSettle();

    final networkImages = tester
        .widgetList<Image>(find.byType(Image))
        .where((image) => image.image is NetworkImage);
    expect(networkImages, isNotEmpty);
    expect(networkImages.first.loadingBuilder, isNotNull);
    expect(networkImages.first.errorBuilder, isNotNull);
  });
}
