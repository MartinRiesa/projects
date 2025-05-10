import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/core/level_manager.dart';

class QuizScreen extends StatelessWidget {
  final int level;
  final int streak;
  final double blur;
  final ImageProvider levelImage;
  final String prompt;
  final VoidCallback onSpeak;
  final VoidCallback onShowTts;
  final List<String> options;
  final int correctIndex;
  final int? wrongIndex;
  final bool awaitWrong;
  final ValueChanged<int> onAnswer;
  final VoidCallback onNextWrong;

  const QuizScreen({
    Key? key,
    required this.level,
    required this.streak,
    required this.blur,
    required this.levelImage,
    required this.prompt,
    required this.onSpeak,
    required this.onShowTts,
    required this.options,
    required this.correctIndex,
    required this.wrongIndex,
    required this.awaitWrong,
    required this.onAnswer,
    required this.onNextWrong,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Level $level – Streak $streak/${LevelManager.levelGoal}',
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: onShowTts,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Bild mit Blur-Effekt
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Image(
                  image: levelImage,
                  fit: BoxFit.cover,
                  alignment: Alignment.topCenter,
                ),
              ),
            ),
            // Frage + Lautsprecher-Icon
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Flexible(
                    child: Text(
                      prompt,
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
                    ),
                  ),
                  IconButton(
                    iconSize: 32,
                    icon: const Icon(Icons.volume_up),
                    onPressed: onSpeak,
                    onLongPress: onShowTts,
                  ),
                ],
              ),
            ),
            // Antwort-Buttons
            ...options.asMap().entries.map((e) {
              final i = e.key;
              final txt = e.value;
              Color? bg;
              if (awaitWrong) {
                if (i == correctIndex) bg = Colors.green;
                if (i == wrongIndex) bg = Colors.red;
              }
              return Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: bg,
                    minimumSize: const Size.fromHeight(56),
                  ),
                  onPressed: () => onAnswer(i),
                  child: Text(txt, style: const TextStyle(fontSize: 18)),
                ),
              );
            }),
            if (awaitWrong)
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10),
                child: ElevatedButton(
                  onPressed: onNextWrong,
                  child: const Text('Weiter'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
