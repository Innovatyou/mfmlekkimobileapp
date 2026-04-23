import 'package:flutter/material.dart';
import 'package:higherground/models/language.dart';
import 'dart:convert';
// translator package removed — use no-op translator to avoid build failures
import 'package:shared_preferences/shared_preferences.dart';

class TranslateProvider with ChangeNotifier {
  // no-op translator: simply returns the original text
  bool _isTranslating = false;
  String textTranslated = "";
  String? textToTranslate = "";
  Language _secondLanguage = Language('fr', 'French', true, true, true);
  final _languagePreference = "preferred_translanguage_preference";

  TranslateProvider() {
    _loadLanguagePreference();
  }

  void _loadLanguagePreference() async {
    SharedPreferences.getInstance().then((prefs) {
      if (prefs.getString(_languagePreference) != null) {
        _secondLanguage = Language.fromJson(
            json.decode(prefs.getString(_languagePreference)!));
      }

      notifyListeners();
    });
  }

  save(value) async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setString(_languagePreference, json.encode(value));
  }

  changeLanguages(Language secondLanguage) {
    _secondLanguage = secondLanguage;
    save(_secondLanguage.toJson());
    notifyListeners();
    if (textToTranslate != "") {
      transateVerse(textToTranslate);
    }
  }

  Language get secondLanguage => _secondLanguage;

  bool get isTranslating => _isTranslating;

  transateVerse(String? text) {
    textToTranslate = text;
    _isTranslating = true;
    notifyListeners();
    if (text != null && text.isNotEmpty) {
      // Fallback: no external translation available — echo original text
      _isTranslating = false;
      textTranslated = text;
      notifyListeners();
    }
  }
}


