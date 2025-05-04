// lib/ui/language_selection_screen.dart
import 'package:flutter/material.dart';
import 'question_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() =>
      _LanguageSelectionScreenState();
}

class _LanguageSelectionScreenState extends State<LanguageSelectionScreen> {
  static const _langs = [
    {'name': 'Deutsch',    'code': 'de'},
    {'name': 'English',    'code': 'en'},
    {'name': 'Українська', 'code': 'uk'},
    {'name': 'العربية',    'code': 'ar'},
    {'name': 'دری (Dari)', 'code': 'fa'},
  ];

  String _src = 'de';
  String _tgt = 'en';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sprachauswahl')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            const Text('Ausgangssprache', style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: _src,
              items: _langs
                  .map((l) => DropdownMenuItem(
                value: l['code'],
                child: Text(l['name']!),
              ))
                  .toList(),
              onChanged: (v) => setState(() => _src = v!),
            ),
            const SizedBox(height: 24),
            const Text('Zielsprache', style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: _tgt,
              items: _langs
                  .map((l) => DropdownMenuItem(
                value: l['code'],
                child: Text(l['name']!),
              ))
                  .toList(),
              onChanged: (v) => setState(() => _tgt = v!),
            ),
            const Spacer(),
            ElevatedButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) =>
                      QuestionScreen(source: _src, target: _tgt),
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
