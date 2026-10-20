import 'dart:convert';

/// An API failure with the stable error `code` and a simple-English `message` that is safe to show
/// (blueprint §37: every error uses the envelope `{error:{code,message}}`).
class HmApiException implements Exception {
  const HmApiException(
    this.code,
    this.message, {
    this.statusCode,
    this.retryAfterSeconds,
  });

  /// The phone could not reach the server.
  static const networkError = 'NETWORK_ERROR';
  static const networkMessage =
      'No internet connection. Please check and try again.';

  /// The server answered with something that is not the envelope.
  static const unknownError = 'INTERNAL_ERROR';
  static const unknownMessage = 'Something went wrong. Please try again.';

  factory HmApiException.network() =>
      const HmApiException(networkError, networkMessage);

  /// Parses an error response. Falls back to a generic message when the body is not an envelope.
  factory HmApiException.fromResponse(
    int statusCode,
    String body, {
    Map<String, String> headers = const {},
  }) {
    final retryAfter = int.tryParse(headers['retry-after'] ?? '');
    try {
      final decoded = jsonDecode(body);
      if (decoded is Map && decoded['error'] is Map) {
        final error = decoded['error'] as Map;
        final code = error['code'];
        final message = error['message'];
        if (code is String && message is String) {
          return HmApiException(
            code,
            message,
            statusCode: statusCode,
            retryAfterSeconds: retryAfter,
          );
        }
      }
    } on FormatException {
      // Not JSON: fall through to the generic message.
    }
    return HmApiException(
      unknownError,
      unknownMessage,
      statusCode: statusCode,
      retryAfterSeconds: retryAfter,
    );
  }

  final String code;
  final String message;
  final int? statusCode;
  final int? retryAfterSeconds;

  bool get isNetwork => code == networkError;

  @override
  String toString() => 'HmApiException($code, $statusCode): $message';
}
