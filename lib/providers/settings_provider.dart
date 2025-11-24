import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';


enum AppLanguage {
  portuguese('pt', 'BR'),
  english('en', 'US');

  final String languageCode;
  final String countryCode;

  const AppLanguage(this.languageCode, this.countryCode);

  Locale get locale => Locale(languageCode, countryCode);
  
  String getDisplayName(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    switch (this) {
      case AppLanguage.portuguese:
        return localizations?.portuguese ?? 'Português';
      case AppLanguage.english:
        return localizations?.english ?? 'English';
    }
  }
}

enum AppThemeMode {
  light('light'),
  dark('dark'),
  system('system');

  final String value;

  const AppThemeMode(this.value);

  ThemeMode get themeMode {
    switch (this) {
      case AppThemeMode.light:
        return ThemeMode.light;
      case AppThemeMode.dark:
        return ThemeMode.dark;
      case AppThemeMode.system:
        return ThemeMode.system;
    }
  }
  
  String getDisplayName(BuildContext context) {
    final localizations = AppLocalizations.of(context);
    switch (this) {
      case AppThemeMode.light:
        return localizations?.light ?? 'Claro';
      case AppThemeMode.dark:
        return localizations?.dark ?? 'Escuro';
      case AppThemeMode.system:
        return localizations?.system ?? 'Sistema';
    }
  }
}

class SettingsProvider extends ChangeNotifier {
  static const String _languageKey = 'app_language';
  static const String _themeKey = 'app_theme';

  AppLanguage _currentLanguage = AppLanguage.portuguese;
  AppThemeMode _currentTheme = AppThemeMode.system;

  AppLanguage get currentLanguage => _currentLanguage;
  AppThemeMode get currentTheme => _currentTheme;
  Locale get currentLocale => _currentLanguage.locale;
  ThemeMode get themeMode => _currentTheme.themeMode;

  SettingsProvider() {
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    
    // Carregar idioma
    final languageValue = prefs.getString(_languageKey);
    if (languageValue != null) {
      _currentLanguage = AppLanguage.values.firstWhere(
        (lang) => lang.languageCode == languageValue,
        orElse: () => AppLanguage.portuguese,
      );
    }

    // Carregar tema
    final themeValue = prefs.getString(_themeKey);
    if (themeValue != null) {
      _currentTheme = AppThemeMode.values.firstWhere(
        (theme) => theme.value == themeValue,
        orElse: () => AppThemeMode.system,
      );
    }

    notifyListeners();
  }

  Future<void> setLanguage(AppLanguage language) async {
    if (_currentLanguage == language) return;

    _currentLanguage = language;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_languageKey, language.languageCode);
    notifyListeners();
  }

  Future<void> setTheme(AppThemeMode theme) async {
    if (_currentTheme == theme) return;

    _currentTheme = theme;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_themeKey, theme.value);
    notifyListeners();
  }
}

