/// Dummy-Ersatz für FlutterTts, damit keine Abhängigkeit zu flutter_tts existiert.
/// Alle Methoden tun nichts, behalten aber die Signatur der Original-API.

class FlutterTts {
  Future<void> setSpeechRate(double _) async {}
  Future<void> setPitch(double _) async {}
  Future<void> setLanguage(String _) async {}
  Future<void> stop() async {}
  Future<void> speak(String _) async {}
}
