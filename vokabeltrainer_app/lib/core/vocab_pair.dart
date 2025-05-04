// lib/core/vocab_pair.dart

/// Repräsentiert ein einzelnes Vokabel-Paar mit Fehler- und Erfolgszähler.
class VocabPair {
  final String en;
  final String de;
  int mistakes;
  int corrects;    // neu: Zähler für richtig beantwortete Durchläufe

  VocabPair({
    required this.en,
    required this.de,
    this.mistakes = 0,
    this.corrects = 0,
  });
}
