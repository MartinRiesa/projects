// lib/ui/level_up_screen.dart
import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/ui/map_screen.dart';
import 'package:vokabeltrainer_app/core/level_info_loader.dart';
import 'package:vokabeltrainer_app/core/station_description_provider.dart';

class LevelUpScreen extends StatelessWidget {
  final int previousLevel;
  final ImageProvider levelImage;
  final VoidCallback onContinue;

  const LevelUpScreen({
    Key? key,
    required this.previousLevel,
    required this.levelImage,
    required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ──────────── Bild ────────────
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image(image: levelImage, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
            // ──────────── Level-Name ───────
            FutureBuilder<String>(
              future: LevelInfoLoader.nameFor(previousLevel),
              builder: (_, snap) => Text(
                snap.data ?? '',
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            // ──────────── Erklärung ────────
            FutureBuilder<String>(
              future: StationDescriptionProvider.getExplanation(previousLevel),
              builder: (_, snap) => Padding(
                padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Text(
                  snap.data ?? '',
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 16),
                ),
              ),
            ),
            const Spacer(),
            // ──────────── Buttons ──────────
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  child: const Text('Zur Karte'),
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const MapScreen()),
                  ),
                ),
                ElevatedButton(
                  child: const Text('Weiter'),
                  onPressed: onContinue,
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
