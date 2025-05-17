import 'dart:convert';
import 'package:flutter/services.dart';

class StationDescriptionMultilangProvider {
  static Map<int, Map<String, String>>? _descCache;

  // Lädt die gesamte CSV, cacht sie als Map<level, Map<lang, beschreibung>>
  static Future<void> _loadDescriptions() async {
    if (_descCache != null) return;
    final csvString = await rootBundle.loadString('assets/Stationenbeschreibung-englisch.csv');
    final lines = LineSplitter.split(csvString).toList();

    final header = lines.first.split(';').map((s) => s.trim()).toList();
    _descCache = {};

    for (var i = 1; i < lines.length; i++) {
      final columns = lines[i].split(';');
      if (columns.length < header.length) continue;
      int? nr = int.tryParse(columns[0]);
      if (nr == null) continue;
      Map<String, String> langDescs = {};
      for (var j = 0; j < header.length; j++) {
        if (header[j].startsWith("Beschreibung_")) {
          final lang = header[j].split('_').last;
          langDescs[lang] = columns[j].trim();
        }
      }
      _descCache![nr] = langDescs;
    }
  }

  // Hauptfunktion: holt die Beschreibung in Wunsch-Sprache, sonst auf deutsch
  static Future<String> getDescription(int level, String languageCode) async {
    await _loadDescriptions();
    if (_descCache == null || !_descCache!.containsKey(level)) {
      return '';
    }
    final descs = _descCache![level]!;
    // Fallback: falls z.B. "en" leer ist
    return (descs[languageCode]?.isNotEmpty ?? false)
        ? descs[languageCode]!
        : (descs['de'] ?? '');
  }
}
