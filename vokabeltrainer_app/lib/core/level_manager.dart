// lib/core/level_manager.dart
import 'dart:math' as math;
import 'package:flutter/foundation.dart';

import 'vocab_pair.dart';
import 'vocab_loader.dart';
import 'question_generator.dart';

class LevelManager {
  LevelManager({
    required this.sourceLang,
    required this.targetLang,
  }) {
    // Singleton bereitstellen
    instance = this;
  }

  /// Globale Instanz
  static late LevelManager instance;

  final String sourceLang;
  final String targetLang;

  // Callbacks für die UI
  VoidCallback? onWrong;
  VoidCallback? onLevelUp;

  static const int levelGoal = 10;

  int level = 1;
  int streak = 0;

  late List<VocabPair> _all;
  VocabPair? _lastPair;

  /// Alias, damit bestehender Code funktioniert
  int get currentLevel => level;

  /// CSV einlesen (einmalig aufrufen)
  Future<void> init() async {
    _all = await VocabLoader.load(sourceLang, targetLang);
  }

  /// Nächste Frage erzeugen
  Question nextQuestion() {
    final pool = _all.take(level * 7).toList();
    final chosen = _pickWeighted(pool);

    // Distraktoren
    final wrongCandidates = List<VocabPair>.from(pool)
      ..remove(chosen)
      ..sort((a, b) => b.mistakes.compareTo(a.mistakes));

    final distractors = <VocabPair>[...wrongCandidates.take(2)];
    final rnd = math.Random();

    while (distractors.length < 3) {
      final cand = pool[rnd.nextInt(pool.length)];
      if (cand != chosen && !distractors.contains(cand)) {
        distractors.add(cand);
      }
    }

    // Antworten mischen
    final options = [chosen, ...distractors]..shuffle(rnd);
    final correctIndex = options.indexOf(chosen);
    _lastPair = chosen;

    return Question(
      prompt: chosen.prompt,
      options: options.map<String>((e) => e.answer).toList(),
      correctIndex: correctIndex,
      sourcePair: chosen,
    );
  }

  /// Antwort verarbeiten (true = korrekt)
  bool answer(Question q, int idx) {
    final isCorrect = idx == q.correctIndex;

    if (isCorrect) {
      q.sourcePair.corrects++;
      streak++;

      if (streak >= levelGoal) {
        level++;
        streak = 0;
        onLevelUp?.call();
      }
    } else {
      q.sourcePair.mistakes++;
      streak = 0;
      onWrong?.call();
    }
    return isCorrect;
  }

  /// Gewichtete Zufallsauswahl
  VocabPair _pickWeighted(List<VocabPair> pool) {
    final weights =
    pool.map((v) => (v.mistakes + 1) / (v.corrects + 1)).toList();
    final total = weights.reduce((a, b) => a + b);
    var rnd = math.Random().nextDouble() * total;

    for (var i = 0; i < pool.length; i++) {
      rnd -= weights[i];
      if (rnd <= 0 && pool[i] != _lastPair) {
        return pool[i];
      }
    }
    // Fallback
    return pool.firstWhere((v) => v != _lastPair, orElse: () => pool.first);
  }
}
