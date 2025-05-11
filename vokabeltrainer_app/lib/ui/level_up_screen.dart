import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/core/station_description_provider.dart';
import 'package:vokabeltrainer_app/ui/map_screen.dart';

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
        // Hintergrundbild für das Level
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
              // Levelname / Überschrift
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
                    // Ladeindikator während des Einlesens
                    return const CircularProgressIndicator();
                  } else if (snapshot.hasError) {
                    // Fehlermeldung beim Einlesen
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
                        style:
                        const TextStyle(fontSize: 18.0, color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                },
              ),

              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (_) => const MapScreen(),
                    ),
                  );
                },
                child: const Text('Karte'),
              ),

              const SizedBox(height: 20),
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
