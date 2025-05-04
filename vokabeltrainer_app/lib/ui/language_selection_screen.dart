import 'package:flutter/material.dart';
import '../core/vocab_loader.dart';
import 'question_screen.dart';

class LanguageSelectionScreen extends StatefulWidget {
  const LanguageSelectionScreen({super.key});

  @override
  State<LanguageSelectionScreen> createState() => _LangSelState();
}

class _LangSelState extends State<LanguageSelectionScreen> {
  List<String> _langs = [];
  String? _learn;   // Lernsprache
  String? _native;  // Muttersprache

  @override
  void initState() {
    super.initState();
    _init();
  }

  Future<void> _init() async {
    final (_, header) = await loadAllPairs();
    setState(() {
      _langs = header;
      _learn  = header.elementAtOrNull(1) ?? header.first;
      _native = header.first;
    });
  }

  void _setLearn(String v) => setState(() {
    _learn = v;
    if (_learn == _native) {
      // automatisch tauschen, damit jede Sprache wählbar ist
      _native =
          _langs.firstWhere((l) => l != _learn, orElse: () => _native!);
    }
  });

  void _setNative(String v) => setState(() {
    _native = v;
    if (_learn == _native) {
      _learn = _langs.firstWhere((l) => l != _native, orElse: () => _learn!);
    }
  });

  @override
  Widget build(BuildContext context) {
    if (_langs.isEmpty) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Sprachauswahl')),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Ich möchte lernen …', style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: _learn,
              items: _langs
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (v) => _setLearn(v!),
            ),
            const SizedBox(height: 24),
            const Text('Meine Muttersprache', style: TextStyle(fontSize: 18)),
            DropdownButton<String>(
              value: _native,
              items: _langs
                  .map((l) => DropdownMenuItem(value: l, child: Text(l)))
                  .toList(),
              onChanged: (v) => _setNative(v!),
            ),
            const Spacer(),
            Center(
              child: ElevatedButton.icon(
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start'),
                onPressed: () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                    builder: (_) =>
                        QuestionScreen(source: _learn!, target: _native!),
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }
}
