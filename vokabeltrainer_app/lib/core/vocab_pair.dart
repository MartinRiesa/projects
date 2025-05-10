// lib/core/vocab_pair.dart
/// Repräsentiert ein Wortpaar (Frage ↔ Antwort) samt Lern-Statistiken.
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

  @override
  bool operator ==(Object other) =>
      other is VocabPair &&
          other.prompt == prompt &&
          other.answer == answer;

  @override
  int get hashCode => Object.hash(prompt, answer);
}
