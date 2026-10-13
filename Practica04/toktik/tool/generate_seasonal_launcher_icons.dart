import 'dart:io';

const seasons = [
  (name: 'normal', config: 'pubspec.yaml', background: '#101020'),
  (
    name: 'halloween',
    config: 'launcher_icons_halloween.yaml',
    background: '#160D24',
  ),
  (
    name: 'christmas',
    config: 'launcher_icons_christmas.yaml',
    background: '#071A12',
  ),
  (
    name: 'valentines',
    config: 'launcher_icons_valentines.yaml',
    background: '#260F1A',
  ),
];

Future<void> main() async {
  if (!File('pubspec.yaml').existsSync()) {
    throw StateError('Run this script from the Practica04/toktik directory.');
  }

  for (final season in seasons) {
    final result = await Process.run('dart', [
      'run',
      'flutter_launcher_icons',
      '-f',
      season.config,
    ]);
    stdout.write(result.stdout);
    stderr.write(result.stderr);
    if (result.exitCode != 0) {
      throw ProcessException(
        'dart',
        ['run', 'flutter_launcher_icons', '-f', season.config],
        'Icon generation failed for ${season.name}.',
        result.exitCode,
      );
    }

    final resources = Directory('android/app/src/main/res');
    await for (final entity in resources.list()) {
      if (entity is! Directory ||
          !RegExp(r'^drawable-.+dpi$').hasMatch(entity.uri.pathSegments.last)) {
        continue;
      }
      final source = File('${entity.path}/ic_launcher_foreground.png');
      if (source.existsSync()) {
        await source.copy(
          '${entity.path}/ic_launcher_foreground_${season.name}.png',
        );
      }
    }

    final iconName = 'ic_launcher_${season.name}';
    final foregroundName = 'ic_launcher_foreground_${season.name}';
    final xml =
        '''
<?xml version="1.0" encoding="utf-8"?>
<adaptive-icon xmlns:android="http://schemas.android.com/apk/res/android">
  <background android:drawable="@color/ic_launcher_background_${season.name}"/>
  <foreground>
      <inset
          android:drawable="@drawable/$foregroundName"
          android:inset="16%" />
  </foreground>
</adaptive-icon>
''';
    await File('android/app/src/main/res/mipmap-anydpi-v26/$iconName.xml')
        .writeAsString(xml);
  }

  await File('android/app/src/main/res/values/colors.xml').writeAsString('''
<?xml version="1.0" encoding="utf-8"?>
<resources>
    <color name="ic_launcher_background">#101020</color>
    <color name="ic_launcher_background_normal">#101020</color>
    <color name="ic_launcher_background_halloween">#160D24</color>
    <color name="ic_launcher_background_christmas">#071A12</color>
    <color name="ic_launcher_background_valentines">#260F1A</color>
</resources>
''');
}
