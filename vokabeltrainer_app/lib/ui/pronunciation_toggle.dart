import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/settings.dart';

class PronunciationToggle extends StatelessWidget {
  const PronunciationToggle({super.key});

  @override
  Widget build(BuildContext context) => IconButton(
        icon: const Icon(Icons.volume_up),
        tooltip: 'Aussprache-Optionen',
        onPressed: () => showDialog(
          context: context,
          builder: (_) => AlertDialog(
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            content: Consumer<Settings>(
              builder: (_, s, __) => SwitchListTile.adaptive(
                title: const Text('Aussprache abspielen'),
                value: s.speakEnabled,
                onChanged: (_) => s.toggleSpeak(),
              ),
            ),
          ),
        ),
      );
}
