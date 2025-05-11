import 'package:flutter/material.dart';

/// Einfache Datenklasse für geografische Punkte.
class LatLon {
  final double lat; // Breitengrad
  final double lon; // Längengrad

  const LatLon(this.lat, this.lon);
}

/// Zeigt die Deutschlandkarte mit grünen Markern an.
/// Die Marker werden aus geografischen Koordinaten auf
/// relative Bildpositionen umgerechnet.
class MapWithMarkers extends StatelessWidget {
  /// Liste aller darzustellenden Punkte.
  final List<LatLon> markers;

  const MapWithMarkers({
    Key? key,
    required this.markers,
  }) : super(key: key);

  // Begrenzungsrahmen der Karte (ca. Deutschland-Bounding-Box).
  static const double _latMin = 47.27;
  static const double _latMax = 55.05;
  static const double _lonMin = 5.87;
  static const double _lonMax = 15.04;

  /// Wandelt Längen-/Breitengrad in eine Alignment-Position um.
  Alignment _alignmentFromLatLon(double lat, double lon) {
    final xFrac = (lon - _lonMin) / (_lonMax - _lonMin);
    final yFrac = 1 - (lat - _latMin) / (_latMax - _latMin);
    return Alignment(xFrac * 2 - 1, yFrac * 2 - 1); // -1 … +1
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Kartenbild
        Image.asset(
          'assets/images/germany_map.png',
          fit: BoxFit.contain,
        ),

        // Marker (grüne Punkte)
        for (final p in markers)
          Align(
            alignment: _alignmentFromLatLon(p.lat, p.lon),
            child: Container(
              width: 18,
              height: 18,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
            ),
          ),
      ],
    );
  }
}
