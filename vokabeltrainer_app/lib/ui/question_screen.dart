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
  final LevelManager _manager = LevelManager();
  late Question _question;

  bool _awaitingContinue = false;   // nur nach falscher Antwort
  int? _wrongIndex;

  // Blur-Werte
  static const double _maxBlur = 30.0;
  double _blur = _maxBlur;

  ImageProvider? _levelImage;

  @override
  void initState() {
    super.initState();

    // Callbacks aus dem Algorithmus
    _manager.onWrong  = () => setState(() => _blur = _maxBlur);
    _manager.onLevelUp = () {
      setState(() {
        _blur       = _maxBlur;
        _levelImage = AssetImage('assets/images/${_manager.level}.jpg');
      });
    };

    _initFirstQuestion();
  }

  Future<void> _initFirstQuestion() async {
    await _manager.init();
    _levelImage = AssetImage('assets/images/${_manager.level}.jpg');
    setState(() => _question = _manager.nextQuestion());
  }

  void _handleAnswer(int idx) {
    if (_awaitingContinue) return;              // Doppel-Klick-Schutz

    final isCorrect = _manager.answer(_question, idx);

    if (isCorrect) {
      // Sofort weiter: Blur anpassen & neue Frage holen
      setState(() {
        _blur = _maxBlur * (1 - (_manager.streak / LevelManager.levelGoal));
        _question      = _manager.nextQuestion();
        _wrongIndex    = null;
        _awaitingContinue = false;              // bleibt false
      });
    } else {
      // Falsch: Antwort einfärben und „Weiter“-Button anzeigen
      setState(() {
        _wrongIndex       = idx;
        _awaitingContinue = true;
      });
    }
  }

  void _nextQuestionAfterWrong() {
    setState(() {
      _blur = _maxBlur * (1 - (_manager.streak / LevelManager.levelGoal));
      _question          = _manager.nextQuestion();
      _wrongIndex        = null;
      _awaitingContinue  = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_levelImage == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: Text('Level ${_manager.level} – Streak ${_manager.streak}/${LevelManager.levelGoal}'),
      ),
      body: SafeArea(
        child: Column(
          children: [
            // ── (1) Prompt ───────────────────────────────────────────
            Padding(
              padding: const EdgeInsets.all(16),
              child: Text(
                _question.prompt,                         // nur das Wort!
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),

            // ── (2) Antwort-Buttons ────────────────────────────────
            ..._question.options.asMap().entries.map((e) {
              final i   = e.key;
              final txt = e.value;

              Color? bg;
              if (_awaitingContinue) {
                if (i == _question.correctIndex) bg = Colors.green;
                else if (i == _wrongIndex)       bg = Colors.red;
              }

              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bg,
                    minimumSize: const Size.fromHeight(48),
                  ),
                  onPressed: () => _handleAnswer(i),
                  child: Text(txt),
                ),
              );
            }),

            // ── (3) „Weiter“ nur nach falscher Antwort ─────────────
            if (_awaitingContinue)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: ElevatedButton(
                  onPressed: _nextQuestionAfterWrong,
                  child: const Text('Weiter'),
                ),
              ),

            const Spacer(),

            // ── (4) Bild unten, feste 16:9-Box ─────────────────────
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
          ],
        ),
      ),
    );
  }
}
