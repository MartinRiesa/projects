// lib/core/level_manager.dart

import 'dart:async';
import 'dart:math';

import 'package:vokabeltrainer_app/core/vocab_loader.dart';
import 'package:vokabeltrainer_app/core/vocab_pair.dart';
import 'package:vokabeltrainer_app/core/question_generator.dart';

typedef VoidCallback = void Function();

/// Steuert Level-Fortschritt, Streak-Logik und gewichtet die Auswahl.
class LevelManager {
  static const int levelGoal = 10;
  final Random _rand = Random();

  late final List<VocabPair> _pairs;
  int level = 1;
  int streak = 0;
  VocabPair? _lastPair;
  VoidCallback? onWrong;
  VoidCallback? onLevelUp;

  Future<void> init() async {
    _pairs = await loadWordPairs();
  }

  /// Gewichtete Auswahl, Gewicht = (mistakes+1)/(corrects+1)
  VocabPair _pickWeighted(List<VocabPair> list) {
    final weights = list
        .map((p) => (p.mistakes + 1) / (p.corrects + 1))
        .toList();
    final total = weights.fold<double>(0, (sum, w) => sum + w);
    var r = _rand.nextDouble() * total;
    for (var i = 0; i < list.length; i++) {
      r -= weights[i];
      if (r <= 0) return list[i];
    }
    return list.last;
  }

  /// Erzeugt die nächste Frage aus dem aktuellen Level-Pool.
  Question nextQuestion() {
    final maxIndex = (level * 7).clamp(1, _pairs.length);
    final subset = _pairs.sublist(0, maxIndex);

    VocabPair target;
    do {
      target = _pickWeighted(subset);
    } while (_lastPair != null && subset.length > 1 && target == _lastPair);
    _lastPair = target;

    final others = List<VocabPair>.from(subset)..remove(target);
    final wrongPool =
    others.where((p) => p.mistakes > 0).toList()..shuffle(_rand);
    final distractors = <String>[];
    distractors.addAll(wrongPool.take(2).map((p) => p.de));

    final remaining = others
        .where((p) => !wrongPool.take(2).contains(p))
        .toList()
      ..shuffle(_rand);
    while (distractors.length < 3 && remaining.isNotEmpty) {
      distractors.add(remaining.removeLast().de);
    }

    final options = <String>[target.de, ...distractors]..shuffle(_rand);

    return Question(
      prompt: 'Was bedeutet "${target.en}" auf Deutsch?',
      options: options,
      correctIndex: options.indexOf(target.de),
      sourcePair: target,
    );
  }

  /// Verarbeitet eine Antwort; erhöht corrects oder mistakes, managt Streak/Level.
  bool answer(Question q, int index) {
    final isCorrect = index == q.correctIndex;
    final pair = q.sourcePair;
    if (isCorrect) {
      pair.corrects++;   // neu: Zähler erhöhen
      streak++;
      if (streak >= levelGoal) {
        level++;
        streak = 0;
        if (onLevelUp != null) onLevelUp!();
      }
    } else {
      streak = 0;
      pair.mistakes++;
      if (onWrong != null) onWrong!();
    }
    return isCorrect;
  }
}
