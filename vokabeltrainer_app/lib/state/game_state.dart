// lib/state/game_state.dart
//
// Einfacher ChangeNotifier, der Lern- und Muttersprache
// sowie den Spielstand hält.

import 'package:flutter/foundation.dart';

class GameState extends ChangeNotifier {
  String learnLang  = 'Deutsch';
  String nativeLang = 'English';

  // Beispiel für weitere Felder (Level etc.)
  int level = 1;

  void setLanguages(String learn, String native) {
    learnLang  = learn;
    nativeLang = native;
    notifyListeners();
  }

  void nextLevel() {
    level += 1;
    notifyListeners();
  }
}
