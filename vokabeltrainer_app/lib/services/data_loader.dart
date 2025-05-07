// lib/services/data_loader.dart
//
// Lädt Vokabel- und Stationsdaten aus assets/data/*.csv
// Entfernt dabei führende BOM und trimmt unsichtbare Zeichen,
// damit Header-Zeilen wie "Deutsch;Englisch;…" sauber erkannt werden.

import 'dart:convert';
import 'package:flutter/services.dart';

class DataLoader {
  static const _vocabAsset    = 'assets/data/vokabeln_alle.csv';
  static const _stationsAsset = 'assets/data/stationen.csv';

  /// Hilfsfunktion: BOM entfernen und trimmen.
  static String _cleanCsv(String raw) {
    // BOM (\uFEFF) entfernen, dann alle Zeilenenden vereinheitlichen
    return raw.replaceAll('\uFEFF', '').replaceAll('\r\n', '\n');
  }

  /// Liest die Vokabel-CSV und liefert Header + Datenzeilen.
  static Future<Map<String, dynamic>> loadVocabCsv() async {
    final raw   = await rootBundle.loadString(_vocabAsset);
    final clean = _cleanCsv(raw);
    final lines = const LineSplitter().convert(clean);
    if (lines.isEmpty) {
      throw Exception('Vokabel-Datei ist leer oder nicht gefunden!');
    }

    final header = lines.first
        .split(';')
        .map((h) => h.trim())
        .toList();

    final rows = lines.skip(1).map((line) {
      return line
          .split(';')
          .map((c) => c.trim())
          .toList();
    }).toList();

    return {'header': header, 'rows': rows};
  }

  /// Erstellt eine Alias-Mapping-Funktion, wenn nötig.
  /// Falls deine UI tatsächlich "English" anzeigt, mappe auf "Englisch" usw.
  static String _mapUiToCsv(String uiLang) {
    switch (uiLang.toLowerCase()) {
      case 'english':     return 'Englisch';
      case 'deutsch':     return 'Deutsch';
      case 'daari':       return 'Daari';
      case 'ukrainisch':  return 'Ukrainisch';
      case 'arabisch':    return 'arabisch';
      default:            return uiLang.trim();
    }
  }

  /// Findet die Indizes der Spalten für Lern- und Muttersprache.
  static Map<String, int> findLanguageIndices(
      List<String> header, String learnLang, String nativeLang) {
    final csvLearn  = _mapUiToCsv(learnLang);
    final csvNative = _mapUiToCsv(nativeLang);

    final iLearn  = header.indexWhere((h) => h == csvLearn);
    final iNative = header.indexWhere((h) => h == csvNative);

    final missing = <String>[];
    if (iLearn  < 0) missing.add(csvLearn);
    if (iNative < 0) missing.add(csvNative);

    if (missing.isNotEmpty) {
      throw Exception(
          'Sprach-Code nicht im CSV-Header gefunden: ${missing.join(' & ')}\n'
              'Verfügbare Spalten: ${header.join(', ')}'
      );
    }

    return {'learn': iLearn, 'native': iNative};
  }

  /// Lädt die Vokabel-Liste als Map-Liste mit `learn` und `native`.
  static Future<List<Map<String, String>>> loadVocabData(
      String learnLang, String nativeLang) async {
    final csv    = await loadVocabCsv();
    final header = csv['header'] as List<String>;
    final rows   = csv['rows']   as List<List<String>>;
    final idxs   = findLanguageIndices(header, learnLang, nativeLang);

    return rows.map((cells) {
      return {
        'learn' : cells[idxs['learn']!],
        'native': cells[idxs['native']!],
      };
    }).toList();
  }

  /// Lädt Stationsdaten analog.
  static Future<List<Map<String, String>>> loadStationsCsv() async {
    final raw   = await rootBundle.loadString(_stationsAsset);
    final clean = _cleanCsv(raw);
    final lines = const LineSplitter().convert(clean);
    if (lines.length < 2) {
      throw Exception('Stations-Datei ist leer oder fehlt!');
    }

    final keys = lines.first
        .split(';')
        .map((h) => h.trim())
        .toList();

    final values = lines.skip(1).map((line) {
      final cells = line
          .split(';')
          .map((c) => c.trim())
          .toList();
      final map = <String, String>{};
      for (var i = 0; i < keys.length && i < cells.length; i++) {
        map[keys[i]] = cells[i];
      }
      return map;
    }).toList();

    return values;
  }
}
