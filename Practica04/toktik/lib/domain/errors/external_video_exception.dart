class ExternalVideoConfigurationException implements Exception {
  const ExternalVideoConfigurationException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ExternalVideoNetworkException implements Exception {
  const ExternalVideoNetworkException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ExternalVideoQueryException implements Exception {
  const ExternalVideoQueryException(this.message);

  final String message;

  @override
  String toString() => message;
}

class ExternalVideoApiException implements Exception {
  const ExternalVideoApiException({
    required this.provider,
    required this.statusCode,
    required this.message,
    this.isAuthenticationError = false,
  });

  final String provider;
  final int statusCode;
  final String message;
  final bool isAuthenticationError;

  bool get isRateLimitError => statusCode == 429;

  @override
  String toString() => '$provider API devolvió HTTP $statusCode: $message';
}
