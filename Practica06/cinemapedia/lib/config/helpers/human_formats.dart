import 'package:intl/intl.dart';


class HumanFormats {

  /// Número compacto (1.2K, 1,2 mil, 1.2만…). [locale] usa el idioma actual
  /// de la interfaz; por defecto se conserva el formato inglés original.
  static String number( double number, [ int decimals = 0, String locale = 'en' ] ) {

    final formattedNumber = NumberFormat.compactCurrency(
      decimalDigits: decimals,
      symbol: '',
      locale: locale
    ).format(number);

    return formattedNumber;
  }

  /// Número decimal con los separadores del idioma (7.8 / 7,8 / ٧٫٨).
  static String decimal( double number, String locale, [ int decimals = 1 ] ) {
    final format = NumberFormat.decimalPattern(locale)
      ..minimumFractionDigits = decimals
      ..maximumFractionDigits = decimals;
    return format.format(number);
  }

  /// Entero con los dígitos del idioma (útil en árabe: ١٠ en lugar de 10).
  static String integer( int number, String locale ) =>
      NumberFormat.decimalPattern(locale).format(number);

  /// Fecha media localizada (12 oct 2026, 2026年10月12日…).
  static String date( DateTime date, String locale ) =>
      DateFormat.yMMMd(locale).format(date);

  /// Fecha corta del día para subtítulos (lun, 9 nov).
  static String shortDay( DateTime date, String locale ) =>
      DateFormat.MMMEd(locale).format(date);

}
