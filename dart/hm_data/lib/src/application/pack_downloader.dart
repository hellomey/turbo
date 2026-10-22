import 'dart:async';
import 'dart:io';

import 'package:crypto/crypto.dart';
import 'package:hm_api/api.dart' as api;
import 'package:hm_core/hm_core.dart';

import '../data/gateways.dart';
import '../data/local_stores.dart';
import '../domain/content_pack.dart';

/// Downloads content packs (§39, U-app-shell invariant 6):
/// - Wi-Fi only unless the user allowed mobile data;
/// - resumable: a broken download continues from the bytes already on disk (HTTP Range);
/// - size-checked and SHA-256 verified before use; a mismatch deletes the file so it is fetched again later;
/// - a newer version replaces the installed one only after its checksum passes;
/// - locked (Pro) packs are never requested by free users.
class PackDownloader {
  PackDownloader({
    required PackCatalogGateway catalog,
    required PackTransport transport,
    required PackStore store,
    required Future<Directory> Function() directory,
  }) : _catalog = catalog,
       _transport = transport,
       _store = store,
       _directory = directory;

  final PackCatalogGateway _catalog;
  final PackTransport _transport;
  final PackStore _store;
  final Future<Directory> Function() _directory;

  static PackOffer offerFrom(api.ContentPack p) => PackOffer(
    code: p.code,
    version: p.version,
    url: p.url,
    sha256: p.sha256.toLowerCase(),
    sizeBytes: p.sizeBytes,
    tier: p.tier == api.ContentPackTierEnum.pro ? PackTier.pro : PackTier.free,
    locked: p.locked,
  );

  Future<List<PackOffer>> offers(String examCode) async => [
    for (final p in await _catalog.listPacks(examCode)) offerFrom(p),
  ];

  /// Offers that are not locked and newer than what is installed.
  Future<List<PackOffer>> updates(String examCode) async {
    final result = <PackOffer>[];
    for (final o in await offers(examCode)) {
      if (o.locked) continue;
      final installed = await _store.get(o.code);
      if (installed == null || installed.version < o.version) result.add(o);
    }
    return result;
  }

  Future<PackDownloadResult> download(
    PackOffer offer, {
    required NetworkState network,
    bool allowMobileData = false,
  }) async {
    if (offer.locked) return PackDownloadResult.locked;
    final installed = await _store.get(offer.code);
    if (installed != null &&
        installed.version >= offer.version &&
        await File(installed.path).exists()) {
      return PackDownloadResult.alreadyInstalled;
    }
    if (!network.online) return PackDownloadResult.offline;
    if (!network.wifi && !allowMobileData) {
      return PackDownloadResult.waitingForWifi;
    }

    final dir = await _directory();
    await dir.create(recursive: true);
    final base =
        '${dir.path}${Platform.pathSeparator}'
        '${offer.code}-v${offer.version}';
    final part = File('$base.part');

    var have = await part.exists() ? await part.length() : 0;
    if (have > offer.sizeBytes) {
      await part.delete();
      have = 0;
    }
    if (have < offer.sizeBytes) {
      try {
        final res = await _transport.get(offer.url, from: have);
        final FileMode mode;
        if (res.statusCode == 206 && have > 0) {
          mode = FileMode.append;
        } else if (res.statusCode == 200 || res.statusCode == 206) {
          mode = FileMode.write;
        } else {
          await res.body.drain<void>();
          return PackDownloadResult.failed;
        }
        final sink = part.openWrite(mode: mode);
        try {
          await sink.addStream(res.body);
        } finally {
          await sink.close();
        }
      } on Object {
        // Bytes already written stay on disk; the next try resumes from there.
        return PackDownloadResult.failed;
      }
    }

    final size = await part.length();
    if (size > offer.sizeBytes) {
      await part.delete();
      return PackDownloadResult.sizeMismatch;
    }
    if (size < offer.sizeBytes) return PackDownloadResult.failed;

    final digest = await sha256.bind(part.openRead()).first;
    if (digest.toString() != offer.sha256) {
      await part.delete();
      return PackDownloadResult.checksumMismatch;
    }

    final packFile = await part.rename('$base.pack');
    await _store.put(
      InstalledPack(
        code: offer.code,
        version: offer.version,
        sha256: offer.sha256,
        path: packFile.path,
        sizeBytes: offer.sizeBytes,
        tier: offer.tier,
      ),
    );
    if (installed != null && installed.path != packFile.path) {
      final old = File(installed.path);
      if (await old.exists()) await old.delete();
    }
    return PackDownloadResult.installed;
  }
}
