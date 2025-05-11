import 'package:flutter/material.dart';

/// Zeigt die Deutschlandkarte im Vollbild an.
/// Per [InteractiveViewer] kann der Nutzer zoomen und verschieben.
class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Karte'),
      ),
      body: InteractiveViewer(
        maxScale: 5.0,
        child: Center(
          child: Image.asset(
            'assets/images/germany_map.png',
            fit: BoxFit.contain,
          ),
        ),
      ),
    );
  }
}
