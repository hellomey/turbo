import 'package:flutter/foundation.dart';

enum PackTier { free, pro }

/// A content pack the server offers (contract `ContentPack`, §39).
@immutable
class PackOffer {
  const PackOffer({
    required this.code,
    required this.version,
    required this.url,
    required this.sha256,
    required this.sizeBytes,
    required this.tier,
    required this.locked,
  });

  final String code;
  final int version;
  final String url;

  /// Lower-case hex SHA-256 of the whole file.
  final String sha256;
  final int sizeBytes;
  final PackTier tier;

  /// True when this user may not download it (Pro pack, free user).
  final bool locked;
}

/// A pack on this phone that passed its checksum.
@immutable
class InstalledPack {
  const InstalledPack({
    required this.code,
    required this.version,
    required this.sha256,
    required this.path,
    required this.sizeBytes,
    required this.tier,
  });

  final String code;
  final int version;
  final String sha256;
  final String path;
  final int sizeBytes;
  final PackTier tier;
}

enum PackDownloadResult {
  installed,
  alreadyInstalled,
  locked,
  waitingForWifi,
  offline,
  sizeMismatch,
  checksumMismatch,
  failed,
}
