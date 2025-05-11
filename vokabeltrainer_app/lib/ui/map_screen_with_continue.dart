import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/ui/widgets/map_with_markers.dart';

class MapScreenWithContinue extends StatelessWidget {
  /// Callback, der das nächste Level öffnet.
  final VoidCallback onContinue;

  const MapScreenWithContinue({
    Key? key,
    required this.onContinue,
  }) : super(key: key);

  // Feste Markerkoordinaten aus der Aufgabenstellung
  static const _points = [
    LatLon(50.1096, 8.6724),
    LatLon(48.7650, 11.4257),
    LatLon(54.3126, 13.0929),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Karte'),
      ),
      body: Column(
        children: [
          // Zoombare Karte mit Markern
          Expanded(
            child: InteractiveViewer(
              maxScale: 5.0,
              child: MapWithMarkers(markers: _points),
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
                    onContinue();          // nächstes Level
                    Navigator.of(context).pop(); // Karte schließen
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
