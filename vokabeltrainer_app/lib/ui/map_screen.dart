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
        builder: (ctx, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          final stations = snap.data!;
          final completed = LevelManager.instance.currentLevel - 1;
          final next = LevelManager.instance.currentLevel;

          // Pfad bis zum letzten abgeschlossenen Level
          final path = stations
              .where((s) => s.level <= completed)
              .map((s) => LatLng(s.latitude, s.longitude))
              .toList();

          return FlutterMap(
            options: MapOptions(
              center:
              path.isNotEmpty ? path.last : const LatLng(51.0, 9.0),
              zoom: 6,
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
              ),
              if (path.length >= 2)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: path,
                      strokeWidth: 4,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: stations
                    .map((s) {
                  if (s.level > next) return null;

                  double size = 50;
                  Color color = Colors.green;
                  if (s.level == completed) size = 70;
                  if (s.level == next) color = Colors.red;

                  return Marker(
                    point: LatLng(s.latitude, s.longitude),
                    width: size,
                    height: size,
                    child: GestureDetector(
                      onTap: () => _showPopup(context, s),
                      child: Icon(Icons.location_on,
                          color: color, size: size),
                    ),
                  );
                })
                    .whereType<Marker>()
                    .toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showPopup(BuildContext context, Station s) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(s.name),
        content: Text(s.description),
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
