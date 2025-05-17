import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/ui/widgets/germany_map_with_markers.dart';

/// Zeigt die Deutschlandkarte mit Markern an und verfügt über einen
/// „Weiter“-Button, der dieselbe Aktion wie im Level-Up-Screen ausführt.
class MapScreenWithContinue extends StatelessWidget {
  /// Callback, der das nächste Level öffnet.
  final VoidCallback onContinue;

  const MapScreenWithContinue({
    Key? key,
    required this.onContinue,
  }) : super(key: key);

  // ---- Marker-Koordinaten -----------------------------------------------
  // Von dir angeliefert: ganzzahlige Werte → / 10000  ⇒ Dezimalgrad
  static const _markerPoints = <LatLon>[
    LatLon(50.1096, 8.6724),   // Frankfurt a. M.
    LatLon(48.7650, 11.4257),  // Nähe Regensburg
    LatLon(54.3126, 13.0929),  // Nähe Stralsund/Rügen
  ];
  // ------------------------------------------------------------------------

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
              child: GermanyMapWithMarkers(points: _markerPoints),
            ),
          ),

          // „Weiter“-Button
          SafeArea(
            top: false,
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    // zuerst nächste Station öffnen …
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
