import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:vokabeltrainer_app/core/latlon.dart';

class StationLoader {
  static Future<List<LatLon>> loadStationsFromCSV(String assetPath) async {
    final csvString = await rootBundle.loadString(assetPath);
    final lines = LineSplitter.split(csvString);
    final List<LatLon> stations = [];
    bool isFirst = true;

    for (final line in lines) {
      if (isFirst) { isFirst = false; continue; }
      final columns = line.split(';');
      if (columns.length < 5) continue;
      try {
        // Passe hier die Indizes ggf. an – laut deiner Datei:
        // [Nr, Station, Ort, Latitude, Longitude, ...]
        final latRaw = columns[3].replaceAll(',', '.').trim();
        final lonRaw = columns[4].replaceAll(',', '.').trim();
        final lat = double.parse(latRaw) / 10000.0;
        final lon = double.parse(lonRaw) / 10000.0;
        stations.add(LatLon(lat, lon));
      } catch (_) {}
    }
    print('DEBUG Stationen geladen: ${stations.length}');
    return stations;
  }
}
