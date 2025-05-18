// lib/core/vocab_loader.dart
import 'package:flutter/services.dart' show rootBundle;
import 'vocab_pair.dart';

/// Lädt die CSV assets/Vokabeln alle.csv und liefert
/// für die ISO-Codes src→tgt eine Liste von VocabPair.
class VocabLoader {
  /// Mappt ISO-Sprachcode → Spaltenname in der CSV.
  static const Map<String, String> _codeToHeader = {
    'de': 'Deutsch',
    'en': 'Englisch',
    'fa': 'Daari',
    'uk': 'Ukrainisch',
    'ar': 'arabisch',
  };

  static Future<List<VocabPair>> load(String src, String tgt) async {
    // 1) Datei einlesen
    final raw = await rootBundle.loadString('assets/Vokabeln alle.csv');
    final lines = raw
        .split(RegExp(r'\r?\n'))
        .where((l) => l.trim().isNotEmpty)
        .toList();

    if (lines.isEmpty) {
      throw Exception('CSV ist leer');
    }

    // 2) Header parsen und BOM entfernen
    final headerLine = lines.first.replaceFirst('\ufeff', '');
    final headers = headerLine.split(';').map((h) => h.trim()).toList();

    // 3) Index für src/tgt ermitteln
    final srcHeader = _codeToHeader[src];
    final tgtHeader = _codeToHeader[tgt];
    final srcIdx = srcHeader != null ? headers.indexOf(srcHeader) : -1;
    final tgtIdx = tgtHeader != null ? headers.indexOf(tgtHeader) : -1;

    if (srcIdx < 0 || tgtIdx < 0) {
      throw Exception(
        'Sprach-Code nicht in CSV-Header gefunden: '
            '$src → $srcIdx, $tgt → $tgtIdx',
      );
    }

    // 4) Zeilen 2…n als Vokabeln parsen
    final List<VocabPair> pairs = [];
    for (var i = 1; i < lines.length; i++) {
      final cols = lines[i].split(';');
      if (cols.length <= srcIdx || cols.length <= tgtIdx) continue;

      final prompt = cols[srcIdx].trim();
      final answer = cols[tgtIdx].trim();
      if (prompt.isEmpty || answer.isEmpty) continue;

      pairs.add(VocabPair(prompt: prompt, answer: answer));
    }

    if (pairs.isEmpty) {
      throw Exception('Keine Vokabeln für $src→$tgt in CSV gefunden');
    }

    return pairs;
  }
}
