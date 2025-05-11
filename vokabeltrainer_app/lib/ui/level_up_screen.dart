// lib/ui/level_up_screen.dart
import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/ui/map_screen.dart';
import 'package:vokabeltrainer_app/core/level_info_loader.dart';
import 'package:vokabeltrainer_app/core/station_description_provider.dart';
import 'package:vokabeltrainer_app/core/station.dart';     // ← neu

class LevelUpScreen extends StatelessWidget {
  final int previousLevel;
  final ImageProvider levelImage;
  final VoidCallback onContinue;
  final Station? station;                                // ← neu (optional)

  const LevelUpScreen({
    Key? key,
    required this.previousLevel,
    required this.levelImage,
    required this.onContinue,
    this.station,
  }) : super(key: key);

  /// Erklärung priorisieren:
  ///   1) direkte Station-Beschreibung (falls gesetzt)
  ///   2) StationDescriptionProvider-Future
  Widget _buildExplanation() {
    if (station?.description.isNotEmpty ?? false) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          station!.description,
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      );
    }

    // Fallback: ursprünglicher Future-Getter
    return FutureBuilder<String>(
      future: StationDescriptionProvider.getExplanation(previousLevel),
      builder: (_, snap) => Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          snap.data ?? '',
          textAlign: TextAlign.center,
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ───────── Bild ─────────
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image(image: levelImage, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
            // ───────── Level-Name ───
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
            // ───────── Erklärung ────
            _buildExplanation(),
            const Spacer(),
            // ───────── Buttons ──────
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
// lib/ui/level_up_screen.dart
import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/ui/map_screen.dart';
import 'package:vokabeltrainer_app/core/level_info_loader.dart';
import 'package:vokabeltrainer_app/core/station_description_provider.dart';
import 'package:vokabeltrainer_app/core/station.dart';

class LevelUpScreen extends StatelessWidget {
  final int previousLevel;
  final ImageProvider levelImage;
  final VoidCallback onContinue;
  final Station? station; // optional

  const LevelUpScreen({
    Key? key,
    required this.previousLevel,
    required this.levelImage,
    required this.onContinue,
    this.station,
  }) : super(key: key);

  /// Liefert den anzuzeigenden Erklärungstext.
  ///   1) station.description, falls nicht leer
  ///   2) Ergebnis des Providers
  ///   3) Platzhalter, falls beides leer
  Widget _buildExplanation() {
    // 1) Direkte Beschreibung aus Station
    if (station?.description.trim().isNotEmpty ?? false) {
      return _textBox(station!.description.trim());
    }

    // 2) Fallback-Provider
    return FutureBuilder<String>(
      future: StationDescriptionProvider.getExplanation(previousLevel),
      builder: (_, snap) {
        final txt = snap.data?.trim() ?? '';
        return _textBox(
          txt.isEmpty
              ? 'Weiter so – auf zum nächsten Ziel!' // 3) Platzhalter
              : txt,
        );
      },
    );
  }

  /// Zentrierte Textbox mit Standard-Padding
  Widget _textBox(String text) => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
    child: Text(
      text,
      textAlign: TextAlign.center,
      style: const TextStyle(fontSize: 16),
    ),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ─ Bild ─
            AspectRatio(
              aspectRatio: 16 / 9,
              child: Image(image: levelImage, fit: BoxFit.cover),
            ),
            const SizedBox(height: 12),
            // ─ Level-Titel ─
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
            // ─ Erklärung ─
            _buildExplanation(),
            const Spacer(),
            // ─ Buttons ─
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
