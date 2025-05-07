// lib/main.dart

import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/ui/language_selection_screen.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) =>
      const MaterialApp(
        title: 'VokabelTrainer Classic',
        home: LanguageSelectionScreen(),
      );
}
