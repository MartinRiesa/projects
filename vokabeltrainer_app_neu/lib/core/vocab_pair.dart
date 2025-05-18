// lib/core/vocab_pair.dart
class VocabPair {
  VocabPair({
    required this.prompt,
    required this.answer,
    this.mistakes = 0,
    this.corrects = 0,
  });

  final String prompt;
  final String answer;
  int mistakes;
  int corrects;
}
