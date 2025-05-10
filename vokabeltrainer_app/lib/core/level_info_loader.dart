import 'package:csv/csv.dart';
import 'package:flutter/services.dart' show rootBundle;

/// Lädt Level-Titel („Station“) und Beschreibungstexte aus der CSV.
/// Datei-Pfad: assets/Stationenbeschreibung-englisch.csv
class LevelInfoLoader {
  static final Map<int, Map<String, String>> _cache = {};

  /// Liefert den Stations-/Level-Namen.
  static Future<String> nameFor(int level) async {
    await _ensureLoaded();
    return _cache[level]?['Station'] ?? 'Level $level';
  }

  /// Liefert den Beschreibungstext für [langCode] ('de', 'en', ...).
  /// Erwartet, dass die CSV-Spalten „Deutsch“, „Englisch“, „Arabisch“ usw. heißen.
  static Future<String> descriptionFor(int level, String langCode) async {
    await _ensureLoaded();
    final col = _columnForLang(langCode);
    return _cache[level]?[col] ?? '';
  }

  // ---------------------------------------------------------------

  static Future<void> _ensureLoaded() async {
    if (_cache.isNotEmpty) return;

    final raw = await rootBundle
        .loadString('assets/Stationenbeschreibung-englisch.csv');
    final rows = const CsvToListConverter(
      fieldDelimiter: ';',
      eol: '\n',
    ).convert(raw);

    if (rows.isEmpty) return;

    final header = rows.first.cast<String>();
    final idxNr = header.indexOf('Nr');
    final idxStation = header.indexOf('Station');

    for (var row in rows.skip(1)) {
      final list = row.cast<String>();
      final nr = int.tryParse(list[idxNr] ?? '');
      if (nr == null) continue;

      final data = <String, String>{
        'Station': list[idxStation],
      };

      for (var i = 0; i < header.length; i++) {
        final colName = header[i];
        if (colName == 'Nr' || colName == 'Station') continue;
        data[colName] = list[i];
      }
      _cache[nr] = data;
    }
  }

  static String _columnForLang(String lang) {
    switch (lang) {
      case 'de':
        return 'Deutsch';
      case 'en':
        return 'Englisch';
      case 'ar':
        return 'Arabisch';
      case 'fa':
        return 'Persisch';
      case 'uk':
        return 'Ukrainisch';
      default:
        return 'Englisch';
    }
  }
}
