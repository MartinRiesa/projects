import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/core/latlon.dart';
import '../core/station_loader.dart';
import 'widgets/static_germany_map_with_marker.dart';

class MapScreenStaticMarker extends StatefulWidget {
  final int stationIndex;

  const MapScreenStaticMarker({Key? key, required this.stationIndex})
      : super(key: key);

  @override
  State<MapScreenStaticMarker> createState() => _MapScreenStaticMarkerState();
}

class _MapScreenStaticMarkerState extends State<MapScreenStaticMarker> {
  late Future<List<LatLon>> _stationsFuture;

  @override
  void initState() {
    super.initState();
    _stationsFuture = StationLoader.loadStationsFromCSV(
      'assets/Stationenbeschreibung-englisch.csv',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Deutschlandkarte')),
      body: FutureBuilder<List<LatLon>>(
        future: _stationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Fehler beim Laden der Stationen.'));
          }
          final stations = snapshot.data!;
          print('DEBUG: stationIndex=${widget.stationIndex}, stations.length=${stations.length}');
          if (widget.stationIndex < 0 || widget.stationIndex >= stations.length) {
            return Center(
              child: Text(
                'Ungültige Station!\n'
                    'Level: ${widget.stationIndex + 1}\n'
                    'Vorhandene Stationen: ${stations.length}\n'
                    'Bitte prüfe deine Stationen-CSV und die Level-Zuordnung.',
                style: const TextStyle(color: Colors.red, fontSize: 18),
                textAlign: TextAlign.center,
              ),
            );
          }
          final point = stations[widget.stationIndex];
          return StaticGermanyMapWithMarker(
            point: point,
            assetPath: 'assets/images/germany_map.png',
          );
        },
      ),
    );
  }
}
