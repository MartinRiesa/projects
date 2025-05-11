import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/station_loader.dart';
import '../core/station.dart';
import '../core/level_manager.dart';
import 'question_screen.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late Future<List<Station>> _stationsFut;

  // Grenzen des statischen Deutschland-PNGs
  final _pngBounds = LatLngBounds(
    LatLng(55.1, 5.5),  // Nord-West
    LatLng(47.0, 15.5), // Süd-Ost
  );

  @override
  void initState() {
    super.initState();
    _stationsFut = StationLoader.load();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deutschlandkarte')),
      body: FutureBuilder<List<Station>>(
        future: _stationsFut,
        builder: (_, snap) {
          final stations = snap.data ?? <Station>[];

          final completed = LevelManager.instance.currentLevel - 1;
          final next = LevelManager.instance.currentLevel;

          final path = stations
              .where((s) => s.level <= completed)
              .map((s) => LatLng(s.latitude, s.longitude))
              .toList();

          return Column(
            children: [
              // Kartenbereich
              Expanded(
                child: FlutterMap(
                  options: MapOptions(
                    center: path.isNotEmpty
                        ? path.last
                        : const LatLng(51.0, 9.0),
                    zoom: 6,
                    maxZoom: 8,
                    minZoom: 5,
                  ),
                  children: [
                    // Statisches Bild
                    OverlayImageLayer(
                      overlayImages: [
                        OverlayImage(
                          bounds: _pngBounds,
                          imageProvider:
                          const AssetImage('assets/images/static_map.png'),
                        ),
                      ],
                    ),
                    // Verbindungslinie
                    if (path.length >= 2)
                      PolylineLayer(
                        polylines: [
                          Polyline(
                            points: path,
                            color: Colors.green,
                            strokeWidth: 4,
                          ),
                        ],
                      ),
                    // Marker
                    MarkerLayer(
                      markers: stations
                          .map((s) => _buildMarker(s, completed, next))
                          .whereType<Marker>()
                          .toList(),
                    ),
                  ],
                ),
              ),
              // Nächstes-Level-Button
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: ElevatedButton.icon(
                  icon: const Icon(Icons.arrow_forward),
                  label: const Text('Nächstes Level'),
                  onPressed: () {
                    Navigator.of(context).push(
                      MaterialPageRoute(
                        builder: (_) => const QuestionScreen(
                          source: 'de',
                          target: 'en',
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  Marker? _buildMarker(Station s, int completed, int next) {
    if (s.level > next) return null;

    double size = 40;
    Color color = Colors.green;
    if (s.level == completed) size = 60;     // zuletzt erledigt
    if (s.level == next) {
      size = 50;
      color = Colors.red;                    // nächstes Level
    }

    return Marker(
      point: LatLng(s.latitude, s.longitude),
      width: size,
      height: size,
      child: Icon(Icons.location_on, color: color, size: size),
    );
  }
}
