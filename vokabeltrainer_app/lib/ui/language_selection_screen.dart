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

  String _src = 'de'; // Ausgangssprache, default ist Deutsch

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Sprachauswahl')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ausgangssprache', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            DropdownButton<String>(
              value: _src,
              isExpanded: true,
              items: _langs.map((lang) {
                return DropdownMenuItem<String>(
                  value: lang['code'],
                  child: Text(lang['name']!),
                );
              }).toList(),
              onChanged: (value) {
                setState(() {
                  _src = value!;
                });
              },
            ),
            const SizedBox(height: 32),
            const Text('Zielsprache', style: TextStyle(fontSize: 18)),
            const SizedBox(height: 16),
            // Statt Dropdown: Feste Anzeige "Deutsch"
            Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4),
                color: Colors.grey.shade100,
              ),
              child: const Text('Deutsch', style: TextStyle(fontSize: 16)),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(
                      builder: (_) => QuestionScreen(
                        source: _src,
                        target: 'de', // Zielsprache immer Deutsch
                      ),
                    ),
                  );
                },
                child: const Text('Start'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
