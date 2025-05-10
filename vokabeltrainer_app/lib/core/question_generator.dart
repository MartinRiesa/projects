import 'vocab_pair.dart';

/// Datenträger für eine einzelne Quizfrage.
class Question {
  final String prompt;           // Anzeige-Wort
  final List<String> options;    // Antwortmöglichkeiten
  final int correctIndex;        // Index der korrekten Antwort
  final VocabPair pair;          // Referenz auf Original-Vokabel

  Question({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.pair,
  });
}
