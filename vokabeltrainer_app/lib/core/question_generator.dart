// lib/core/question_generator.dart

import 'package:vokabeltrainer_app/core/vocab_pair.dart';

/// Repräsentiert eine einzelne Vokabel-Frage inklusive Quelle.
class Question {
  final String prompt;
  final List<String> options;
  final int correctIndex;
  final VocabPair sourcePair;

  /// Neuer öffentlicher Konstruktor, der alle Felder belegt.
  Question({
    required this.prompt,
    required this.options,
    required this.correctIndex,
    required this.sourcePair,
  });
}
