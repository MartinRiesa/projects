import 'package:flutter/material.dart';

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
  final void Function(int) onAnswer;
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
        title: Text('Level $level'),
        actions: [
          IconButton(
            icon: const Icon(Icons.volume_up),
            onPressed: onShowTts,
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const SizedBox(height: 16),
          // Bild mit Blur-Effekt
          Stack(
            children: [
              Image(
                image: levelImage,
                width: double.infinity,
                height: 180,
                fit: BoxFit.cover,
              ),
              if (blur > 0)
                Positioned.fill(
                  child: BackdropFilter(
                    filter: ImageFilter.blur(sigmaX: blur, sigmaY: blur),
                    child: Container(color: Colors.transparent),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 16),
          // DIE VOKABEL (PROMPT), JETZT TRANSPARENT
          Text(
            prompt,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              fontSize: 22,
              color: Colors.transparent, // Unsichtbar!
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          // Streak & Vorlesen Button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                streak.toString(),
                style: const TextStyle(fontSize: 24),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up),
                onPressed: onSpeak,
              ),
            ],
          ),
          const SizedBox(height: 24),
          // Antwortmöglichkeiten (Buttons)
          ...List.generate(options.length, (idx) {
            Color? buttonColor;
            if (awaitWrong) {
              if (idx == correctIndex) {
                buttonColor = Colors.green[200];
              } else if (idx == wrongIndex) {
                buttonColor = Colors.red[200];
              }
            }
            return Padding(
              padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 24.0),
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: buttonColor ?? Colors.white,
                  foregroundColor: Colors.black,
                  minimumSize: const Size.fromHeight(48),
                ),
                onPressed: awaitWrong ? null : () => onAnswer(idx),
                child: Text(
                  options[idx],
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            );
          }),
          if (awaitWrong)
            Padding(
              padding: const EdgeInsets.only(top: 24.0),
              child: ElevatedButton(
                onPressed: onNextWrong,
                child: const Text('Weiter'),
              ),
            ),
        ],
      ),
    );
  }
}
