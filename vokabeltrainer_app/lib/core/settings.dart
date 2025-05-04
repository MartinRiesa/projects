import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Settings extends ChangeNotifier {
  static const _keySpeak = 'speakEnabled';
  bool _speakEnabled = true;

  bool get speakEnabled => _speakEnabled;

  Future<void> load() async {
    final sp = await SharedPreferences.getInstance();
    _speakEnabled = sp.getBool(_keySpeak) ?? true;
    notifyListeners();
  }

  Future<void> toggleSpeak() async {
    _speakEnabled = !_speakEnabled;
    notifyListeners();
    final sp = await SharedPreferences.getInstance();
    await sp.setBool(_keySpeak, _speakEnabled);
  }
}
