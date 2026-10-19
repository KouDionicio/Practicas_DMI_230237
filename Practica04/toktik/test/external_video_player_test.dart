import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/presentation/widgets/video/external_video_player.dart';
import 'package:webview_flutter/webview_flutter.dart';

final _validVideo = ExternalVideo(
  id: 'youtube:abc123',
  source: VideoSource.youtube,
  title: 'A video',
  description: '',
  thumbnailUrl: '',
  watchUrl: Uri.https('www.youtube.com', '/watch', {'v': 'abc123'}),
  embedUrl: Uri.https('www.youtube.com', '/embed/abc123'),
);

final _invalidVideo = ExternalVideo(
  id: 'youtube:abc123',
  source: VideoSource.youtube,
  title: 'A video',
  description: '',
  thumbnailUrl: '',
  watchUrl: Uri.https('www.youtube.com', '/watch'),
  embedUrl: Uri.https('attacker.example', '/embed/abc123'),
);

final _mismatchedVideo = ExternalVideo(
  id: 'youtube:other123',
  source: VideoSource.youtube,
  title: 'A video',
  description: '',
  thumbnailUrl: '',
  watchUrl: Uri.https('www.youtube.com', '/watch', {'v': 'abc123'}),
  embedUrl: Uri.https('www.youtube.com', '/embed/abc123'),
);

final _peerTubeVideo = ExternalVideo(
  id: 'peertube:a1b2c3d4-0000-4000-8000-000000000001',
  source: VideoSource.peertube,
  title: 'A PeerTube video',
  description: '',
  thumbnailUrl: '',
  watchUrl: Uri.https('peertube.cpy.re', '/w/sWxgbBUu1ScQkHqz831Qqi'),
  embedUrl: Uri.https(
    'peertube.cpy.re',
    '/videos/embed/a1b2c3d4-0000-4000-8000-000000000001',
  ),
);

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('shows invalid embed URLs without initializing a player', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ExternalVideoPlayer(video: _invalidVideo)),
      ),
    );

    expect(find.textContaining('host oficial'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('rejects video IDs that do not match their embed URL', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ExternalVideoPlayer(video: _mismatchedVideo)),
      ),
    );

    expect(find.textContaining('ruta no corresponde'), findsOneWidget);
    expect(find.byType(WebViewWidget), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('uses the web iframe instead of webview_flutter in Chrome', (
    tester,
  ) async {
    if (!kIsWeb) return;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ExternalVideoPlayer(video: _validVideo)),
      ),
    );
    await tester.pump();

    expect(tester.takeException(), isNull);
    expect(find.byType(HtmlElementView), findsOneWidget);
    expect(find.byType(WebViewWidget), findsNothing);
    expect(
      find.textContaining('No se pudo cargar el reproductor'),
      findsNothing,
    );
  });

  testWidgets('opens the PeerTube embed in a web iframe', (tester) async {
    if (!kIsWeb) return;

    await tester.pumpWidget(
      MaterialApp(
        home: Scaffold(body: ExternalVideoPlayer(video: _peerTubeVideo)),
      ),
    );
    await tester.pump();

    expect(_peerTubeVideo.embedUrl.host, 'peertube.cpy.re');
    expect(
      _peerTubeVideo.embedUrl.path,
      '/videos/embed/a1b2c3d4-0000-4000-8000-000000000001',
    );
    expect(find.byType(HtmlElementView), findsOneWidget);
    expect(find.byType(WebViewWidget), findsNothing);
    expect(tester.takeException(), isNull);
  });
}
