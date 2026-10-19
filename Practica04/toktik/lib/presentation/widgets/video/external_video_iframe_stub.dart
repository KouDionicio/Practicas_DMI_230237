import 'package:flutter/widgets.dart';

Widget buildExternalVideoIframe({
  required Uri embedUrl,
  required Uri watchUrl,
  required String title,
  required String providerName,
  required int retryToken,
  required bool isMuted,
  required VoidCallback onDocumentLoad,
  required VoidCallback onDocumentError,
}) {
  throw UnsupportedError('El iframe solo está disponible en Flutter Web.');
}
