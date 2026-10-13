import 'dart:convert';
import 'dart:async';

import 'package:http/http.dart' as http;
import 'package:toktik/domain/errors/external_video_exception.dart';

String? normalizeExternalVideoQuery(String query) {
  final normalizedQuery = query.trim();
  if (normalizedQuery.isEmpty) return null;
  if (normalizedQuery.length > 100) {
    throw const ExternalVideoQueryException(
      'La búsqueda no puede superar los 100 caracteres.',
    );
  }
  return normalizedQuery;
}

Future<http.Response> getExternalVideoResponse(
  Uri uri, {
  required String provider,
  http.Client? client,
  Map<String, String>? headers,
}) async {
  try {
    return await (client == null
            ? http.get(uri, headers: headers)
            : client.get(uri, headers: headers))
        .timeout(const Duration(seconds: 15));
  } on TimeoutException {
    throw ExternalVideoNetworkException(
      'La consulta a $provider tardó demasiado. Intenta de nuevo.',
    );
  } on http.ClientException {
    throw ExternalVideoNetworkException('No se pudo conectar con $provider.');
  }
}

Map<String, dynamic> decodeCollection(
  http.Response response, {
  required String provider,
  String collectionKey = 'data',
}) {
  if (response.statusCode < 200 || response.statusCode >= 300) {
    final retryAfter = response.headers['retry-after'];
    final retrySeconds = int.tryParse(retryAfter ?? '');
    final retryHint = response.statusCode == 429 && retrySeconds != null
        ? ' Intenta de nuevo en $retrySeconds segundos.'
        : '';

    throw ExternalVideoApiException(
      provider: provider,
      statusCode: response.statusCode,
      message: switch (response.statusCode) {
        401 || 403 =>
          'La credencial es inválida o no tiene permisos suficientes. '
              'Revisa la configuración de $provider.',
        429 => 'Se alcanzó el límite de solicitudes.$retryHint',
        _ => 'El servicio no pudo completar la consulta.',
      },
      isAuthenticationError:
          response.statusCode == 401 || response.statusCode == 403,
    );
  }

  final decoded = jsonDecode(response.body);

  if (decoded is! Map<String, dynamic>) {
    throw FormatException('$provider API respondió un objeto inesperado.');
  }

  final items = decoded[collectionKey];

  if (items is! List<dynamic>) {
    throw FormatException(
      '$provider API no incluyó la colección "$collectionKey".',
    );
  }

  return {'items': items};
}

List<Map<String, dynamic>> collectionItems(
  http.Response response, {
  required String provider,
  String collectionKey = 'data',
}) {
  final decoded = decodeCollection(
    response,
    provider: provider,
    collectionKey: collectionKey,
  );

  return (decoded['items'] as List<dynamic>)
      .map((item) {
        if (item is! Map<String, dynamic>) {
          throw FormatException(
            '$provider API incluyó un elemento que no es un objeto.',
          );
        }

        return item;
      })
      .toList(growable: false);
}
