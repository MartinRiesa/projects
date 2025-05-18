import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/core/level_manager.dart';
import 'package:vokabeltrainer_app/core/level_info_loader.dart';

class QuizScreen extends StatelessWidget {
  final int level;                 // Levelnummer
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
        title: FutureBuilder<String>(
          future: LevelInfoLoader.nameFor(level),
          builder: (c, snap) {
            final name = snap.data ?? '';
            return Text(
              'Level $level – $name – '
                  'Streak $streak/${LevelManager.levelGoal}',
            );
          },
        ),
        actions: [
          IconButton(icon: const Icon(Icons.more_vert), onPressed: onShowTts),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // Bild mit Blur (BoxFit.contain statt BoxFit.cover)
            AspectRatio(
              aspectRatio: 16 / 9,
              child: ImageFiltered(
                imageFilter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                child: Image(image: levelImage, fit: BoxFit.contain),
              ),
            ),

            // Levelname über dem Bild
            FutureBuilder<String>(
              future: LevelInfoLoader.nameFor(level),
              builder: (c, snap) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Text(
                  snap.data ?? '',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
            ),

            // Prompt
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      prompt,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.volume_up), onPressed: onSpeak),
                ],
              ),
            ),

            // Auswahlmöglichkeiten
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                itemCount: options.length,
                itemBuilder: (context, index) {
                  final isCorrect = correctIndex == index;
                  final isWrong = wrongIndex == index;
                  Color? color;
                  if (isCorrect) color = Colors.green[200];
                  if (isWrong) color = Colors.red[200];
                  return Padding(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: color, // <-- Korrigiert!
                        minimumSize: const Size.fromHeight(48),
                        textStyle: const TextStyle(fontSize: 18),
                      ),
                      onPressed: awaitWrong && !isWrong
                          ? null
                          : () => onAnswer(index),
                      child: Text(options[index]),
                    ),
                  );
                },
              ),
            ),

            // Bei Fehler: "Weiter"-Button
            if (awaitWrong)
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: ElevatedButton(
                  onPressed: onNextWrong,
                  child: const Text("Weiter"),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
