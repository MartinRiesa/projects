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
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen> {
  final LevelManager _manager = LevelManager();
  late Question _question;
  bool _answered = false;
  int? _wrongIndex;
  static const double _maxBlur = 30.0;    // erhöht von 10 auf 30
  double _blur = _maxBlur;                // initial maximal verschwommen
  ImageProvider? _levelImage;

  @override
  void initState() {
    super.initState();
    _manager.onWrong = () {
      setState(() => _blur = _maxBlur);
    };
    _manager.onLevelUp = () {
      setState(() {
        _blur = _maxBlur;
        _levelImage = AssetImage('assets/images/${_manager.level}.jpg');
      });
    };
    _loadInitial();
  }

  Future<void> _loadInitial() async {
    await _manager.init();
    _levelImage = AssetImage('assets/images/${_manager.level}.jpg');
    setState(() => _question = _manager.nextQuestion());
  }

  void _handleAnswer(int idx) {
    if (_answered) return;
    final correct = _manager.answer(_question, idx);
    if (correct) {
      setState(() {
        // stärkere Reduktion: pro Streak-Punkt 1/10 von max
        _blur = _maxBlur * (1 - (_manager.streak / LevelManager.levelGoal));
        _question = _manager.nextQuestion();
        _wrongIndex = null;
        _answered = false;
      });
    } else {
      setState(() {
        _wrongIndex = idx;
        _answered = true;
      });
    }
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
        title: Text(
          'Level ${_manager.level} – Streak ${_manager.streak}/${LevelManager.levelGoal}',
        ),
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: Image(image: _levelImage!, fit: BoxFit.cover),
          ),
          if (_blur > 0)
            Positioned.fill(
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: _blur, sigmaY: _blur),
                child: Container(color: Colors.black.withOpacity(0)),
              ),
            ),
          Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  _question.prompt,
                  style: const TextStyle(fontSize: 20, color: Colors.white),
                ),
              ),
              ..._question.options.asMap().entries.map((e) {
                final idx = e.key, txt = e.value;
                Color? bg;
                if (_answered) {
                  if (idx == _question.correctIndex) bg = Colors.green;
                  else if (idx == _wrongIndex) bg = Colors.red;
                }
                return Padding(
                  padding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: bg),
                    onPressed: () => _handleAnswer(idx),
                    child: Text(txt),
                  ),
                );
              }).toList(),
              if (_answered)
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _blur = _maxBlur *
                          (1 - (_manager.streak / LevelManager.levelGoal));
                      _question = _manager.nextQuestion();
                      _answered = false;
                      _wrongIndex = null;
                    });
                  },
                  child: const Text('Weiter'),
                ),
            ],
          ),
        ],
      ),
    );
  }
}
