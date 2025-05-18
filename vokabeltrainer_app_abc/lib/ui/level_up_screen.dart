import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/ui/map_screen_progress.dart'; // Fortschritt-Karte

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
      body: Container(
        decoration: BoxDecoration(
          image: DecorationImage(
            image: levelImage,
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Überschrift: aktuelles Level
              Text(
                'Level $previousLevel',
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 24),

              // Button für die Fortschritts-Karte
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MapScreenProgress(
                        completedLevels: previousLevel, // erledigte Level
                        nextLevel: previousLevel,        // anstehendes Level
                        levelImage: levelImage,          // Bild an die Karte übergeben
                      ),
                    ),
                  );
                },
                child: const Text('Deutschlandkarte – Fortschritt'),
              ),

              const SizedBox(height: 28),

              // Button „Weiter“ – führt ins nächste Level
              ElevatedButton(
                onPressed: onContinue,
                child: const Text('Weiter'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
