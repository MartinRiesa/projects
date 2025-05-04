// lib/ui/question_screen.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/core/question_generator.dart';
import 'package:vokabeltrainer_app/core/level_manager.dart';

class QuestionScreen extends StatefulWidget {
  final String source;
  final String target;

  const QuestionScreen({
    Key? key,
    required this.source,
    required this.target,
  }) : super(key: key);

  @override
  State<QuestionScreen> createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  // Der aktuelle LevelManager erwartet keine Parameter – daher jetzt parameterlos.
  late final LevelManager _manager = LevelManager();

  late Question _question;
  bool _awaitingWrongContinue = false;   // Warten nach falscher Antwort
  bool _awaitingLevelContinue = false;   // Warten nach Level-Up
  int? _wrongIndex;

  // Blur-Konstanten
  static const double _maxBlur = 30.0;
  double _blur = _maxBlur;

  ImageProvider? _levelImage;

  @override
  void initState() {
    super.initState();

    // Fehler → Bild wieder komplett verschwommen
    _manager.onWrong = () => setState(() => _blur = _maxBlur);

    // Level-Up → Bild vollständig zeigen & auf „Weiter“ warten
    _manager.onLevelUp = () {
      final prevLevel = (_manager.level - 1).clamp(1, _manager.level);
      setState(() {
        _awaitingLevelContinue = true;
        _blur = 0.0;
        _levelImage = AssetImage('assets/images/$prevLevel.jpg');
      });
    };

    _loadFirst();
  }

  Future<void> _loadFirst() async {
    await _manager.init();
    _levelImage = AssetImage('assets/images/${_manager.level}.jpg');
    setState(() => _question = _manager.nextQuestion());
  }

  // ─────────────────────────  Antwort-Auswertung  ──────────────────────────────
  void _handleAnswer(int idx) {
    if (_awaitingWrongContinue || _awaitingLevelContinue) return;

    final correct = _manager.answer(_question, idx);

    if (correct) {
      // Falls Level-Up ausgelöst wurde, ab hier warten wir auf den Weiter-Button
      if (_awaitingLevelContinue) return;

      setState(() {
        _blur = _maxBlur * (1 - (_manager.streak / LevelManager.levelGoal));
        _question = _manager.nextQuestion();
        _wrongIndex = null;
        _awaitingWrongContinue = false;
      });
    } else {
      setState(() {
        _wrongIndex = idx;
        _awaitingWrongContinue = true;
      });
    }
  }

  void _nextAfterWrong() {
    setState(() {
      _blur = _maxBlur * (1 - (_manager.streak / LevelManager.levelGoal));
      _question = _manager.nextQuestion();
      _wrongIndex = null;
      _awaitingWrongContinue = false;
    });
  }

  void _nextLevel() {
    setState(() {
      _blur = _maxBlur;
      _levelImage = AssetImage('assets/images/${_manager.level}.jpg');
      _question = _manager.nextQuestion();
      _awaitingLevelContinue = false;
      _wrongIndex = null;
      _awaitingWrongContinue = false;
    });
  }

  // ─────────────────────────────  UI-Aufbau  ───────────────────────────────────
  @override
  Widget build(BuildContext context) {
    if (_levelImage == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    // ─────  Level geschafft – Bild freigelegt  ─────
    if (_awaitingLevelContinue) {
      return Scaffold(
        appBar: AppBar(
          title: Text('Level ${_manager.level - 1} geschafft!'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              AspectRatio(
                aspectRatio: 16 / 9,
                child: Image(image: _levelImage!, fit: BoxFit.cover),
              ),
              const SizedBox(height: 24),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'Super gemacht! Tippe auf „Weiter“, um das nächste Level zu starten.',
                  textAlign: TextAlign.center,
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              Padding(
                padding: const EdgeInsets.only(bottom: 30),
                child: ElevatedButton(
                  onPressed: _nextLevel,
                  child: const Text('Weiter'),
                ),
              ),
            ],
          ),
        ),
      );
    }

    // ─────  Regulärer Frage-Screen  ─────
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Level ${_manager.level} – Streak ${_manager.streak}/${LevelManager.levelGoal}',
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // (1) Bild oben
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: _blur, sigmaY: _blur),
                child: Image(
                  image: _levelImage!,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),

            // (2) Vokabel-Prompt
            Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                _question.prompt,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
            ),

            // (3) Antwort-Buttons
            ..._question.options.asMap().entries.map((e) {
              final i = e.key;
              final txt = e.value;

              Color? bg;
              if (_awaitingWrongContinue) {
                if (i == _question.correctIndex) bg = Colors.green;
                else if (i == _wrongIndex) bg = Colors.red;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bg,
                    minimumSize: const Size.fromHeight(56),
                  ),
                  onPressed: () => _handleAnswer(i),
                  child: Text(
                    txt,
                    style: const TextStyle(fontSize: 18),
                  ),
                ),
              );
            }),

            // (4) „Weiter“-Button nach falscher Antwort
            if (_awaitingWrongContinue)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton(
                  onPressed: _nextAfterWrong,
                  child: const Text('Weiter'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
