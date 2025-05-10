import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import '../core/station.dart';
import '../core/station_loader.dart';

class MapScreen extends StatefulWidget {
  final int completedCount;   // erledigte Level vom Aufrufer

  const MapScreen({Key? key, required this.completedCount}) : super(key: key);

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  late Future<List<Station>> _stations = StationLoader.load();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deutschlandkarte')),
      body: FutureBuilder<List<Station>>(
        future: _stations,
        builder: (_, snap) {
          if (!snap.hasData) {
            return const Center(child: CircularProgressIndicator());
          }
          final st = snap.data!;
          final completed = widget.completedCount;
          final next = completed + 1;

          final path = st
              .where((s) => s.level <= completed)
              .map((s) => LatLng(s.latitude, s.longitude))
              .toList();

          return FlutterMap(
            options: MapOptions(
              center:
              path.isNotEmpty ? path.last : LatLng(51.0, 9.0),
              zoom: 6,
            ),
            children: [
              TileLayer(
                urlTemplate:
                'https://{s}.tile.openstreetmap.org/{z}/{x}/{y}.png',
                subdomains: const ['a', 'b', 'c'],
                userAgentPackageName: 'com.example.vokabeltrainer',
              ),
              if (path.length > 1)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: path,
                      color: Colors.green,
                      strokeWidth: 4,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: st.map((s) {
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
                      onTap: () => _showDetail(context, s),
                      child: Icon(Icons.location_on, color: color, size: size),
                    ),
                  );
                }).whereType<Marker>().toList(),
              ),
            ],
          );
        },
      ),
    );
  }

  void _showDetail(BuildContext ctx, Station s) {
    showDialog(
      context: ctx,
      builder: (_) => AlertDialog(
        title: Text(s.name),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Image.asset(s.imageAsset, fit: BoxFit.cover),
            const SizedBox(height: 8),
            Text(s.description),
          ],
        ),
        actions: [
          TextButton(
            onPressed: Navigator.of(ctx).pop,
            child: const Text('Schließen'),
          )
        ],
      ),
    );
  }
}
