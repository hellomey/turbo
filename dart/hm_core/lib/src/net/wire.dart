import '../session/token_store.dart';

/// Decodes a contract `TokenPair`.
StoredTokens? tokensFromJson(Object? json) => StoredTokens.fromJson(json);

/// Reads a JSON object or throws [FormatException].
Map<String, dynamic> asJsonMap(Object? json) {
  if (json is Map) return json.cast<String, dynamic>();
  throw const FormatException('Expected a JSON object');
}

/// Reads a JSON list of objects (missing = empty).
List<Map<String, dynamic>> asJsonList(Object? json) => [
  for (final item in (json is List ? json : const <Object?>[]))
    if (item is Map) item.cast<String, dynamic>(),
];
