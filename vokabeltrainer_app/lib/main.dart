import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/core/level_manager.dart';
import 'package:vokabeltrainer_app/ui/question_screen.dart';

void main() {
  runApp(const VokabeltrainerApp());
}

class VokabeltrainerApp extends StatelessWidget {
  const VokabeltrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vokabeltrainer',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.teal),
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Start')),
      body: Center(
        child: ElevatedButton(
          onPressed: () {
            // Beispiel: Deutsch → Englisch
            final manager = LevelManager(sourceLang: 'de', targetLang: 'en');
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => QuestionScreen(levelManager: manager),
              ),
            );
          },
          child: const Text('Quiz starten'),
        ),
      ),
    );
  }
}
