import 'package:flutter/material.dart';
import 'package:r_w_r/api/api_model/language/language_model.dart';
import 'package:r_w_r/api/api_model/languageModel.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../api/api_service/language_service.dart';
import 'language_repo.dart';

class LanguageProvider extends ChangeNotifier {
  static const String _languageKey = 'selected_language';
  static const String _localeKey = 'selected_locale';

  final LanguageRepository _languageRepository = LanguageRepository();

  Language? _currentLanguage;
  Locale _currentLocale = const Locale('en', '');
  bool _isLoading = false;
  String? _error;
  String _selectedLangCode='';

  // List to store languages from API
  List<Language> _languages = [];
  List<Data> _langApi=[];
  bool _isLanguagesLoaded = false;

  // Getters
  Language? get currentLanguage => _currentLanguage;
  Locale get currentLocale => _currentLocale;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String? get langCode => _selectedLangCode;

  // Updated getter to return API languages if loaded, otherwise fallback to local
  List<Language> get languages => _languages.isNotEmpty
      ? _languages
      : LanguageRepository.supportedLanguages;
  List<Data>? get language => _langApi.isNotEmpty
      ? _langApi
      : null;

  bool get isLanguagesLoaded => _isLanguagesLoaded;

  LanguageProvider() {
    _initialize();
  }

  // Initialize provider: fetch languages from API and load saved language
  Future<void> _initialize() async {
    await fetchLanguagesFromApi();
    await _loadSavedLanguage();
  }

  void setLangCode(String langCode){
    print("setLangCode:${langCode}");
    _selectedLangCode=langCode;
    notifyListeners();
  }

  // Fetch languages from API
  Future<void> fetchLanguagesFromApi() async {
    try {
      _setLoading(true);
      _clearError();

      debugPrint('Fetching languages from API...');

      final languageModel = await LanguageService.getLanguages();

      print("languageModel.success:${languageModel.success}--${languageModel.data}");

      if (languageModel.success == true && languageModel.data != null) {
         _langApi = languageModel.data!;
        _isLanguagesLoaded = true;
        debugPrint('Successfully fetched ${_languages.length} languages from API');
      } else {
        throw Exception('Invalid response from API');
      }
    } catch (e) {
      _setError('Failed to fetch languages: $e');
      debugPrint('Error fetching languages: $e');

      // Fallback to local languages if API fails
      _languages = LanguageRepository.supportedLanguages;
      _isLanguagesLoaded = false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> _loadSavedLanguage() async {
    try {
      _setLoading(true);

      // Try to get language from repository first
      final currentLanguage = await _languageRepository.getCurrentLanguage();

      if (currentLanguage != null) {
        _currentLanguage = currentLanguage;
        _currentLocale = Locale(currentLanguage.code, '');
      } else {
        // Fallback to SharedPreferences
        final prefs = await SharedPreferences.getInstance();
        final savedLanguageCode = prefs.getString(_languageKey);

        if (savedLanguageCode != null) {
          // Try to find in API languages first, then fallback to local
          final language = languages.firstWhere(
                (lang) => lang.code == savedLanguageCode,
            orElse: () => languages.first,
          );
          _currentLanguage = language;
          _currentLocale = Locale(language.code, '');
        } else {
          // Default to English or first available language
          _currentLanguage = languages.first;
          _currentLocale = Locale(languages.first.code, '');
        }
      }

      _clearError();
    } catch (e) {
      _setError('Error loading saved language: $e');
      // Set default language on error
      _currentLanguage = languages.isNotEmpty
          ? languages.first
          : LanguageRepository.supportedLanguages.first;
      _currentLocale = Locale(_currentLanguage!.code, '');
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changeLanguage(Language language) async {
    try {
      _setLoading(true);
      _clearError();

      // Update via repository
     // final success = await _languageRepository.updateLanguage(language);

      if (true) {
        // Update current language and locale
        _currentLanguage = language;
        _currentLocale = Locale(language.code, '');

        // Save to SharedPreferences as fallback
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString(_languageKey, language.code);
        await prefs.setString(_localeKey, language.code);

        debugPrint('Language changed to: ${language.name} (${language.code})');
      } else {
        _setError('Failed to update language on server');
      }
    } catch (e) {
      _setError('Error changing language: $e');
      debugPrint('Error changing language: $e');
    } finally {
      _setLoading(false);
    }
  }

  Language? getLanguageByCode(String code) {
    try {
      return languages.firstWhere(
            (lang) => lang.code == code,
      );
    } catch (e) {
      return null;
    }
  }

  bool isLanguageSupported(String code) {
    return languages.any(
          (lang) => lang.code == code,
    );
  }

  Future<void> resetToDefault() async {
    if (languages.isNotEmpty) {
      await changeLanguage(languages.first);
    }
  }

  // Refresh languages from API (can be called manually if needed)
  Future<void> refreshLanguages() async {
    await fetchLanguagesFromApi();
  }

  void changeCurrentLocale(Locale cL) {
    _currentLocale = cL;
    notifyListeners();
  }

  // Private state management methods
  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }
}