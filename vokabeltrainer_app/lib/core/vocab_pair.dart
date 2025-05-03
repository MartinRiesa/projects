// lib/core/vocab_pair.dart

/// Repräsentiert ein einzelnes Vokabel-Paar mit Fehlerzähler.
class VocabPair {
  final String en;
  final String de;
  int mistakes;

  VocabPair({
    required this.en,
    required this.de,
    this.mistakes = 0,
  });
}
