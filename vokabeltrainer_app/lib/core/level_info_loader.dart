import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

/// Lädt 'assets/Stationenbeschreibung-englisch.csv' und stellt
/// Levelnamen via [nameFor] bereit.  Die CSV wird nur einmal eingelesen.
class LevelInfoLoader {
  static Map<int, String>? _names; // Nr  → Station

  static Future<void> _load() async {
    if (_names != null) return;

    final raw = await rootBundle
        .loadString('assets/Stationenbeschreibung-englisch.csv');

    final lines = const LineSplitter().convert(raw);
    if (lines.isEmpty) return;

    final header = lines.first.split(';'); // Semikolon-getrennt
    final idxNr = header.indexOf('Nr');
    final idxStation = header.indexOf('Station');
    if (idxNr == -1 || idxStation == -1) return;

    final map = <int, String>{};
    for (final line in lines.skip(1)) {
      if (line.trim().isEmpty) continue;
      final fields = line.split(';');
      if (fields.length <= idxStation) continue;
      final nr = int.tryParse(fields[idxNr].trim());
      if (nr != null) map[nr] = fields[idxStation].trim();
    }
    _names = map;
  }

  /// Liefert den Namen für [level] oder leeren String.
  static Future<String> nameFor(int level) async {
    await _load();
    return _names?[level] ?? '';
  }
}
