import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/core/level_manager.dart';
import 'package:vokabeltrainer_app/core/vocab_loader.dart';
import 'package:vokabeltrainer_app/core/vocab_pair.dart';

/// Verwaltet den Quiz-Status (Laden, Timer, Auswertung).
class QuizController extends ChangeNotifier {
  QuizController(this._levelManager);

  final LevelManager _levelManager;

  // ---------------- Öffentliche Getter ----------------
  bool get isLoading => _isLoading;
  VocabPair get currentPair => _currentPair;
  int get currentIndex => _currentIndex;
  int get totalQuestions => _totalQuestions;
  bool get isAnswerRevealed => _isAnswerRevealed;
  bool get isCorrect => _isCorrect;
  Duration get elapsed => _elapsed;
  String get elapsedFormatted =>
      '${_twoDigits(_elapsed.inMinutes.remainder(60))}:${_twoDigits(_elapsed.inSeconds.remainder(60))}';

  // ---------------- Interner Zustand ------------------
  bool _isLoading = true;
  late List<VocabPair> _vocabList;
  late VocabPair _currentPair;

  int _currentIndex = 0;
  int _totalQuestions = 0;

  bool _isFirstAttempt = true;
  bool _isCorrect = false;
  bool _isAnswerRevealed = false;
  Duration _elapsed = Duration.zero;

  final Stopwatch _stopwatch = Stopwatch();
  Timer? _timer;

  // ---------------- Initialisieren --------------------
  Future<void> load() async {
    // Lade alle Paare für die gewählten Sprachen
    _vocabList = await VocabLoader.load(
      _levelManager.sourceLang,
      _levelManager.targetLang,
    );

    // Optional nur Teilmenge für aktuelles Level wählen:
    final max = (_levelManager.level * 7).clamp(1, _vocabList.length);
    _vocabList = _vocabList.take(max).toList()..shuffle(Random());

    _totalQuestions = _vocabList.length;
    _currentPair = _vocabList.first;
    _isLoading = false;

    _startTimer();
    notifyListeners();
  }

  // ---------------- Benutzeraktionen ------------------
  void checkAnswer(String rawInput) {
    if (_isAnswerRevealed) return; // Doppelklick vermeiden

    final user = rawInput.trim().toLowerCase();
    final correct = _currentPair.answer.toLowerCase();

    _isCorrect = user == correct;
    _isAnswerRevealed = true;
    _isFirstAttempt = false;
    notifyListeners();
  }

  /// Liefert **true**, wenn keine Fragen mehr übrig sind.
  bool nextQuestion() {
    if (!_isAnswerRevealed) return false;

    _currentIndex++;
    if (_currentIndex >= _vocabList.length) {
      _stopTimer();
      return true; // fertig
    }

    _currentPair = _vocabList[_currentIndex];
    _resetFlags();
    notifyListeners();
    return false;
  }

  // ---------------- interne Helfer --------------------
  void _resetFlags() {
    _isFirstAttempt = true;
    _isCorrect = false;
    _isAnswerRevealed = false;
  }

  void _startTimer() {
    _stopwatch.start();
    _timer = Timer.periodic(const Duration(seconds: 1), (_) {
      _elapsed = _stopwatch.elapsed;
      notifyListeners();
    });
  }

  void _stopTimer() {
    _stopwatch.stop();
    _timer?.cancel();
  }

  String _twoDigits(int n) => n.toString().padLeft(2, '0');

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }
}
