import 'dart:async';
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:uuid/uuid.dart';

import '../session/token_store.dart';
import 'wire.dart';
import 'app_version.dart';

/// The HTTP layer under the generated client (blueprint §34.3, §37, §38):
/// - adds `Authorization: Bearer <access token>` when signed in;
/// - adds a fresh UUID `Idempotency-Key` to every POST/PUT/PATCH that lacks one, except the pure
///   computation `POST /v1/eligibility/check` (contract `idempotent: false`). A retry reuses the key;
/// - on 401, refreshes ONCE (single flight: concurrent 401s share one refresh) and retries the request;
///   when the refresh is refused (e.g. SESSION_REVOKED) the tokens are cleared and [onSignedOut] runs;
/// - raises [updateRequired] when `X-Min-App-Version` is higher than [appVersion].
class HmHttpClient extends http.BaseClient {
  HmHttpClient({
    required http.Client inner,
    required TokenStore tokens,
    required this.baseUrl,
    required this.appVersion,
    required this.updateRequired,
    this.onSignedOut,
    String Function()? newIdempotencyKey,
  }) : _inner = inner,
       _tokens = tokens,
       _newKey = newIdempotencyKey ?? (() => const Uuid().v4());

  static const idempotencyHeader = 'idempotency-key';
  static const minAppVersionHeader = 'x-min-app-version';
  static const refreshPath = '/v1/auth/refresh';

  /// Writes that are pure computations and must NOT carry an Idempotency-Key (routes.ts `idempotent: false`).
  static const nonIdempotentWrites = {'/v1/eligibility/check'};
  static const _writeMethods = {'POST', 'PUT', 'PATCH'};

  final http.Client _inner;
  final TokenStore _tokens;
  final String baseUrl;
  final String appVersion;
  final ValueNotifier<bool> updateRequired;
  final void Function()? onSignedOut;
  final String Function() _newKey;

  Future<bool>? _refreshing;

  /// True when this method + path needs an Idempotency-Key.
  static bool needsIdempotencyKey(String method, String path) =>
      _writeMethods.contains(method.toUpperCase()) &&
      !nonIdempotentWrites.contains(path);

  @override
  Future<http.StreamedResponse> send(http.BaseRequest request) async {
    final base = _withIdempotencyKey(request);
    final tokens = await _tokens.read();
    final usedToken = tokens?.accessToken;
    final first = _copy(base, bearer: usedToken);
    var response = await _inner.send(first);
    _checkMinVersion(response.headers);

    final canRetry =
        response.statusCode == 401 &&
        usedToken != null &&
        base is http.Request &&
        base.url.path != refreshPath;
    if (!canRetry) return response;

    final fresh = await _freshAccessToken(usedToken);
    if (fresh == null) return response;
    await response.stream.drain<void>();
    response = await _inner.send(_copy(base, bearer: fresh));
    _checkMinVersion(response.headers);
    return response;
  }

  /// Returns an access token newer than [staleToken], refreshing at most once at a time.
  Future<String?> _freshAccessToken(String staleToken) async {
    final current = await _tokens.read();
    if (current != null && current.accessToken != staleToken) {
      return current.accessToken; // another request already refreshed
    }
    final ok = await (_refreshing ??= _refresh().whenComplete(
      () => _refreshing = null,
    ));
    if (!ok) return null;
    return (await _tokens.read())?.accessToken;
  }

  Future<bool> _refresh() async {
    final tokens = await _tokens.read();
    if (tokens == null) {
      _signedOut();
      return false;
    }
    final http.Response res;
    try {
      res = await _inner.post(
        Uri.parse('$baseUrl$refreshPath'),
        headers: {
          'content-type': 'application/json',
          idempotencyHeader: _newKey(),
        },
        body: jsonEncode({'refreshToken': tokens.refreshToken}),
      );
    } on Exception {
      return false; // offline: keep the session, fail this call
    }
    _checkMinVersion(res.headers);
    if (res.statusCode == 200) {
      final StoredTokens? pair;
      try {
        pair = tokensFromJson(jsonDecode(utf8.decode(res.bodyBytes)));
      } on FormatException {
        return false;
      }
      if (pair == null) return false;
      await _tokens.write(pair);
      return true;
    }
    if (res.statusCode == 401 ||
        res.statusCode == 403 ||
        res.statusCode == 400) {
      // SESSION_REVOKED (reused refresh token), expired or unknown session: sign out.
      await _tokens.clear();
      _signedOut();
    }
    return false;
  }

  void _signedOut() => onSignedOut?.call();

  http.BaseRequest _withIdempotencyKey(http.BaseRequest request) {
    if (!needsIdempotencyKey(request.method, request.url.path)) {
      return request;
    }
    final existing = request.headers.entries
        .where((e) => e.key.toLowerCase() == idempotencyHeader)
        .map((e) => e.value)
        .firstOrNull;
    if (existing != null && existing.isNotEmpty) return request;
    final copy = _copy(request);
    copy.headers.removeWhere((k, _) => k.toLowerCase() == idempotencyHeader);
    copy.headers[idempotencyHeader] = _newKey();
    return copy;
  }

  /// Requests can only be sent once, so every send uses a copy (same headers, body and key).
  http.BaseRequest _copy(http.BaseRequest request, {String? bearer}) {
    if (request is! http.Request) {
      if (bearer != null) request.headers['authorization'] = 'Bearer $bearer';
      return request;
    }
    final copy = http.Request(request.method, request.url)
      ..followRedirects = request.followRedirects
      ..maxRedirects = request.maxRedirects
      ..persistentConnection = request.persistentConnection;
    copy.headers.addAll(request.headers);
    copy.bodyBytes = request.bodyBytes;
    if (bearer != null) {
      copy.headers.removeWhere((k, _) => k.toLowerCase() == 'authorization');
      copy.headers['authorization'] = 'Bearer $bearer';
    }
    return copy;
  }

  void _checkMinVersion(Map<String, String> headers) {
    final min = headers[minAppVersionHeader];
    if (min != null && isVersionLower(appVersion, min)) {
      updateRequired.value = true;
    }
  }

  @override
  void close() => _inner.close();
}
