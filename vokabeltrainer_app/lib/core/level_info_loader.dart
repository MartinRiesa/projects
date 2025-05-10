import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class LevelInfoLoader {
  static Map<int, String>? _names;

  static Future<void> _load() async {
    if (_names != null) return;
    final raw = await rootBundle
        .loadString('assets/Stationenbeschreibung-englisch.csv');
    final rows = const CsvToListConverter(fieldDelimiter: ';').convert(raw);
    final header = rows.first.cast<String>();
    final idxNr = header.indexOf('Nr');
    final idxStation = header.indexOf('Station');
    _names = {
      for (var r in rows.skip(1))
        int.tryParse(r[idxNr].toString()) ?? -1: r[idxStation].toString()
    };
  }

  static Future<String> nameFor(int level) async {
    await _load();
    return _names?[level] ?? '';
  }
}
