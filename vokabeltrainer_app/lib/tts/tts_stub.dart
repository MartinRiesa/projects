/// Platzhalter für Text-to-Speech.
/// Alle Methoden entsprechen der FlutterTts-API, führen jedoch nichts aus,
/// damit der Windows-Build ohne Abhängigkeit zu NuGet durchläuft.

class FlutterTts {
  Future<void> setSpeechRate(double _rate) async {}
  Future<void> setPitch(double _pitch) async {}
  Future<void> setLanguage(String _locale) async {}
  Future<void> stop() async {}
  Future<void> speak(String _text) async {}
}
