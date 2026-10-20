import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// The phone's text-to-speech (Listen Mode, §19.3 Q27). Works offline with the device voice.
abstract interface class TtsPort {
  Future<void> speak(String text);
  Future<void> stop();

  /// Called when speech ends on its own.
  set onDone(void Function()? callback);
}

class FlutterTtsPort implements TtsPort {
  FlutterTtsPort([FlutterTts? tts]) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  bool _configured = false;

  @override
  set onDone(void Function()? callback) {
    _tts.setCompletionHandler(() => callback?.call());
    _tts.setCancelHandler(() => callback?.call());
  }

  @override
  Future<void> speak(String text) async {
    if (!_configured) {
      _configured = true;
      await _tts.setLanguage('en-IN');
      await _tts.setSpeechRate(0.45);
    }
    await _tts.speak(text);
  }

  @override
  Future<void> stop() async {
    await _tts.stop();
  }
}

final ttsProvider = Provider<TtsPort>((ref) => FlutterTtsPort());

enum ListenStatus { idle, speaking, unavailable }

/// Listen / Stop for one lesson screen.
class ListenController extends Notifier<ListenStatus> {
  @override
  ListenStatus build() {
    final tts = ref.watch(ttsProvider);
    tts.onDone = () {
      if (ref.mounted) state = ListenStatus.idle;
    };
    ref.onDispose(() {
      tts.onDone = null;
      unawaited(tts.stop());
    });
    return ListenStatus.idle;
  }

  Future<void> listen(String text) async {
    try {
      state = ListenStatus.speaking;
      await ref.read(ttsProvider).speak(text);
    } on Exception {
      if (ref.mounted) state = ListenStatus.unavailable;
    }
  }

  Future<void> stop() async {
    await ref.read(ttsProvider).stop();
    if (ref.mounted) state = ListenStatus.idle;
  }
}

final listenControllerProvider =
    NotifierProvider.autoDispose<ListenController, ListenStatus>(
      ListenController.new,
    );
