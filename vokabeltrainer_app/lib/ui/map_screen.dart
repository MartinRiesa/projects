import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';

import '../core/station_loader.dart';
import '../core/station.dart';
import '../core/level_manager.dart';

class MapScreen extends StatefulWidget {
  const MapScreen({Key? key}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late Future<List<Station>> _stationsFut;

  // Geografische Ausdehnung des PNGs (grob Deutschland)
  final _pngBounds = LatLngBounds(
    LatLng(55.1, 5.5),   // Nord-West
    LatLng(47.0, 15.5),  // Süd-Ost
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

          return Stack(
            children: [
              FlutterMap(
                options: MapOptions(
                  center: const LatLng(51.0, 9.0),
                  zoom: 6,
                  maxZoom: 8,
                  minZoom: 5,
                ),
                children: [
                  // Dein PNG als Kartenhintergrund
                  OverlayImageLayer(
                    overlayImages: [
                      OverlayImage(
                        bounds: _pngBounds,
                        opacity: 1,
                        imageProvider:
                        const AssetImage('assets/images/static_map.png'),
                      ),
                    ],
                  ),

                  if (path.length >= 2)
                    PolylineLayer(
                      polylines: [
                        Polyline(
                          points: path,
                          strokeWidth: 4,
                          color: Colors.blueAccent,
                        ),
                      ],
                    ),

                  MarkerLayer(
                    markers: stations
                        .map((s) => _buildMarker(s, completed, next))
                        .whereType<Marker>()
                        .toList(),
                  ),
                ],
              ),

              if (snap.connectionState == ConnectionState.waiting)
                const Center(child: CircularProgressIndicator()),
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
    if (s.level == completed) size = 60;
    if (s.level == next) {
      size = 50;
      color = Colors.red;
    }

    return Marker(
      point: LatLng(s.latitude, s.longitude),
      width: size,
      height: size,
      child: GestureDetector(
        onTap: () => _showPopup(context, s),
        child: Icon(Icons.location_on, color: color, size: size),
      ),
    );
  }

  void _showPopup(BuildContext context, Station s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Level ${s.level}: ${s.name}'),
        content: Text(
            s.description.isEmpty ? 'Keine Beschreibung vorhanden.' : s.description),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Schließen'),
          ),
        ],
      ),
    );
  }
}
