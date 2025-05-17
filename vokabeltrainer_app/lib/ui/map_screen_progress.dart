import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/core/latlon.dart';
import '../core/station_loader.dart';
import 'widgets/germany_map_with_progress.dart';

class MapScreenProgress extends StatefulWidget {
  final int completedLevels;
  final int nextLevel;
  final ImageProvider? levelImage; // NEU: Das Bild

  const MapScreenProgress({
    Key? key,
    required this.completedLevels,
    required this.nextLevel,
    this.levelImage, // optional
  }) : super(key: key);

  @override
  State<MapScreenProgress> createState() => _MapScreenProgressState();
}

class _MapScreenProgressState extends State<MapScreenProgress> {
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
      appBar: AppBar(title: const Text('Deutschlandkarte – Fortschritt')),
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

          return Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              if (widget.levelImage != null)
                Padding(
                  padding: const EdgeInsets.only(top: 16.0, bottom: 8),
                  child: Container(
                    height: 120, // Größe nach Wunsch anpassen!
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(14),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black26,
                          blurRadius: 8,
                          spreadRadius: 2,
                        ),
                      ],
                    ),
                    clipBehavior: Clip.hardEdge,
                    child: AspectRatio(
                      aspectRatio: 16 / 9,
                      child: Image(
                        image: widget.levelImage!,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                ),
              Expanded(
                child: GermanyMapWithProgress(
                  stations: stations,
                  completedLevels: widget.completedLevels,
                  nextLevel: widget.nextLevel,
                  assetPath: 'assets/images/germany_map.png',
                  mapScale: 1.15, // Maximale Karte
                ),
              ),
            ],
          );
        },
      ),
    );
  }
}
