// lib/core/question_generator.dart
import 'vocab_pair.dart';

/// Enthält alle Infos für eine Quiz-Frage.
class Question {
  Question({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.sourcePair,
  });

  final String prompt;          // anzuzeigendes Wort / Satz
  final List<String> options;   // mögliche Antworten (Strings)
  final int correctIndex;       // Index der richtigen Antwort in [options]
  final VocabPair sourcePair;   // Referenz, um Statistik zu aktualisieren
}
