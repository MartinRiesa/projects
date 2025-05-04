// lib/core/level_manager.dart
import 'dart:math';
import 'vocab_pair.dart';
import 'vocab_loader.dart';
import 'question_generator.dart';

typedef VoidCallback = void Function();

class LevelManager {
  static const int levelGoal = 10;
  final Random _rand = Random();

  late List<VocabPair> _pairs;
  late String _src;
  late String _dst;

  VocabPair? _lastPair;
  int level = 1;
  int streak = 0;

  VoidCallback? onWrong;
  VoidCallback? onLevelUp;

  /// Lädt ALLE Paare und merkt sich die gewählte Sprachrichtung.
  Future<List<String>> init(String srcLang, String dstLang) async {
    _src = srcLang;
    _dst = dstLang;
    final (pairs, langs) = await loadAllPairs();
    // Nur Paare behalten, die beide Sprachen enthalten
    _pairs = pairs.where((p) => p.word(_src).isNotEmpty && p.word(_dst).isNotEmpty).toList();
    return langs;                              // für UI-Dropdowns
  }

  // Gewichtete Auswahl bleibt unverändert
  VocabPair _pickWeighted(List<VocabPair> list) {
    final w = list.map((p) => (p.mistakes + 1) / (p.corrects + 1)).toList();
    final total = w.fold<double>(0, (s, x) => s + x);
    var r = _rand.nextDouble() * total;
    for (var i = 0; i < list.length; i++) {
      r -= w[i];
      if (r <= 0) return list[i];
    }
    return list.last;
  }

  Question nextQuestion() {
    final max = (level * 7).clamp(1, _pairs.length);
    final pool = _pairs.sublist(0, max);

    VocabPair target;
    do { target = _pickWeighted(pool); }
    while (_lastPair != null && pool.length > 1 && target == _lastPair);
    _lastPair = target;

    // Distraktoren-Regel: max 2 aus Fehler-Pool
    final others = List<VocabPair>.from(pool)..remove(target);
    final wrongPool = others.where((p) => p.mistakes > 0).toList()..shuffle(_rand);

    final distractors = <String>[
      ...wrongPool.take(2).map((p) => p.word(_dst)),
      ...others.where((p) => !wrongPool.contains(p)).map((p) => p.word(_dst)),
    ]..shuffle(_rand);
    distractors.length = 3;

    final options = <String>[target.word(_dst), ...distractors]..shuffle(_rand);

    return Question(
      prompt       : target.word(_src),
      options      : options,
      correctIndex : options.indexOf(target.word(_dst)),
      sourcePair   : target,
    );
  }

  bool answer(Question q, int i) {
    final correct = i == q.correctIndex;
    final p = q.sourcePair;
    if (correct) {
      p.corrects++; streak++;
      if (streak >= levelGoal) { level++; streak = 0; onLevelUp?.call(); }
    } else {
      p.mistakes++; streak = 0; onWrong?.call();
    }
    return correct;
  }
}
