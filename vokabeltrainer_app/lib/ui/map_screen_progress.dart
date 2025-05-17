import 'package:flutter/material.dart';
import 'package:vokabeltrainer_app/core/latlon.dart';
import '../core/station_loader.dart';
import 'widgets/germany_map_with_progress_interactive.dart';
import 'station_info_dialog.dart';
import 'package:vokabeltrainer_app/core/station_description_provider.dart';

class MapScreenProgress extends StatefulWidget {
  final int completedLevels;
  final int nextLevel;
  final ImageProvider? levelImage;

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

  @override
  void initState() {
    super.initState();
    _stationsFuture = StationLoader.loadStationsFromCSV(
      'assets/Stationenbeschreibung-englisch.csv',
    );
  }

  // Holt das Bild zur Station, passend zum Index (Level/Station 1 = 1.jpg)
  ImageProvider? getImageForStation(int index) {
    if (index < 0) return null;
    final assetPath = 'assets/images/${index + 1}.jpg';
    return AssetImage(assetPath);
  }

  // Holt die Beschreibung wie gehabt
  Future<String?> getDescriptionForStation(int index) {
    return StationDescriptionProvider.getExplanation(index + 1);
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

          // ---- HIER die wichtigste Änderung! ----
          // Default: Das zuletzt geschaffte Level anzeigen (nicht das nächste!)
          final int maxAvailableLevel = (widget.completedLevels > 0)
              ? widget.completedLevels - 1
              : 0;
          int currentIndex = maxAvailableLevel;

          return SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                const SizedBox(height: 18),
                GermanyMapWithProgressInteractive(
                  stations: stations,
                  completedLevels: widget.completedLevels,
                  nextLevel: widget.nextLevel,
                  assetPath: 'assets/images/germany_map.png',
                  mapScale: 1.15,
                  // Punkte können weiterhin angewählt werden,
                  // aber keine Vorschau auf das nächste Level.
                  onStationTap: (int index) async {
                    final img = getImageForStation(index);
                    final desc = await getDescriptionForStation(index);

                    showDialog(
                      context: context,
                      builder: (_) => StationInfoDialog(
                        stationIndex: index,
                        image: img,
                        description: desc,
                      ),
                    );
                  },
                ),
                const SizedBox(height: 20),
                // Unter der Karte: Bild + Beschreibung der aktuellen Station
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 18.0, vertical: 6.0),
                  child: Column(
                    children: [
                      if (currentIndex >= 0)
                        Builder(
                          builder: (context) {
                            final imageProvider = getImageForStation(currentIndex);
                            if (imageProvider == null) {
                              return const Icon(Icons.broken_image, size: 120, color: Colors.grey);
                            }
                            return ClipRRect(
                              borderRadius: BorderRadius.circular(12),
                              child: Image(
                                image: imageProvider,
                                height: 180,
                                fit: BoxFit.cover,
                              ),
                            );
                          },
                        ),
                      const SizedBox(height: 10),
                      FutureBuilder<String?>(
                        future: getDescriptionForStation(currentIndex),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.waiting) {
                            return const CircularProgressIndicator();
                          }
                          if (!snapshot.hasData || snapshot.data == null) {
                            return const Text('Keine Beschreibung verfügbar.');
                          }
                          return Text(
                            snapshot.data!,
                            style: const TextStyle(fontSize: 15),
                            textAlign: TextAlign.center,
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
