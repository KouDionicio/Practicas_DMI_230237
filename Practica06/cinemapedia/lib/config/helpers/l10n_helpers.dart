import 'package:flutter/widgets.dart';

import 'package:cinemapedia/config/constants/app_regions.dart';
import 'package:cinemapedia/domain/errors/app_exception.dart';
import 'package:cinemapedia/l10n/app_localizations.dart';

extension LocalizationContext on BuildContext {
  /// Atajo para `AppLocalizations.of(context)`.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

extension AppRegionPresentation on AppRegion {
  /// `Locale` de Flutter: idioma + país (es_MX, ja_JP, ar_EG…).
  Locale get locale => Locale(languageCode, code);

  TextDirection get textDirection => isRtl ? TextDirection.rtl : TextDirection.ltr;

  /// Nombre del país en el idioma actual de la interfaz.
  String localizedName(AppLocalizations l10n) => switch (code) {
        'MX' => l10n.regionMX,
        'US' => l10n.regionUS,
        'DE' => l10n.regionDE,
        'FR' => l10n.regionFR,
        'KR' => l10n.regionKR,
        'JP' => l10n.regionJP,
        'BR' => l10n.regionBR,
        'EG' => l10n.regionEG,
        _ => code,
      };
}

extension AppErrorMessage on AppLocalizations {
  /// Mensaje localizado y comprensible para cualquier error de carga.
  String describeError(Object? error) => switch (error) {
        NetworkException() => errorConnection,
        UnauthorizedException() => errorUnauthorized,
        ServerException() || NotFoundException() => errorServer,
        _ => errorGeneric,
      };
}
