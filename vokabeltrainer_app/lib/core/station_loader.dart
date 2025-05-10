import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'station.dart';

class StationLoader {
  static List<Station>? _cache;

  /// Lädt die Stations-CSV einmalig und hält sie im Cache.
  static Future<List<Station>> load() async {
    if (_cache != null) return _cache!;
    final raw = await rootBundle
        .loadString('assets/Stationenbeschreibung-englisch.csv');

    final rows = const CsvToListConverter(
            fieldDelimiter: ';', eol: '\n', shouldParseNumbers: false)
        .convert(raw);

    if (rows.isEmpty) return [];

    final header = rows.first.cast<String>();
    final idxNr = header.indexOf('Nr');
    final idxStation = header.indexOf('Station');
    final idxLat = header.indexOf('Latitude');
    final idxLon = header.indexOf('Longitude');
    final idxBild = header.indexOf('Bild');
    final idxErkl = header.indexOf('Erklärung');

    final list = <Station>[];
    for (final row in rows.skip(1)) {
      if (row.length <= idxLon) continue;
      final nr = int.tryParse(row[idxNr].trim());
      if (nr == null) continue;
      list.add(Station(
        level: nr,
        name: row[idxStation].trim(),
        latitude: double.parse(row[idxLat].toString().replaceAll(',', '.')),
        longitude: double.parse(row[idxLon].toString().replaceAll(',', '.')),
        imageAsset: row[idxBild].trim(),       // z.B. assets/images/1.jpg
        description: row[idxErkl].trim(),
      ));
    }
    _cache = list;
    return list;
  }
}
