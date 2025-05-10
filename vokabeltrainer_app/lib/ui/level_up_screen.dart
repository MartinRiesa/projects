import 'package:flutter/material.dart';

class LevelUpScreen extends StatelessWidget {
  final int previousLevel;
  final String levelName;                      // ← neu
  final String description;                    // ← neu
  final ImageProvider levelImage;
  final VoidCallback onContinue;
  final VoidCallback onSpeakDescription;       // ← neu

  const LevelUpScreen({
    Key? key,
    required this.previousLevel,
    required this.levelName,
    required this.description,
    required this.levelImage,
    required this.onContinue,
    required this.onSpeakDescription,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
      AppBar(title: Text('Level $previousLevel: $levelName geschafft!')),
      body: SafeArea(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image(image: levelImage, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),
            Text(
              levelName,
              style:
              const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            if (description.isNotEmpty) ...[
              Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                child: Text(
                  description,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                ),
              ),
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.volume_up),
                onPressed: onSpeakDescription,
              ),
            ],
            const Spacer(),
            Padding(
              padding: const EdgeInsets.only(bottom: 30),
              child: ElevatedButton(
                onPressed: onContinue,
                child: const Text('Weiter'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
