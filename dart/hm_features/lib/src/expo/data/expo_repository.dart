import 'package:hm_core/hm_core.dart';

import '../domain/expo_models.dart';

/// Expo Challenge calls (BOLT-0111).
abstract interface class ExpoRepository {
  Future<ExpoChallenge> fetchChallenge();

  /// [idempotencyKey] stays the same for every retry of one attempt.
  Future<ExpoResult> submit(
    String challengeId,
    List<ExpoAnswer> answers, {
    required String idempotencyKey,
  });

  Future<StickerCode> myStickerCode();

  String newIdempotencyKey();
}

class ApiExpoRepository implements ExpoRepository {
  ApiExpoRepository(this._api);

  final HmApi _api;

  @override
  Future<ExpoChallenge> fetchChallenge() async =>
      ExpoJson.challenge(await _api.startExpoChallenge());

  @override
  Future<ExpoResult> submit(
    String challengeId,
    List<ExpoAnswer> answers, {
    required String idempotencyKey,
  }) async => ExpoJson.result(
    await _api.submitExpoChallenge(challengeId, [
      for (final a in answers) a.toJson(),
    ], idempotencyKey: idempotencyKey),
  );

  @override
  Future<StickerCode> myStickerCode() async =>
      ExpoJson.sticker(await _api.getMyStickerCode());

  @override
  String newIdempotencyKey() => _api.newIdempotencyKey();
}
