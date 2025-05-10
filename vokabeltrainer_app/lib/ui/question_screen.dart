import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/core/level_manager.dart';
import 'package:vokabeltrainer_app/core/question_generator.dart';
import 'package:vokabeltrainer_app/core/level_info_loader.dart';
import 'package:vokabeltrainer_app/core/station_description_provider.dart';
import 'package:vokabeltrainer_app/tts/tts_stub.dart'; // Dummy, keine TTS-Abhängigkeit
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
  // Prompt in targetLang, Antworten in sourceLang
  late final LevelManager _manager =
  LevelManager(sourceLang: widget.target, targetLang: widget.source);

  late Question _question;

  String _levelName = '';
  String _description = '';

  bool _awaitWrong = false;
  bool _awaitLevelUp = false;
  int? _wrongIndex;

  static const double _maxBlur = 30;
  double _blur = _maxBlur;
  ImageProvider? _levelImg;

  bool _loadError = false;
  String _errorMsg = '';

  // Dummy-TTS
  final FlutterTts _tts = FlutterTts();

  @override
  void initState() {
    super.initState();
    _initManager();
  }

  // ───────────────────── Manager + CSV-Infos ──────────────────────
  Future<void> _initManager() async {
    try {
      await _manager.init();
      await _loadInfo(_manager.level);
      _question = _manager.nextQuestion();

      _manager.onWrong = () => setState(() => _blur = _maxBlur);
      _manager.onLevelUp = () async {
        final prev = (_manager.level - 1).clamp(1, _manager.level);
        await _loadInfo(prev);
        setState(() {
          _awaitLevelUp = true;
          _blur = 0;
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

  Future<void> _loadInfo(int lvl) async {
    _levelName = await LevelInfoLoader.nameFor(lvl);
    _description = await StationDescriptionProvider.getExplanation(lvl);
    _levelImg ??= AssetImage('assets/images/$lvl.jpg');
  }

  // ───────────────────── Antwort-Logik ────────────────────────────
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
    await _loadInfo(_manager.level);
    setState(() {
      _question = _manager.nextQuestion();
      _awaitLevelUp = false;
      _wrongIndex = null;
    });
  }

  // ───────────────────── UI - Routing ─────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_loadError) {
      return ErrorScreen(errorMessage: _errorMsg, onRetry: _initManager);
    }
    if (_levelImg == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }
    if (_awaitLevelUp) {
      final prev = (_manager.level - 1).clamp(1, _manager.level);
      return LevelUpScreen(
        previousLevel: prev,
        levelImage: _levelImg!,
        completedCount: prev, // an Karte weiterreichen
        onContinue: _nextLevel,
      );
    }
    return QuizScreen(
      level: _manager.level,
      streak: _manager.streak,
      blur: _blur,
      levelImage: _levelImg!,
      levelName: _levelName,
      prompt: _question.prompt,
      onSpeak: () {},   // TTS-Stub
      onShowTts: () {},
      options: _question.options,
      correctIndex: _question.correctIndex,
      wrongIndex: _wrongIndex,
      awaitWrong: _awaitWrong,
      onAnswer: _check,
      onNextWrong: _nextWrong,
    );
  }
}
