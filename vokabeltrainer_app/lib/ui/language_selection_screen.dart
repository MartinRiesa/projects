// lib/ui/language_selection_screen.dart
//
// Dialog zur Auswahl von Lern- und Muttersprache.
// Speichert die Auswahl in GameState via Provider.

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../state/game_state.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  late String _learn;
  late String _native;

  @override
  void initState() {
    super.initState();
    final state = context.read<GameState>();
    _learn  = state.learnLang;
    _native = state.nativeLang;
  }

  @override
  Widget build(BuildContext context) {
    final languages = ['Deutsch', 'English', 'Spanish', 'French'];

    return Scaffold(
      appBar: AppBar(title: const Text('Sprachauswahl')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            const Text('Lernsprache'),
            DropdownButton<String>(
              value: _learn,
              items: languages
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (v) => setState(() => _learn = v!),
            ),
            const SizedBox(height: 24),
            const Text('Muttersprache'),
            DropdownButton<String>(
              value: _native,
              items: languages
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (v) => setState(() => _native = v!),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () {
                if (_learn == _native) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text(
                          'Lern- und Muttersprache müssen verschieden sein'),
                    ),
                  );
                  return;
                }
                context.read<GameState>().setLanguages(_learn, _native);
                Navigator.pop(context);
              },
              child: const Text('Speichern'),
            ),
          ],
        ),
      ),
    );
  }
}
