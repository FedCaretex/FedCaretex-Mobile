import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'app_language';

  String _currentLanguage = 'id';
  String get currentLanguage => _currentLanguage;
  Locale get locale => Locale(_currentLanguage);

  LanguageProvider() {
    _loadLanguage();
  }

  Future<void> _loadLanguage() async {
    try {
      final pref = await SharedPreferences.getInstance();
      final savedLanguage = pref.getString(_languageKey);
      if (savedLanguage != null) {
        _currentLanguage = savedLanguage;
        notifyListeners();
      }
    } catch (_) {}
  }

  Future<void> setLanguage(String languageCode) async {
    if (_currentLanguage == languageCode) return;
    _currentLanguage = languageCode;
    notifyListeners();
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(_languageKey, languageCode);
    } catch (_) {}
  }

  String get languageName {
    switch (_currentLanguage) {
      case 'en':
        return 'English';
      case 'id':
      default:
        return 'Indonesia';
    }
  }

  String translate(Map<String, String> values) {
    return values[_currentLanguage] ?? values['id'] ?? '';
  }
}
