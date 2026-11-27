import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_tts/flutter_tts.dart';

/// The phone's text-to-speech (Listen Mode, §19.3 Q27). Works offline with the device voice.
abstract interface class TtsPort {
  Future<void> speak(String text);
  Future<void> stop();

  /// Called when speech ends on its own.
  set onDone(void Function()? callback);
}

/// Splits text into short pieces (sentences, at most about 220 characters). Browsers stop long utterances
/// part-way, so Listen speaks one piece at a time.
List<String> speechChunks(String text) {
  final out = <String>[];
  for (final line in text.split('\n')) {
    for (final s in line.split(RegExp(r'(?<=[.!?।])\s+'))) {
      var rest = s.trim();
      while (rest.length > 220) {
        var cut = rest.lastIndexOf(RegExp(r'[,;:]\s'), 220);
        if (cut < 60) cut = rest.lastIndexOf(' ', 220);
        if (cut < 1) cut = 220;
        out.add(rest.substring(0, cut + 1).trim());
        rest = rest.substring(cut + 1).trim();
      }
      if (rest.isNotEmpty) out.add(rest);
    }
  }
  return out;
}

/// True when the piece is mostly Tamil script, so it is read with a Tamil voice.
bool isTamil(String text) {
  final tamil = RegExp(r'[஀-௿]').allMatches(text).length;
  final latin = RegExp('[A-Za-z]').allMatches(text).length;
  return tamil > latin;
}

/// The device's own text-to-speech: free, offline, and nothing leaves the phone. Reads piece by piece at a brisk
/// pace and switches to a Tamil voice (ta-IN) for Tamil lines when the device has one.
class FlutterTtsPort implements TtsPort {
  FlutterTtsPort([FlutterTts? tts]) : _tts = tts ?? FlutterTts();

  final FlutterTts _tts;
  void Function()? _onDone;
  bool _configured = false;
  int _run = 0;
  String? _lang;

  @override
  set onDone(void Function()? callback) => _onDone = callback;

  Future<void> _setup() async {
    if (_configured) return;
    _configured = true;
    await _tts.awaitSpeakCompletion(true);
    // Web rates run 0.1-10 with 1 as normal; phone rates run 0-1 with 0.5 as normal.
    await _tts.setSpeechRate(kIsWeb ? 1.15 : 0.58);
    await _tts.setPitch(1.05);
  }

  Future<void> _language(String lang) async {
    if (_lang == lang) return;
    _lang = lang;
    await _tts.setLanguage(lang);
  }

  @override
  Future<void> speak(String text) async {
    await _setup();
    final run = ++_run;
    await _tts.stop();
    for (final piece in speechChunks(text)) {
      if (run != _run) return;
      await _language(isTamil(piece) ? 'ta-IN' : 'en-IN');
      await _tts.speak(piece);
    }
    if (run == _run) _onDone?.call();
  }

  @override
  Future<void> stop() async {
    _run++;
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
