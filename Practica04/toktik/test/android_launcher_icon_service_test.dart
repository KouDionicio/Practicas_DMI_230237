import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toktik/domain/entities/season.dart';
import 'package:toktik/infrastructure/services/android_launcher_icon_service.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const channel = MethodChannel('toktik/launcher_icon');

  tearDown(() {
    debugDefaultTargetPlatformOverride = null;
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, null);
  });

  test('sends the exact season names to the native launcher channel', () async {
    debugDefaultTargetPlatformOverride = TargetPlatform.android;
    final calls = <MethodCall>[];
    TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
        .setMockMethodCallHandler(channel, (call) async {
          calls.add(call);
          return null;
        });

    final service = AndroidLauncherIconService();
    for (final season in Season.values) {
      await service.setSeason(season);
    }

    expect(calls.map((call) => call.method), everyElement('setSeason'));
    expect(calls.map((call) => (call.arguments as Map)['season']), [
      'normal',
      'halloween',
      'christmas',
      'valentines',
    ]);
  });
}
