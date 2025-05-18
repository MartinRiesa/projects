// lib/core/level_manager.dart
import 'dart:math' as math;
import 'vocab_loader.dart';
import 'vocab_pair.dart';
import 'question_generator.dart';

class LevelManager {
  LevelManager({
    required this.sourceLang,
    required this.targetLang,
  });

  final String sourceLang;
  final String targetLang;

  static const int levelGoal = 10;
  int level = 1;
  int streak = 0;

  late List<VocabPair> _all;
  VocabPair? _lastPair;

  late void Function() onWrong;
  late void Function() onLevelUp;

  Future<void> init() async {
    _all = await VocabLoader.load(sourceLang, targetLang);
  }

  Question nextQuestion() {
    final pool = _all.take(level * 7).toList();
    final chosen = _pickWeighted(pool);

    // 3 Distraktoren auswählen:
    final wrongCandidates =
    pool.where((v) => v != chosen).toList()..sort((a, b) => b.mistakes.compareTo(a.mistakes));

    // Zuerst bis zu 2, die oft falsch waren:
    final distractors = <VocabPair>[];
    distractors.addAll(wrongCandidates.take(2));

    // Dann solange zufällig auffüllen, bis wir 3 haben:
    final remaining = pool.where((v) => v != chosen && !distractors.contains(v)).toList();
    final rnd = math.Random();
    while (distractors.length < 3 && remaining.isNotEmpty) {
      final pick = remaining.removeAt(rnd.nextInt(remaining.length));
      distractors.add(pick);
    }

    // Nun haben wir genau 3 Distraktoren:
    assert(distractors.length == 3);

    // Optionen mischen:
    final options = [chosen, ...distractors]..shuffle(rnd);
    final correctIndex = options.indexOf(chosen);
    _lastPair = chosen;

    return Question(
      prompt: chosen.prompt,
      options: options.map((e) => e.answer).toList(),
      correctIndex: correctIndex,
      sourcePair: chosen,
    );
  }

  bool answer(Question q, int idx) {
    final correct = idx == q.correctIndex;
    if (correct) {
      q.sourcePair.corrects++;
      streak++;
      if (streak >= levelGoal) {
        level++;
        streak = 0;
        onLevelUp();
      }
    } else {
      q.sourcePair.mistakes++;
      streak = 0;
      onWrong();
    }
    return correct;
  }

  VocabPair _pickWeighted(List<VocabPair> pool) {
    final weights = pool.map((v) => (v.mistakes + 1) / (v.corrects + 1)).toList();
    final sum = weights.reduce((a, b) => a + b);
    var rnd = math.Random().nextDouble() * sum;

    for (var i = 0; i < pool.length; i++) {
      rnd -= weights[i];
      if (rnd <= 0 && pool[i] != _lastPair) {
        return pool[i];
      }
    }
    // Fallback:
    return pool.firstWhere((v) => v != _lastPair, orElse: () => pool.first);
  }
}
