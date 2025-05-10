/// Platzhalter, damit keine Abhängigkeit zu "flutter_tts" benötigt wird.
/// Alle Methoden entsprechen der Original-API, tun aber nichts.

class FlutterTts {
  Future<void> speak(String _) async {}
  Future<void> stop() async {}

  // optionale Setter – werden im Code meist aufgerufen
  Future<void> setLanguage(String _) async {}
  Future<void> setSpeechRate(double _) async {}
  Future<void> setPitch(double _) async {}
}
