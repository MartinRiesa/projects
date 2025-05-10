import 'package:flutter/services.dart' show rootBundle;
import 'package:csv/csv.dart';
import 'vocab_pair.dart';

class VocabLoader {
  /// Lädt alle Vokabeln für [sourceLang] → [targetLang].
  /// Optional: nur ein bestimmtes [levelFilter].
  static Future<List<VocabPair>> load(
    String sourceLang,
    String targetLang, {
    int? levelFilter,
  }) async {
    final raw =
        await rootBundle.loadString('assets/Vokabeln alle.csv');

    final rows = const CsvToListConverter(
      fieldDelimiter: ';',
      eol: '\n',
      shouldParseNumbers: false,
    ).convert(raw);

    if (rows.isEmpty) throw 'CSV leer';

    final header = rows.first.cast<String>();
    final idxLvl = header.indexOf('Level');
    final idxSrc = header.indexOf(sourceLang);
    final idxTgt = header.indexOf(targetLang);

    if (idxLvl < 0 || idxSrc < 0 || idxTgt < 0) {
      throw 'Spalten nicht gefunden ($sourceLang/$targetLang)';
    }

    final list = <VocabPair>[];
    for (final r in rows.skip(1)) {
      if (r.length <= idxTgt) continue;
      final lvl = int.tryParse(r[idxLvl].toString()) ?? 0;
      if (levelFilter != null && lvl != levelFilter) continue;

      list.add(VocabPair(
        prompt: r[idxSrc].toString().trim(),
        answer: r[idxTgt].toString().trim(),
      ));
    }
    if (list.isEmpty) throw 'Keine Daten für Level $levelFilter';
    return list;
  }
}
