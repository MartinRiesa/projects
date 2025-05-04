import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:provider/provider.dart';

import '../core/level_manager.dart';
import '../core/question_generator.dart';
import '../core/settings.dart';
import 'pronunciation_toggle.dart';

class QuestionScreen extends StatefulWidget {
  final String source;   // Lernsprache
  final String target;   // Muttersprache

  const QuestionScreen({
    super.key,
    required this.source,
    required this.target,
  });

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final _tts        = FlutterTts();
  final _manager    = LevelManager();
  static const _maxBlur = 20.0;

  double _blur = _maxBlur;
  bool   _awaitingContinue = false;
  bool   _levelCleared     = false;

  late Question _question;
  AssetImage?   _levelImage;
  int? _wrongIndex;

  @override
  void initState() {
    super.initState();
    _manager.onWrong = () => setState(() => _blur = _maxBlur);
    _manager.onLevelUp = () => setState(() {
      _blur           = 0;            // Bild un­ver­schleiert zeigen
      _levelCleared   = true;         // Stop – auf „Weiter“ warten
      _awaitingContinue = true;
      _levelImage     = AssetImage('assets/images/${_manager.level}.jpg');
    });

    _setupTts();
    _load();
  }

  Future<void> _setupTts() async => _tts.setSpeechRate(0.5);

  Future<void> _speak(String text) async {
    final settings = context.read<Settings>();
    if (!settings.speakEnabled) return;
    await _tts.stop();
    await _tts.setLanguage(_langCode(widget.source));
    await _tts.speak(text);
  }

  String _langCode(String name) =>
      ttsMap[name] ?? '${name.toLowerCase()}-${name.toUpperCase()}';

  Future<void> _load() async {
    await _manager.init(widget.source, widget.target);
    _levelImage = AssetImage('assets/images/${_manager.level}.jpg');
    setState(() => _question = _manager.nextQuestion());
    _speak(_question.prompt);
  }

  void _handleAnswer(int idx) {
    if (_awaitingContinue) return;
    final ok = _manager.answer(_question, idx);

    if (ok) {
      // Level fertig? -> warten auf manuellen Klick
      if (_levelCleared) return;
      setState(() {
        _blur = _maxBlur * (1 - _manager.streak / LevelManager.levelGoal);
        _question = _manager.nextQuestion();
      });
      _speak(_question.prompt);
    } else {
      setState(() {
        _wrongIndex = idx;
        _awaitingContinue = true;
      });
    }
  }

  void _next() {
    setState(() {
      _blur = _maxBlur * (1 - _manager.streak / LevelManager.levelGoal);
      _question = _manager.nextQuestion();
      _awaitingContinue = false;
      _wrongIndex = null;
      _levelCleared = false;
    });
    _speak(_question.prompt);
  }

  @override
  Widget build(BuildContext context) {
    if (_levelImage == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return ChangeNotifierProvider.value(
      value: context.read<Settings>(),
      child: Scaffold(
        appBar: AppBar(
          title: Text(
            'Level ${_manager.level} – Streak '
                '${_manager.streak}/${LevelManager.levelGoal}',
          ),
          actions: const [PronunciationToggle()],
        ),
        body: SafeArea(
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: ImageFiltered(
                  imageFilter: ImageFilter.blur(
                    sigmaX: _blur,
                    sigmaY: _blur,
                  ),
                  child: Image(image: _levelImage!, fit: BoxFit.cover),
                ),
              ),
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Flexible(
                      child: Text(
                        _question.prompt,
                        style:
                        const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
              ...List.generate(
                _question.options.length,
                    (i) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 20),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _wrongIndex == i
                          ? Colors.red
                          : (_question.correctIndex == i &&
                          _awaitingContinue)
                          ? Colors.green
                          : null,
                    ),
                    onPressed: () => _handleAnswer(i),
                    child: Text(_question.options[i]),
                  ),
                ),
              ),
              if (_awaitingContinue)
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: ElevatedButton(
                    onPressed: _next,
                    child: const Text('Weiter'),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
