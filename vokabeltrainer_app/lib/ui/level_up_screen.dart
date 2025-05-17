import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/core/station_description_provider.dart';
import 'package:vokabeltrainer_app/ui/map_screen_static_marker.dart';
import 'package:vokabeltrainer_app/ui/map_screen_progress.dart'; // NEU: Fortschritt-Karte

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
              const SizedBox(height: 10),

              // Erklärungstext aus der CSV
              FutureBuilder<String?>(
                future: StationDescriptionProvider.getExplanation(previousLevel),
                builder: (context, snapshot) {
                  if (snapshot.connectionState == ConnectionState.waiting) {
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    return const Text(
                      'Fehler beim Laden der Erklärung',
                      style: TextStyle(fontSize: 16.0, color: Colors.red),
                      textAlign: TextAlign.center,
                    );
                  } else {
                    final explanation = snapshot.data ?? '';
                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16.0, vertical: 8.0),
                      child: Text(
                        explanation,
                        style: const TextStyle(fontSize: 18.0, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 20),

              // Button: Fortschritt-Karte
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MapScreenProgress(
                        completedLevels: previousLevel, // alle erledigten Level
                        nextLevel: previousLevel,        // das nächste anstehende Level
                      ),
                    ),
                  );
                },
                child: const Text('Deutschlandkarte – Fortschritt'),
              ),

              const SizedBox(height: 12),

              // Bisheriger Button „Deutschlandkarte ansehen“ – statische Einzelmarkierung
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => MapScreenStaticMarker(
                        stationIndex: previousLevel - 1, // Index ggf. anpassen!
                      ),
                    ),
                  );
                },
                child: const Text('Deutschlandkarte (aktuelles Level)'),
              ),

              const SizedBox(height: 20),

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
