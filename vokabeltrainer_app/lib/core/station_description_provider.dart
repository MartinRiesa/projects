import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class StationDescriptionProvider {
  static Map<int, String>? _data;

  static Future<void> _load() async {
    if (_data != null) return;
    final csv = await rootBundle
        .loadString('assets/Stationenbeschreibung-englisch.csv');
    final rows = const CsvToListConverter(fieldDelimiter: ';').convert(csv);
    final header = rows.first.cast<String>();
    final idxNr = header.indexOf('Nr');
    final idxErkl = header.indexOf('Erklärung');
    _data = {
      for (var r in rows.skip(1))
        int.tryParse(r[idxNr].toString()) ?? -1: r[idxErkl].toString()
    };
  }

  static Future<String> getExplanation(int level) async {
    await _load();
    return _data?[level] ?? '';
  }
}
