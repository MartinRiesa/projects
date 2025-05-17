import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/core/latlon.dart';
import '../core/station_loader.dart';
import 'widgets/germany_map_with_progress.dart';
import 'package:vokabeltrainer_app/core/station_description_provider.dart';

class MapScreenProgress extends StatefulWidget {
  final int completedLevels;
  final int nextLevel;
  final ImageProvider? levelImage; // Das Level-Bild

  const MapScreenProgress({
    Key? key,
    required this.completedLevels,
    required this.nextLevel,
    this.levelImage,
  }) : super(key: key);

  @override
  State<MapScreenProgress> createState() => _MapScreenProgressState();
}

class _MapScreenProgressState extends State<MapScreenProgress> {
  late Future<List<LatLon>> _stationsFuture;
  late Future<String?> _stationDescriptionFuture;

  @override
  void initState() {
    super.initState();
    _stationsFuture = StationLoader.loadStationsFromCSV(
      'assets/Stationenbeschreibung-englisch.csv',
    );
    // Stationen und Level sind meist 1-basiert: Beschreibung für completedLevels
    _stationDescriptionFuture = StationDescriptionProvider.getExplanation(widget.completedLevels);
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

          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                if (widget.levelImage != null)
                  Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image(
                        image: widget.levelImage!,
                        fit: BoxFit.contain,
                        width: MediaQuery.of(context).size.width * 0.92,
                        height: 220,
                      ),
                    ),
                  ),
                const SizedBox(height: 16),
                // Beschreibung der Station UNTER dem Bild
                FutureBuilder<String?>(
                  future: _stationDescriptionFuture,
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    } else if (snapshot.hasError) {
                      return const Text(
                        'Fehler beim Laden der Erklärung',
                        style: TextStyle(fontSize: 16.0, color: Colors.red),
                        textAlign: TextAlign.center,
                      );
                    } else {
                      final explanation = snapshot.data ?? '';
                      return Padding(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 18.0, vertical: 4.0),
                        child: Text(
                          explanation,
                          style: const TextStyle(
                            fontSize: 18.0,
                            color: Colors.black87,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      );
                    }
                  },
                ),
                const SizedBox(height: 14),
                // Die große Karte: NICHT verkleinert
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 0, vertical: 6),
                  child: GermanyMapWithProgress(
                    stations: stations,
                    completedLevels: widget.completedLevels,
                    nextLevel: widget.nextLevel,
                    assetPath: 'assets/images/germany_map.png',
                    mapScale: 1.15,
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          );
        },
      ),
    );
  }
}
