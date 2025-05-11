import 'package:flutter/material.dart';

/// Zeigt die Deutschlandkarte an und bietet unten einen „Weiter“-Button,
/// der dieselbe Aktion wie der „Weiter“-Button im Level-Up-Screen auslöst.
class MapScreenWithContinue extends StatelessWidget {
  /// Callback, der das nächste Level öffnet.
  final VoidCallback onContinue;

  const MapScreenWithContinue({
    Key? key,
    required this.onContinue,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Karte'),
      ),
      body: Column(
        children: [
          // Zoombare Karte
          Expanded(
            child: InteractiveViewer(
              maxScale: 5.0,
              child: Center(
                child: Image.asset(
                  'assets/images/germany_map.png',
                  fit: BoxFit.contain,
                ),
              ),
            ),
          ),

          // Weiter-Button am unteren Rand
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // Erst nächste Station öffnen …
                    onContinue();
                    // … und anschließend diese Karte schließen
                    Navigator.of(context).pop();
                  },
                  child: const Text('Weiter'),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
