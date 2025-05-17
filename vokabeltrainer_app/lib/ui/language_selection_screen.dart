import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/core/app_language.dart';

class LanguageSelectionScreen extends StatelessWidget {
  const LanguageSelectionScreen({Key? key}) : super(key: key);

  void _selectLanguage(BuildContext context, String languageCode) {
    AppLanguage.setLanguage(languageCode);
    Navigator.pushReplacementNamed(context, '/learn');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select your language / Sprache wählen'),
      ),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                child: Text(
                  'Bitte wähle deine Sprache\nPlease select your language',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () => _selectLanguage(context, 'de'),
                child: const Text('Deutsch'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _selectLanguage(context, 'en'),
                child: const Text('English'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _selectLanguage(context, 'fa'),
                child: const Text('Farsi / فارسی'),
              ),
              const SizedBox(height: 10),
              ElevatedButton(
                onPressed: () => _selectLanguage(context, 'uk'),
                child: const Text('Ukrainisch / Українська'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
