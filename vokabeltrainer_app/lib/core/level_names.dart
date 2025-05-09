import 'package:flutter/services.dart' show rootBundle;

class LevelNames {
  static List<String>? _names;

  /// Lädt die CSV (nur einmal) und füllt [_names].
  static Future<void> _ensureLoaded() async {
    if (_names != null) return;

    final raw = await rootBundle
        .loadString('assets/Stationenbeschreibung-englisch.csv');

    // passendes Trennzeichen ermitteln
    final delimiter = raw.contains(';') ? ';' : ',';
    final rows = raw.split('\n').where((r) => r.trim().isNotEmpty).toList();

    // Header auswerten → Index der Spalte "Station"
    final header = rows.first.split(delimiter).map((s) => s.trim()).toList();
    final idx = header.indexWhere(
        (h) => h.toLowerCase() == 'station' || h.toLowerCase() == 'stationen');
    if (idx == -1) {
      throw StateError('Spalte "Station" nicht gefunden');
    }

    _names = rows
        .skip(1) // Header überspringen
        .map((r) => r.split(delimiter)[idx].trim())
        .where((s) => s.isNotEmpty)
        .toList();
  }

  /// Liefert den Namen für [level] (1-basiert) oder "Level X", falls nicht vorhanden.
  static Future<String> nameFor(int level) async {
    await _ensureLoaded();
    if (level < 1 || level > _names!.length) return 'Level $level';
    return _names![level - 1];
  }
}
