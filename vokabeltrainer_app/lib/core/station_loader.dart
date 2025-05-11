// lib/core/station_loader.dart
//
// Liest Stationenbeschreibung-englisch.csv (Semikolon-getrennt) aus assets.
// Ergebnis wird gecacht.

import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

import 'station.dart';

class StationLoader {
  static List<Station>? _cache;

  static Future<List<Station>> load() async {
    if (_cache != null) return _cache!;

    final raw =
    await rootBundle.loadString('assets/Stationenbeschreibung-englisch.csv');

    final rows = const CsvToListConverter(
      fieldDelimiter: ';',
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(raw);

    if (rows.isEmpty) return _cache = [];

    final header = rows.first.map((e) => e.toString().toLowerCase()).toList();
    int idxNr = header.indexOf('nr');
    int idxName = header.indexOf('station');
    int idxLat = header.indexOf('latitude');
    int idxLon = header.indexOf('longitude');
    if (idxLon == -1) idxLon = header.indexOf('longtitude'); // Tippfehler
    int idxDesc = header.indexOf('erklärung');
    int idxImg = header.indexOf('bild');

    final list = <Station>[];

    for (final row in rows.skip(1)) {
      if (row.length <= idxLon || idxLat == -1 || idxLon == -1) continue;

      list.add(
        Station(
          level: int.tryParse(row[idxNr].toString()) ?? 0,
          name: row[idxName].toString().trim(),
          latitude: double.parse(row[idxLat].toString().replaceAll(',', '.')),
          longitude: double.parse(row[idxLon].toString().replaceAll(',', '.')),
          description: idxDesc >= 0 ? row[idxDesc].toString().trim() : '',
          imageAsset: idxImg >= 0 ? row[idxImg].toString().trim() : '',
        ),
      );
    }

    _cache = list;
    return list;
  }
}
