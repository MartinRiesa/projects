// lib/core/vocab_loader.dart

import 'dart:convert';
import 'package:flutter/services.dart' show rootBundle;
import 'package:vokabeltrainer_app/core/vocab_pair.dart';

/// Liest die erste Zeile der CSV und liefert die verfügbaren Sprachen.
Future<List<String>> loadLanguages() async {
  final raw = await rootBundle.loadString('assets/Vokabeln alle.csv');
  final firstLine = raw.split('\n').first;
  return firstLine.split(';').map((s) => s.trim()).toList();
}

/// Lädt Wortpaare aus der CSV-Datei assets/Vokabeln alle.csv
/// und erstellt VocabPair-Instanzen mit Fehlerzähler.
Future<List<VocabPair>> loadWordPairs() async {
  final raw = await rootBundle.loadString('assets/Vokabeln alle.csv');
  final lines = const LineSplitter().convert(raw);
  final pairs = <VocabPair>[];

  for (var i = 1; i < lines.length; i++) {
    final line = lines[i].trim();
    if (line.isEmpty) continue;
    final parts = line.split(';');
    if (parts.length >= 2) {
      pairs.add(VocabPair(
        en: parts[0].trim(),
        de: parts[1].trim(),
      ));
    }
  }
  return pairs;
}
