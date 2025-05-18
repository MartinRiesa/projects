import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:vokabeltrainer_app/core/level_manager.dart';
import 'package:vokabeltrainer_app/core/question_generator.dart';
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
  // Sprachen getauscht (Prompt = targetLang, Optionen = sourceLang)
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

  final FlutterTts _tts = FlutterTts();
  bool _ttsReady = false;
  bool _autoTts = true;

  @override
  void initState() {
    super.initState();
    _setupTts().then((_) => _initManager());
  }

  Future<void> _setupTts() async {
    await _tts.setLanguage(_langToLocale(widget.target));
    await _tts.setSpeechRate(0.45);
    setState(() => _ttsReady = true);
  }

  String _langToLocale(String code) => switch (code) {
    'de' => 'de-DE',
    'en' => 'en-US',
    'uk' => 'uk-UA',
    'ar' => 'ar-SA',
    'fa' => 'fa-AF',
    _ => 'en-US',
  };

  Future<void> _speak(String text) async {
    if (!_ttsReady) return;
    await _tts.setLanguage(_langToLocale(widget.target));
    await _tts.stop();
    await _tts.speak(text);
  }

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
        setState(() {
          _awaitLevelUp = true;
          _blur = 0.0;
          _levelImg = AssetImage('assets/images/$prev.jpg');
        });
      };

      setState(() {
        _awaitWrong = false;
        _wrongIndex = null;
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
    _tts.stop();
    super.dispose();
  }

  // ------------------------------------------------------------------
  //  Korrigiert: Nur vorlesen, wenn KEIN Level-Up ansteht
  // ------------------------------------------------------------------
  void _check(int idx) {
    if (_awaitWrong || _awaitLevelUp) return;

    final ok = _manager.answer(_question, idx);
    if (ok) {
      setState(() {
        _blur = _maxBlur * (1 - _manager.streak / LevelManager.levelGoal);
        _question = _manager.nextQuestion();
        _wrongIndex = null;
      });
      if (!_awaitLevelUp) _speakIfNeeded(); // <- Fix
    } else {
      setState(() {
        _wrongIndex = idx;
        _awaitWrong = true;
      });
    }
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
        builder: (ctx, setState) {
          return Column(
            children: <Widget>[
              ListTile(
                title: const Text('Vorlesen aktivieren'),
                trailing: Switch(
                  value: _autoTts,
                  onChanged: (value) {
                    setState(() {
                      _autoTts = value;
                    });
                  },
                ),
              ),
            ],
          );
        },
      ),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Frage anzeigen'),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: () => _speakIfNeeded(),
          ),
        ],
      ),
      body: Center(
        child: _loadError
            ? Text(_errorMsg)
            : _awaitLevelUp
            ? Column(
          children: [
            Image(image: _levelImg!),
            const Text('Level-Up!'),
          ],
        )
            : _awaitWrong
            ? Column(
          children: <Widget>[
            const Text('Falsche Antwort!'),
            ElevatedButton(
              child: const Text('Weiter'),
              onPressed: _nextLevel,
            ),
          ],
        )
            : Column(
          children: <Widget>[
            const Text('Wähle die richtige Antwort:'),
            // Hier wird die Frage versteckt, aber die TTS bleibt erhalten
            // Text(_question.prompt), // Hier wird die Frage (Vokabel) nicht mehr angezeigt
            ElevatedButton(
              onPressed: () => _check(0),
              child: Text(_question.options[0]),
            ),
            ElevatedButton(
              onPressed: () => _check(1),
              child: Text(_question.options[1]),
            ),
            ElevatedButton(
              onPressed: () => _check(2),
              child: Text(_question.options[2]),
            ),
            ElevatedButton(
              onPressed: () => _check(3),
              child: Text(_question.options[3]),
            ),
          ],
        ),
      ),
    );
  }
}
