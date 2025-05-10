// lib/core/level_info_loader.dart
//
// Liest „assets/Stationenbeschreibung-englisch.csv“ genau einmal ein
// und liefert den Level-Namen (Spalte „Station“) anhand der Nummer.

import 'dart:async';
import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;

class LevelInfoLoader {
  static Map<int, String>? _names; // Level-Nr → Stationsname

  /// Interne Ladefunktion (füllt den Cache beim ersten Aufruf).
  static Future<void> _load() async {
    if (_names != null) return;

    final raw =
    await rootBundle.loadString('assets/Stationenbeschreibung-englisch.csv');

    // Datei zeilenweise splitten (schneller als csv-Converter für nur eine Spalte)
    final lines = const LineSplitter().convert(raw);
    if (lines.isEmpty) {
      _names = {};
      return;
    }

    final header = lines.first.split(';');
    final idxNr = header.indexOf('Nr');
    final idxStation = header.indexOf('Station');
    if (idxNr == -1 || idxStation == -1) {
      _names = {};
      return;
    }

    final map = <int, String>{};
    for (final line in lines.skip(1)) {
      if (line.trim().isEmpty) continue; // leere Zeile ignorieren
      final fields = line.split(';');
      if (fields.length <= idxStation) continue;

      final nr = int.tryParse(fields[idxNr].trim());
      if (nr == null) continue;

      map[nr] = fields[idxStation].trim();
    }
    _names = map;
  }

  /// Liefert den Stationsnamen für [level] (oder leeren String, falls nicht gefunden).
  static Future<String> nameFor(int level) async {
    await _load();
    return _names?[level] ?? '';
  }
}
