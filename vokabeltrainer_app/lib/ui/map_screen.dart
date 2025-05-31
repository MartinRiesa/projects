import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/core/latlon.dart';
import 'package:vokabeltrainer_app/ui/widgets/zoomable_germany_map_with_markers.dart';

class MapScreen extends StatelessWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    // Beispielhafte Stationen: Ersetze dies durch deine echte Logik!
    final List<LatLon> stations = [
      LatLon(52.52, 13.405),  // Berlin
      LatLon(48.137, 11.575), // München
      LatLon(50.9375, 6.9603), // Köln
      LatLon(53.5511, 9.9937), // Hamburg
    ];

    final int completedLevels = 2;
    final int nextLevel = 2;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Interaktive Deutschlandkarte'),
      ),
      body: ZoomableGermanyMapWithMarkers(
        stations: stations,
        completedLevels: completedLevels,
        nextLevel: nextLevel,
        assetPath: 'assets/images/germany_map.png', // oder dein eigenes Kartenbild
        markerDiameter: 32,
        onStationTap: (index) {
          // Beispiel: Zeige Snackbar beim Antippen eines Markers
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Marker $index getippt!')),
          );
        },
      ),
    );
  }
}
