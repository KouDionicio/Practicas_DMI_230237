import 'package:flutter_test/flutter_test.dart';
import 'package:cinemapedia/presentation/widgets/movies/triple_tap_tracker.dart';

void main() {
  group('TripleTapTracker', () {
    late DateTime now;
    late TripleTapTracker tracker;

    void advance(int ms) => now = now.add(Duration(milliseconds: ms));

    setUp(() {
      now = DateTime(2026, 1, 1);
      tracker = TripleTapTracker(clock: () => now);
    });

    test('tres pulsaciones rápidas en la misma flecha completan la secuencia', () {
      expect(tracker.registerTap(CarouselDirection.next), isFalse);
      advance(200);
      expect(tracker.registerTap(CarouselDirection.next), isFalse);
      advance(200);
      expect(tracker.registerTap(CarouselDirection.next), isTrue);
    });

    test('el contador se reinicia tras completar la secuencia', () {
      tracker.registerTap(CarouselDirection.previous);
      tracker.registerTap(CarouselDirection.previous);
      expect(tracker.registerTap(CarouselDirection.previous), isTrue);
      expect(tracker.count, equals(0));
      expect(tracker.registerTap(CarouselDirection.previous), isFalse);
      expect(tracker.count, equals(1));
    });

    test('cambiar de dirección reinicia el contador', () {
      tracker.registerTap(CarouselDirection.next);
      tracker.registerTap(CarouselDirection.next);
      expect(tracker.registerTap(CarouselDirection.previous), isFalse);
      expect(tracker.count, equals(1));
      expect(tracker.registerTap(CarouselDirection.previous), isFalse);
      expect(tracker.registerTap(CarouselDirection.previous), isTrue);
    });

    test('pulsaciones lentas no provocan saltos', () {
      tracker.registerTap(CarouselDirection.next);
      advance(700);
      tracker.registerTap(CarouselDirection.next);
      advance(700);
      expect(tracker.registerTap(CarouselDirection.next), isFalse);
      expect(tracker.count, equals(1));
    });

    test('una pausa a mitad de la secuencia la reinicia', () {
      tracker.registerTap(CarouselDirection.next);
      advance(100);
      tracker.registerTap(CarouselDirection.next);
      advance(900);
      expect(tracker.registerTap(CarouselDirection.next), isFalse);
      advance(100);
      tracker.registerTap(CarouselDirection.next);
      advance(100);
      expect(tracker.registerTap(CarouselDirection.next), isTrue);
    });

    test('reset() (seleccionar otra película) borra el progreso', () {
      tracker.registerTap(CarouselDirection.next);
      tracker.registerTap(CarouselDirection.next);
      tracker.reset();
      expect(tracker.registerTap(CarouselDirection.next), isFalse);
      expect(tracker.count, equals(1));
    });
  });
}
