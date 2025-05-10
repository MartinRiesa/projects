class VocabPair {
  final String prompt;   // Wort in Muttersprache
  final String answer;   // Übersetzung
  int corrects;
  int mistakes;

  VocabPair({
    required this.prompt,
    required this.answer,
    this.corrects = 0,
    this.mistakes = 0,
  });
}
