class AppLanguage {
  static final AppLanguage _instance = AppLanguage._internal();
  String languageCode = "de"; // Default: Deutsch

  factory AppLanguage() => _instance;
  AppLanguage._internal();

  static AppLanguage get instance => _instance;

  static void setLanguage(String code) {
    _instance.languageCode = code;
  }

  static String getLanguage() {
    return _instance.languageCode;
  }
}
