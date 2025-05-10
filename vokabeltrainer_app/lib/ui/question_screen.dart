import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/core/level_manager.dart';
import 'package:vokabeltrainer_app/core/question_generator.dart';
import 'package:vokabeltrainer_app/core/level_info_loader.dart';
import 'package:vokabeltrainer_app/tts/tts_stub.dart';     // Dummy-TTS, macht nichts

import 'error_screen.dart';
import 'level_up_screen.dart';
import 'quiz_screen.dart';

class QuestionScreen extends StatefulWidget {
  final String source; // Muttersprache
  final String target; // Zielsprache

  const QuestionScreen({
    Key? key,
    required this.source,
    required this.target,
  }) : super(key: key);

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  // Prompt = targetLang, Antwortoptionen = sourceLang
  late final LevelManager _manager =
  LevelManager(sourceLang: widget.target, targetLang: widget.source);

  late Question _question;

  // Level-Infos aus CSV
  String _levelName = '';
  String _description = '';

  bool _awaitWrong = false;
  bool _awaitLevelUp = false;
  int? _wrongIndex;

  static const double _maxBlur = 30.0;
  double _blur = _maxBlur;
  ImageProvider? _levelImg;

  bool _loadError = false;
  String _errorMsg = '';

  // Dummy-TTS (keine NuGet-Pflicht)
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initManager();
  }

  // ────── TTS-Wrapper (macht nichts) ─────────────────────────────
  Future<void> _speak(String _text) async {}
  Future<void> _speakPrompt() async {}
  Future<void> _speakDescription() async {}

  // ────── Manager + Level-Info laden ─────────────────────────────
  Future<void> _initManager() async {
    try {
      await _manager.init();
      await _loadLevelInfo(_manager.level);
      _question = _manager.nextQuestion();

      _manager.onWrong = () => setState(() => _blur = _maxBlur);

      _manager.onLevelUp = () async {
        final prev = (_manager.level - 1).clamp(1, _manager.level);
        await _loadLevelInfo(prev);
        setState(() {
          _awaitLevelUp = true;
          _blur = 0.0;
          _levelImg = AssetImage('assets/images/$prev.jpg');
        });
      };

      setState(() {
        _awaitWrong = false;
        _blur = _maxBlur;
      });
    } catch (e) {
      setState(() {
        _loadError = true;
        _errorMsg = e.toString();
      });
    }
  }

  Future<void> _loadLevelInfo(int level) async {
    _levelName = await LevelInfoLoader.nameFor(level);
    _description =
    await LevelInfoLoader.descriptionFor(level, widget.source);
    _levelImg ??= AssetImage('assets/images/$level.jpg');
  }

  // ────── Antwort- & Level-Logik ─────────────────────────────────
  void _check(int idx) {
    if (_awaitWrong || _awaitLevelUp) return;

    final ok = _manager.answer(_question, idx);
    if (ok) {
      setState(() {
        _blur = _maxBlur * (1 - _manager.streak / LevelManager.levelGoal);
        _question = _manager.nextQuestion();
        _wrongIndex = null;
      });
    } else {
      setState(() {
        _wrongIndex = idx;
        _awaitWrong = true;
      });
    }
  }

  void _nextWrong() {
    setState(() {
      _blur = _maxBlur;
      _question = _manager.nextQuestion();
      _awaitWrong = false;
      _wrongIndex = null;
    });
  }

  Future<void> _nextLevel() async {
    setState(() {
      _blur = _maxBlur;
      _levelImg = AssetImage('assets/images/${_manager.level}.jpg');
    });
    await _loadLevelInfo(_manager.level);
    setState(() {
      _question = _manager.nextQuestion();
      _awaitLevelUp = false;
      _wrongIndex = null;
    });
  }

  // ────── Fehler neu laden ───────────────────────────────────────
  void _retry() {
    setState(() {
      _loadError = false;
      _blur = _maxBlur;
      _levelImg = null;
    });
    _initManager();
  }

  // ────── UI-Routing ─────────────────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loadError) {
      return ErrorScreen(errorMessage: _errorMsg, onRetry: _retry);
    }

    if (_levelImg == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    if (_awaitLevelUp) {
      final prev = (_manager.level - 1).clamp(1, _manager.level);
      return LevelUpScreen(
        previousLevel: prev,
        levelName: _levelName,
        description: _description,
        levelImage: _levelImg!,
        onContinue: _nextLevel,
        onSpeakDescription: _speakDescription, // Button tut nichts
      );
    }

    return QuizScreen(
      level: _manager.level,
      streak: _manager.streak,
      blur: _blur,
      levelImage: _levelImg!,
      levelName: _levelName,
      prompt: _question.prompt,
      onSpeak: _speakPrompt,   // Lautsprecher ohne Funktion
      onShowTts: () {},        // Popup deaktiviert
      options: _question.options,
      correctIndex: _question.correctIndex,
      wrongIndex: _wrongIndex,
      awaitWrong: _awaitWrong,
      onAnswer: _check,
      onNextWrong: _nextWrong,
    );
  }
}
