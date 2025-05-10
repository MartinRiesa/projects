import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/core/level_info_loader.dart';

class LevelUpScreen extends StatelessWidget {
  final int previousLevel;
  final ImageProvider levelImage;
  final VoidCallback onContinue;

  /// Optionaler Callback, um eine Level-Beschreibung vorzulesen.
  /// Wenn `null`, wird kein Lautsprecher-Icon angezeigt.
  final VoidCallback? onSpeakDescription;

  const LevelUpScreen({
    Key? key,
    required this.previousLevel,
    required this.levelImage,
    required this.onContinue,
    this.onSpeakDescription,        // ← jetzt optional
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: FutureBuilder<String>(
          future: LevelInfoLoader.nameFor(previousLevel),
          builder: (c, snap) =>
              Text('Level $previousLevel: ${snap.data ?? ""} geschafft!'),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image(image: levelImage, fit: BoxFit.cover),
            ),
            const SizedBox(height: 16),

            // Levelname
            FutureBuilder<String>(
              future: LevelInfoLoader.nameFor(previousLevel),
              builder: (c, snap) {
                final name = snap.data ?? '';
                return Text(
                  name,
                  style:
                  const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                );
              },
            ),

            // Optionaler Lautsprecher-Button
            if (onSpeakDescription != null)
              IconButton(
                iconSize: 32,
                icon: const Icon(Icons.volume_up),
                onPressed: onSpeakDescription,
              ),

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
