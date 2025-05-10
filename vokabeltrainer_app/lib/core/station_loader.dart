// lib/core/station_loader.dart
//
// Lädt die Stationsdaten (Levelname, Beschreibung, Koordinaten, Bild)
// genau einmal aus „assets/Stationenbeschreibung-englisch.csv“.

import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'station.dart';

class StationLoader {
  static List<Station>? _cache;

  static Future<List<Station>> load() async {
    if (_cache != null) return _cache!;

    // CSV als String laden
    final raw = await rootBundle
        .loadString('assets/Stationenbeschreibung-englisch.csv');

    // Semikolon-getrennt, keine Zahl-Parsing
    final rows = const CsvToListConverter(
      fieldDelimiter: ';',
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(raw);

    if (rows.isEmpty) return _cache = [];

    // Spaltenindizes
    final header = rows.first.cast<String>();
    final idxNr = header.indexOf('Nr');
    final idxStation = header.indexOf('Station');
    final idxLat = header.indexOf('Latitude');
    final idxLon = header.indexOf('Longitude');
    final idxBild = header.indexOf('Bild');
    final idxErkl = header.indexOf('Erklärung');

    final list = <Station>[];

    for (final row in rows.skip(1)) {
      if (row.length <= idxErkl) continue; // defekte Zeile überspringen
      final nr = int.tryParse(row[idxNr].toString()) ?? 0;

      list.add(Station(
        level: nr,
        name: row[idxStation].toString().trim(),
        latitude:
        double.parse(row[idxLat].toString().replaceAll(',', '.')),
        longitude:
        double.parse(row[idxLon].toString().replaceAll(',', '.')),
        imageAsset: row[idxBild].toString().trim(),
        description: row[idxErkl].toString().trim(),
      ));
    }

    _cache = list;
    return list;
  }
}
