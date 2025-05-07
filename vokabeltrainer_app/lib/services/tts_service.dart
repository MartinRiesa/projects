// lib/services/tts_service.dart
//
// Zentraler Wrapper für flutter_tts, damit immer die
// korrekte Stimme / Sprache verwendet wird.

import 'package:flutter_tts/flutter_tts.dart';

class TtsService {
  final FlutterTts _tts = FlutterTts();

  /// Map Sprachcode → Locale-String
  static const _localeMap = <String, String>{
    'de': 'de-DE',
    'en': 'en-US',
    'uk': 'uk-UA',
    'ar': 'ar-SA',
    'fa': 'fa-AF',
  };

  Future<void> speak(String text, String langCode) async {
    final locale = _localeMap[langCode] ?? 'en-US';
    await _tts.setLanguage(locale);
    await _tts.setSpeechRate(0.45);
    await _tts.setPitch(1.0);
    await _tts.setVolume(1.0);
    await _tts.stop();              // evtl. laufende Ausgabe beenden
    await _tts.speak(text);
  }

  Future<void> dispose() async {
    await _tts.stop();
  }
}
