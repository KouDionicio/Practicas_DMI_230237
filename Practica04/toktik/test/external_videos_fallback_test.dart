import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:provider/provider.dart';
import 'package:toktik/domain/entities/external_video.dart';
import 'package:toktik/domain/errors/external_video_exception.dart';
import 'package:toktik/domain/repositories/external_video_repository.dart';
import 'package:toktik/presentation/providers/external_video_search_provider.dart';
import 'package:toktik/presentation/screens/external_videos/external_videos_screen.dart';

void main() {
  testWidgets('shows auth failure details and returns to the local feed', (
    tester,
  ) async {
    final provider = ExternalVideoSearchProvider(_UnauthorizedRepository());
    await provider.search('cats');

    await tester.pumpWidget(
      MultiProvider(
        providers: [ChangeNotifierProvider.value(value: provider)],
        child: MaterialApp(
          home: Builder(
            builder: (context) => Scaffold(
              body: Column(
                children: [
                  const Text('Discover local videos'),
                  TextButton(
                    onPressed: () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) => const ExternalVideosScreen(),
                      ),
                    ),
                    child: const Text('Open external search'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('Open external search'));
    await tester.pumpAndSettle();

    expect(find.textContaining('HTTP 403'), findsOneWidget);
    expect(find.textContaining('credencial es inválida'), findsOneWidget);
    await tester.tap(find.text('Volver a los videos locales'));
    await tester.pumpAndSettle();

    expect(find.text('Discover local videos'), findsOneWidget);
    provider.dispose();
  });
}

class _UnauthorizedRepository implements ExternalVideoRepository {
  @override
  Future<List<ExternalVideo>> search(VideoSource source, String query) async {
    throw const ExternalVideoApiException(
      provider: 'YouTube',
      statusCode: 403,
      message:
          'La credencial es inválida o no tiene permisos suficientes. '
          'Revisa la configuración de YouTube.',
      isAuthenticationError: true,
    );
  }
}
