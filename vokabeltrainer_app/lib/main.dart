// lib/main.dart
//
// Einstiegspunkt: stellt GameState global via provider bereit.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'state/game_state.dart';
import 'ui/language_selection_screen.dart';
import 'ui/question_screen.dart';

void main() => runApp(const VokabelApp());

class VokabelApp extends StatelessWidget {
  const VokabelApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => GameState()),
      ],
      child: MaterialApp(
        title: 'Vokabeltrainer',
        theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
        home: const HomeScreen(),
      ),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final game = context.watch<GameState>();

    return Scaffold(
      appBar: AppBar(title: const Text('Vokabeltrainer')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text('Lernsprache: ${game.learnLang}'),
            Text('Muttersprache: ${game.nativeLang}'),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => const LanguageSelectionScreen(),
                ),
              ),
              child: const Text('Sprachen wählen'),
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => QuestionScreen(
                    source: game.nativeLang,
                    target: game.learnLang,
                  ),
                ),
              ),
              child: const Text('Start'),
            ),
          ],
        ),
      ),
    );
  }
}
