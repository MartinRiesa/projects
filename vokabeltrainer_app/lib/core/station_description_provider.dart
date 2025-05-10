// lib/core/station_description_provider.dart
//
// Liest "assets/Stationenbeschreibung-englisch.csv" genau einmal ein und
// stellt den Erklärungstext (Spalte „Erklärung“) nach Levelnummer bereit.

import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';

class StationDescriptionProvider {
  static Map<int, String>? _cache;

  /// Interne Ladefunktion → füllt [_cache] beim ersten Aufruf.
  static Future<void> _load() async {
    if (_cache != null) return;           // bereits vorhanden

    final raw =
    await rootBundle.loadString('assets/Stationenbeschreibung-englisch.csv');

    // CSV parsen (Semikolon als Trennzeichen)
    final rows = const CsvToListConverter(
      fieldDelimiter: ';',
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(raw);

    if (rows.isEmpty) {
      _cache = {};
      return;
    }

    final header = rows.first.cast<String>();
    final idxNr = header.indexOf('Nr');
    final idxErkl = header.indexOf('Erklärung');

    final map = <int, String>{};
    for (final r in rows.skip(1)) {
      if (r.length <= idxErkl) continue;
      final nr = int.tryParse(r[idxNr].toString().trim());
      if (nr == null) continue;

      var text = r[idxErkl].toString();
      // Entfernt evtl. Anführungszeichen um den Text
      if (text.startsWith('"') && text.endsWith('"')) {
        text = text.substring(1, text.length - 1);
      }
      map[nr] = text.trim();
    }
    _cache = map;
  }

  /// Öffentliche Methode: Erklärung für [level] oder leerer String.
  static Future<String> getExplanation(int level) async {
    await _load();
    return _cache?[level] ?? '';
  }
}
