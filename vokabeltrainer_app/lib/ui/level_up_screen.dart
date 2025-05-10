import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/ui/map_screen.dart';
import 'package:vokabeltrainer_app/core/level_info_loader.dart';
import 'package:vokabeltrainer_app/core/station_description_provider.dart';

class LevelUpScreen extends StatelessWidget {
  final int previousLevel;
  final ImageProvider levelImage;
  final int completedCount;      // Anzahl erledigter Level
  final VoidCallback onContinue;

  const LevelUpScreen({
    Key? key,
    required this.previousLevel,
    required this.levelImage,
    required this.completedCount,
    required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image(image: levelImage, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
            FutureBuilder<String>(
              future: LevelInfoLoader.nameFor(previousLevel),
              builder: (_, s) => Text(
                s.data ?? '',
                style:
                const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            FutureBuilder<String>(
              future: StationDescriptionProvider.getExplanation(previousLevel),
              builder: (_, s) => Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  s.data ?? '',
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const Spacer(),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => MapScreen(completedCount: completedCount),
                    ),
                  ),
                  child: const Text('Zur Karte'),
                ),
                ElevatedButton(
                  onPressed: onContinue,
                  child: const Text('Weiter'),
                ),
              ],
            ),
            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }
}
