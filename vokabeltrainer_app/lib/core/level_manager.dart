import 'dart:math';
import 'vocab_loader.dart';
import 'vocab_pair.dart';
import 'question_generator.dart';

class LevelManager {
  LevelManager({
    required this.sourceLang,
    required this.targetLang,
  });

  // eingestellte Sprachen
  final String sourceLang;
  final String targetLang;

  late List<VocabPair> _all;
  late List<VocabPair> _pool;

  // Fortschritt
  int _currentLevel = 1;
  int get level => _currentLevel;

  int _streak = 0;
  int get streak => _streak;

  static const int levelGoal = 10;

  void Function()? onWrong;
  void Function()? onLevelUp;

  final _rnd = Random();

  // ─────────────────────────────────────────── init ──
  Future<void> init() async {
    _all = await VocabLoader.load(sourceLang, targetLang);
    _pool = _all.where((v) => v.corrects < 3).toList();
    _ensurePool();
  }

  // ─────────────────────────────── nächste Frage ──
  Question nextQuestion() {
    final VocabPair chosen = _weightedPick(_pool);

    final distractors = (_pool.where((v) => v != chosen).toList()
      ..sort((a, b) => b.mistakes.compareTo(a.mistakes)))
        .take(3)
        .toList();

    final options = [chosen, ...distractors]..shuffle(_rnd);
    final correct = options.indexOf(chosen);

    return Question(
      prompt: chosen.prompt,
      options: options.map((e) => e.answer).toList(),
      correctIndex: correct,
      pair: chosen,
    );
  }

  // ───────────────────────────── Antwort werten ──
  bool answer(Question q, int idx) {
    final pair = q.pair;
    final ok = idx == q.correctIndex;

    if (ok) {
      pair.corrects++;
      _streak++;
      if (_streak >= levelGoal) _levelUp();
    } else {
      pair.mistakes++;
      _streak = 0;
      onWrong?.call();
    }
    return ok;
  }

  // ─────────────────────────── Level-Up & Pool ──
  void _levelUp() {
    _currentLevel++;
    _streak = 0;
    _ensurePool();
    onLevelUp?.call();
  }

  void _ensurePool() {
    _pool = _all
        .where((v) =>
    v.corrects < 3 &&
        v.mistakes < 10 &&
        v.corrects < _currentLevel + 2)
        .toList();

    if (_pool.isEmpty) {
      for (final v in _all) v.corrects = 0;
      _pool = _all.toList();
    }
  }

  // ───────────────────────── Gewichtete Auswahl ──
  VocabPair _weightedPick(List<VocabPair> list) {
    final weights = list
        .map((v) => (v.mistakes + 1) / (v.corrects + 1))
        .toList(growable: false);
    final sum = weights.fold<double>(0, (a, b) => a + b);

    double r = _rnd.nextDouble() * sum;
    for (int i = 0; i < list.length; i++) {
      r -= weights[i];
      if (r <= 0) return list[i];
    }
    return list.last;
  }
}
