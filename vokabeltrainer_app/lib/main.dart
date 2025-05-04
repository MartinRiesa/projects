import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'core/settings.dart';
import 'ui/language_selection_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final settings = Settings();
  await settings.load();

  runApp(
    ChangeNotifierProvider<Settings>.value(
      value: settings,
      child: const VokabelTrainerApp(),
    ),
  );
}

class VokabelTrainerApp extends StatelessWidget {
  const VokabelTrainerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vokabeltrainer',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorSchemeSeed: Colors.indigo,
        useMaterial3: true,
      ),
      home: const LanguageSelectionScreen(),
    );
  }
}
