// lib/core/vocab_pair.dart
class VocabPair {
  /// Map ‹ISO-Code → Wort›, z. B. {'de':'Hund', 'en':'dog', 'uk':'пес'}
  final Map<String, String> t;

  int mistakes = 0;
  int corrects = 0;

  VocabPair(this.t);

  /// Liefert das Wort für eine Sprache (oder '' falls nicht vorhanden).
  String word(String lang) => t[lang] ?? '';
}
