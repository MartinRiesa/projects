// lib/tts/tts_service.dart
import 'package:flutter_tts/flutter_tts.dart';

/// Einfache Wrapper-Klasse für Text-to-Speech.
class TtsService {
  TtsService._internal();

  static final TtsService instance = TtsService._internal();

  final FlutterTts _tts = FlutterTts();
  bool _ready = false;

  Future<void> init(String locale) async {
    await _tts.setLanguage(locale);
    await _tts.setSpeechRate(0.45);
    _ready = true;
  }

  Future<void> speak(String text, {String? locale}) async {
    if (!_ready) return;
    if (locale != null) await _tts.setLanguage(locale);
    await _tts.stop();
    await _tts.speak(text);
  }

  Future<void> stop() => _tts.stop();
}
