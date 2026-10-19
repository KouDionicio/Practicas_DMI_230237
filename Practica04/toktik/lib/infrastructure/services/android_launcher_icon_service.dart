import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:toktik/domain/entities/season.dart';

class AndroidLauncherIconService {
  static const _channel = MethodChannel('toktik/launcher_icon');

  Future<void> setSeason(Season season) async {
    if (defaultTargetPlatform != TargetPlatform.android) return;
    await _channel.invokeMethod<void>(
      'setSeason',
      {'season': season.name},
    );
  }
}
