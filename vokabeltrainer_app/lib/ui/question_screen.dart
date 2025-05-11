import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/core/level_manager.dart';
import 'package:vokabeltrainer_app/core/question_generator.dart';
import 'package:vokabeltrainer_app/core/station_loader.dart';
import 'package:vokabeltrainer_app/core/station.dart';
import 'package:vokabeltrainer_app/tts/tts_service.dart';

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
  late final LevelManager _manager =
  LevelManager(sourceLang: widget.target, targetLang: widget.source);

  late Question _question;

  bool _awaitWrong = false;
  bool _awaitLevelUp = false;
  int? _wrongIndex;

  static const double _maxBlur = 30.0;
  double _blur = _maxBlur;
  ImageProvider? _levelImg;

  bool _loadError = false;
  String _errorMsg = '';

  bool _autoTts = true;

  List<Station> _stations = [];        // ❸ Stationsliste gecached
  Station? _latestStation;             // ❹ Station des gerade abgeschlossenen Levels

  @override
  void initState() {
    super.initState();
    _initAll();
  }

  Future<void> _initAll() async {
    await TtsService.instance.init(_langToLocale(widget.target));
    await _loadStations();
    await _initManager();
  }

  Future<void> _loadStations() async {
    _stations = await StationLoader.load();
  }

  String _langToLocale(String code) => switch (code) {
    'de' => 'de-DE',
    'en' => 'en-US',
    'uk' => 'uk-UA',
    'ar' => 'ar-SA',
    'fa' => 'fa-AF',
    _ => 'en-US',
  };

  Future<void> _speak(String text) =>
      TtsService.instance.speak(text, locale: _langToLocale(widget.target));

  Future<void> _speakIfNeeded() =>
      _autoTts ? _speak(_question.prompt) : Future.value();

  Future<void> _initManager() async {
    try {
      await _manager.init();
      _levelImg = AssetImage('assets/images/${_manager.level}.jpg');
      _question = _manager.nextQuestion();

      _manager.onWrong = () => setState(() => _blur = _maxBlur);
      _manager.onLevelUp = () {
        final prev = (_manager.level - 1).clamp(1, _manager.level);
        // ❺ passende Station für Dialog ermitteln
        _latestStation = _stations.firstWhere(
              (s) => s.level == prev,
          orElse: () => Station(
            level: prev,
            name: 'Unbekannt',
            description: '',
            latitude: 0,
            longitude: 0,
          ),
        );
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
      _speakIfNeeded();
    } catch (e) {
      setState(() {
        _loadError = true;
        _errorMsg = e.toString();
      });
    }
  }

  @override
  void dispose() {
    TtsService.instance.stop();
    super.dispose();
  }

  void _check(int idx) {
    if (_awaitWrong || _awaitLevelUp) return;

    final ok = _manager.answer(_question, idx);
    if (ok) {
      setState(() {
        _blur = _maxBlur * (1 - _manager.streak / LevelManager.levelGoal);
        _question = _manager.nextQuestion();
        _wrongIndex = null;
      });
      if (!_awaitLevelUp) _speakIfNeeded();
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
    _speakIfNeeded();
  }

  void _nextLevel() {
    setState(() {
      _blur = _maxBlur;
      _levelImg = AssetImage('assets/images/${_manager.level}.jpg');
      _question = _manager.nextQuestion();
      _awaitLevelUp = false;
      _wrongIndex = null;
    });
    _speakIfNeeded();
  }

  void _showTtsPopup() => showDialog(
    context: context,
    builder: (c) => AlertDialog(
      title: const Text('Vorlese-Einstellungen'),
      content: StatefulBuilder(
        builder: (ctx, setLocal) => SwitchListTile(
          title: const Text('Automatisch vorlesen'),
          value: _autoTts,
          onChanged: (v) {
            setLocal(() => _autoTts = v);
            setState(() => _autoTts = v);
          },
        ),
      ),
      actions: [
        TextButton(
          onPressed: Navigator.of(c).pop,
          child: const Text('OK'),
        ),
      ],
    ),
  );

  void _retry() {
    setState(() {
      _loadError = false;
      _blur = _maxBlur;
    });
    _initManager();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadError) {
      return ErrorScreen(errorMessage: _errorMsg, onRetry: _retry);
    }
    if (_levelImg == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }
    if (_awaitLevelUp) {
      final prevLevel = (_manager.level - 1).clamp(1, _manager.level);
      return LevelUpScreen(
        previousLevel: prevLevel,
        levelImage: _levelImg!,
        station: _latestStation,          // ❻ Station wird übergeben
        onContinue: _nextLevel,
      );
    }
    return QuizScreen(
      level: _manager.level,
      streak: _manager.streak,
      blur: _blur,
      levelImage: _levelImg!,
      prompt: _question.prompt,
      onSpeak: () => _speak(_question.prompt),
      onShowTts: _showTtsPopup,
      options: _question.options,
      correctIndex: _question.correctIndex,
      wrongIndex: _wrongIndex,
      awaitWrong: _awaitWrong,
      onAnswer: _check,
      onNextWrong: _nextWrong,
    );
  }
}
