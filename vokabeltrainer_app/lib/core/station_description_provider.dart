import 'package:flutter/services.dart' show rootBundle;

class StationDescriptionProvider {
  static Map<int, String>? _explanations;

  /// Lädt die CSV-Datei und erstellt eine Map von Levelnummer auf Erklärungstext.
  static Future<void> _loadData() async {
    if (_explanations != null) return;  // Bereits geladen
    final csv = await rootBundle.loadString('assets/Stationenbeschreibung-englisch.csv');
    final lines = csv.split('\n');
    final map = <int, String>{};
    if (lines.isNotEmpty) {
      // Spaltenüberschriften auslesen und Index der Spalte 'Erklärung' bestimmen
      final header = lines[0].split(';');
      final index = header.indexOf('Erklärung');
      for (var i = 1; i < lines.length; i++) {
        final parts = lines[i].split(';');
        if (parts.length > index) {
          final nr = int.tryParse(parts[0].trim());
          if (nr != null) {
            var text = parts[index];
            // Anführungszeichen am Anfang und Ende entfernen, falls vorhanden
            if (text.startsWith('"') && text.endsWith('"')) {
              text = text.substring(1, text.length - 1);
            }
            map[nr] = text;
          }
        }
      }
    }
    _explanations = map;
  }

  /// Liefert den Erklärungstext für das gegebene Level (oder `null`, wenn nicht gefunden).
  static Future<String?> getExplanation(int level) async {
    await _loadData();
    return _explanations?[level];
  }
}
