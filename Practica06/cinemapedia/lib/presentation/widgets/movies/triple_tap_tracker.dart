/// Dirección de una flecha del carrusel.
enum CarouselDirection { previous, next }

/// Detecta tres pulsaciones consecutivas sobre la misma flecha.
///
/// Reglas:
///  * Cada pulsación debe llegar como máximo [window] después de la anterior;
///    si el usuario toca despacio, el contador vuelve a empezar.
///  * Cambiar de dirección reinicia el contador.
///  * [reset] debe llamarse cuando el usuario elige otra película por otro
///    medio (deslizar, tocar un póster o un indicador) o cambia la lista.
///
/// Es Dart puro (sin Flutter) para poder probarlo de forma aislada.
class TripleTapTracker {
  final Duration window;
  final int requiredTaps;
  final DateTime Function() _now;

  CarouselDirection? _direction;
  DateTime? _lastTap;
  int _count = 0;

  TripleTapTracker({
    this.window = const Duration(milliseconds: 650),
    this.requiredTaps = 3,
    DateTime Function()? clock,
  }) : _now = clock ?? DateTime.now;

  int get count => _count;
  CarouselDirection? get direction => _direction;

  /// Registra una pulsación. Devuelve `true` cuando completa la secuencia;
  /// en ese caso el contador se reinicia.
  bool registerTap(CarouselDirection direction) {
    final now = _now();
    final isConsecutive = _direction == direction &&
        _lastTap != null &&
        now.difference(_lastTap!) <= window;

    _count = isConsecutive ? _count + 1 : 1;
    _direction = direction;
    _lastTap = now;

    if (_count >= requiredTaps) {
      reset();
      return true;
    }
    return false;
  }

  void reset() {
    _count = 0;
    _direction = null;
    _lastTap = null;
  }
}
