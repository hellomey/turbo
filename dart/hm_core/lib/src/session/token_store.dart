import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:uuid/uuid.dart';

/// The access + refresh tokens of this install (blueprint §38 step 4).
@immutable
class StoredTokens {
  const StoredTokens({
    required this.accessToken,
    required this.refreshToken,
    required this.accessTokenExpiresAt,
  });

  final String accessToken;
  final String refreshToken;
  final DateTime accessTokenExpiresAt;

  Map<String, Object> toJson() => {
    'accessToken': accessToken,
    'refreshToken': refreshToken,
    'accessTokenExpiresAt': accessTokenExpiresAt.toUtc().toIso8601String(),
  };

  static StoredTokens? fromJson(Object? json) {
    if (json is! Map) return null;
    final access = json['accessToken'];
    final refresh = json['refreshToken'];
    final expires = DateTime.tryParse('${json['accessTokenExpiresAt']}');
    if (access is! String || refresh is! String || expires == null) {
      return null;
    }
    return StoredTokens(
      accessToken: access,
      refreshToken: refresh,
      accessTokenExpiresAt: expires,
    );
  }
}

/// A tiny key-value port over secure storage, so tests can use memory instead.
abstract interface class SecureKeyValue {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

/// flutter_secure_storage (Android Keystore / iOS Keychain / web: encrypted local storage).
class FlutterSecureKeyValue implements SecureKeyValue {
  FlutterSecureKeyValue([FlutterSecureStorage? storage])
    : _storage = storage ?? const FlutterSecureStorage();

  final FlutterSecureStorage _storage;

  @override
  Future<String?> read(String key) => _storage.read(key: key);

  @override
  Future<void> write(String key, String value) =>
      _storage.write(key: key, value: value);

  @override
  Future<void> delete(String key) => _storage.delete(key: key);
}

class MemoryKeyValue implements SecureKeyValue {
  final Map<String, String> values = {};

  @override
  Future<String?> read(String key) async => values[key];

  @override
  Future<void> write(String key, String value) async => values[key] = value;

  @override
  Future<void> delete(String key) async => values.remove(key);
}

abstract interface class TokenStore {
  Future<StoredTokens?> read();
  Future<void> write(StoredTokens tokens);
  Future<void> clear();
}

/// Tokens in secure storage. Nothing else about the user is kept on the phone in Phase 1.
class SecureTokenStore implements TokenStore {
  SecureTokenStore(this._kv, {this.key = 'hm.session.tokens'});

  final SecureKeyValue _kv;
  final String key;

  @override
  Future<StoredTokens?> read() async {
    final raw = await _kv.read(key);
    if (raw == null) return null;
    try {
      return StoredTokens.fromJson(jsonDecode(raw));
    } on FormatException {
      return null;
    }
  }

  @override
  Future<void> write(StoredTokens tokens) =>
      _kv.write(key, jsonEncode(tokens.toJson()));

  @override
  Future<void> clear() => _kv.delete(key);
}

/// Memory only (tests, and the memory half of [CachedTokenStore]).
class MemoryTokenStore implements TokenStore {
  MemoryTokenStore([this._tokens]);

  StoredTokens? _tokens;

  @override
  Future<StoredTokens?> read() async => _tokens;

  @override
  Future<void> write(StoredTokens tokens) async => _tokens = tokens;

  @override
  Future<void> clear() async => _tokens = null;
}

/// Memory first, persisted behind it. Used by HeyMey Desk (short sessions, §15).
class CachedTokenStore implements TokenStore {
  CachedTokenStore(this._persistent);

  final TokenStore _persistent;
  StoredTokens? _memory;
  bool _loaded = false;

  @override
  Future<StoredTokens?> read() async {
    if (!_loaded) {
      _memory = await _persistent.read();
      _loaded = true;
    }
    return _memory;
  }

  @override
  Future<void> write(StoredTokens tokens) async {
    _memory = tokens;
    _loaded = true;
    await _persistent.write(tokens);
  }

  @override
  Future<void> clear() async {
    _memory = null;
    _loaded = true;
    await _persistent.clear();
  }
}

/// A random UUID created once per install and sent as `deviceId` (§38 step 3).
class DeviceIdStore {
  DeviceIdStore(this._kv, {this.key = 'hm.device.id'});

  final SecureKeyValue _kv;
  final String key;
  String? _cached;

  Future<String> deviceId() async {
    final cached = _cached;
    if (cached != null) return cached;
    final stored = await _kv.read(key);
    if (stored != null && stored.isNotEmpty) return _cached = stored;
    final fresh = const Uuid().v4();
    await _kv.write(key, fresh);
    return _cached = fresh;
  }
}
