import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/core/latlon.dart';

class MapWithMarkers extends StatelessWidget {
  final String assetPath;
  final List<LatLon> points;
  final double markerDiameter;

  const MapWithMarkers({
    Key? key,
    required this.assetPath,
    required this.points,
    this.markerDiameter = 18,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        // Beispiel: Bildgrößenanpassung und Markerplatzierung
        return Stack(
          children: [
            Image.asset(
              assetPath,
              fit: BoxFit.contain,
              width: constraints.maxWidth,
              height: constraints.maxHeight,
            ),
            // ...hier die Marker-Logik je nach Projektion!
          ],
        );
      },
    );
  }
}
