import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/core/latlon.dart';
import '../core/station_loader.dart';
import 'widgets/germany_map_with_markers_auto.dart';

class MapScreenAutoMarkersCSV extends StatefulWidget {
  const MapScreenAutoMarkersCSV({Key? key}) : super(key: key);

  @override
  State<MapScreenAutoMarkersCSV> createState() => _MapScreenAutoMarkersCSVState();
}

class _MapScreenAutoMarkersCSVState extends State<MapScreenAutoMarkersCSV> {
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
      appBar: AppBar(title: const Text('Deutschlandkarte mit CSV-Markern')),
      body: FutureBuilder<List<LatLon>>(
        future: _stationsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text('Fehler beim Laden der Stationen.'));
          }
          final points = snapshot.data!;
          return Center(
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: SingleChildScrollView(
                scrollDirection: Axis.vertical,
                child: GermanyMapWithMarkersAuto(
                  points: points,
                  assetPath: 'assets/images/germany_map.png',
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
