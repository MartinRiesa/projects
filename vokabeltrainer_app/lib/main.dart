import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/ui/language_selection_screen.dart';
import 'package:vokabeltrainer_app/ui/quiz_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vokabeltrainer',
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const LanguageSelectionScreen(),
        '/learn': (context) => const QuizScreen(level: 1, streak: 0, blur: false), // <-- ALLE Pflichtparameter!
      },
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
    );
  }
}
