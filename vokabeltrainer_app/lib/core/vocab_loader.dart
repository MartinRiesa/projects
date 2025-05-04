import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'vocab_pair.dart';

/// Lädt alle Vokabeln aus einer einzigen CSV.
/// Kopfzeile = Sprachnamen (z. B. Deutsch;Englisch;Ukrainisch;Arabisch)
/// Gibt neben der Wortliste die gefundene Kopfzeile zurück.
Future<(List<VocabPair>, List<String>)> loadAllPairs() async {
  final csv = await rootBundle.loadString('assets/Vokabeln alle.csv');
  final lines = const LineSplitter().convert(csv.trim());

  if (lines.isEmpty) return (<VocabPair>[], <String>[]);

  final header = lines.first.split(';').map((s) => s.trim()).toList();
  final pairs = <VocabPair>[];

  for (final line in lines.skip(1)) {
    final cols = line.split(';');
    if (cols.length != header.length) continue;

    final map = <String, String>{};
    for (var i = 0; i < header.length; i++) {
      final word = cols[i].trim();
      if (word.isNotEmpty) map[header[i]] = word;
    }
    if (map.length >= 2) pairs.add(VocabPair(map));
  }
  return (pairs, header);
}
