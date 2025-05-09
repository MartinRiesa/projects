import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:vokabeltrainer_app/controller/quiz_controller.dart';
import 'package:vokabeltrainer_app/core/level_manager.dart';

class QuestionScreen extends StatelessWidget {
  const QuestionScreen({super.key, required this.levelManager});

  final LevelManager levelManager;

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => QuizController(levelManager)..load(),
      child: const _QuestionScreenBody(),
    );
  }
}

class _QuestionScreenBody extends StatelessWidget {
  const _QuestionScreenBody();

  @override
  Widget build(BuildContext context) {
    final ctrl = context.watch<QuizController>();

    if (ctrl.isLoading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Frage'),
        actions: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Center(
              child: Text(ctrl.elapsedFormatted, style: const TextStyle(fontSize: 18)),
            ),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Text(
              'Frage ${ctrl.currentIndex + 1} von ${ctrl.totalQuestions}',
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(height: 20),
            Text(
              ctrl.currentPair.prompt,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _AnswerInput(),
            const SizedBox(height: 20),
            if (ctrl.isAnswerRevealed)
              Text(
                ctrl.isCorrect
                    ? 'Richtig!'
                    : 'Falsch. Richtige Antwort: ${ctrl.currentPair.answer}',
                style: TextStyle(
                  fontSize: 20,
                  color: ctrl.isCorrect ? Colors.green : Colors.red,
                ),
              ),
            const Spacer(),
            ElevatedButton(
              onPressed: ctrl.isAnswerRevealed
                  ? () {
                final finished = ctrl.nextQuestion();
                if (finished) Navigator.pop(context);
              }
                  : null,
              child: const Text('Nächste Frage'),
            ),
          ],
        ),
      ),
    );
  }
}

class _AnswerInput extends StatefulWidget {
  @override
  State<_AnswerInput> createState() => _AnswerInputState();
}

class _AnswerInputState extends State<_AnswerInput> {
  final _textCtrl = TextEditingController();

  @override
  void dispose() {
    _textCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final quiz = context.watch<QuizController>();

    return Column(
      children: [
        TextField(
          controller: _textCtrl,
          decoration: const InputDecoration(labelText: 'Übersetzung eingeben'),
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          onPressed: quiz.isAnswerRevealed ? null : () => quiz.checkAnswer(_textCtrl.text),
          child: const Text('Antwort prüfen'),
        ),
      ],
    );
  }
}
