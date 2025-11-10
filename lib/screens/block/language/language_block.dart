import 'dart:async';

import 'package:bloc/bloc.dart';
import 'package:r_w_r/screens/block/language/language_event.dart';
import 'package:r_w_r/screens/block/language/language_repo.dart';
import 'package:r_w_r/screens/block/language/language_state.dart';

class LanguageBloc extends Bloc<LanguageEvent, LanguageState> {
  final LanguageRepository languageRepository;

  LanguageBloc({required this.languageRepository}) : super(LanguageInitial()) {
    on<LoadLanguage>(_onLoadLanguage);
    on<ChangeLanguage>(_onChangeLanguage);
  }

  Future<void> _onLoadLanguage(
    LoadLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    emit(LanguageLoadInProgress());
    try {
      final currentLanguage = await languageRepository.getCurrentLanguage();
      emit(LanguageLoadSuccess(
        currentLanguage:
            currentLanguage ?? LanguageRepository.supportedLanguages.first,
        languages: LanguageRepository.supportedLanguages,
      ));
    } catch (e) {
      emit(LanguageLoadFailure(
        error: 'Failed to load language: ${e.toString()}',
        currentLanguage: LanguageRepository.supportedLanguages.first,
        languages: LanguageRepository.supportedLanguages,
      ));
    }
  }

  Future<void> _onChangeLanguage(
    ChangeLanguage event,
    Emitter<LanguageState> emit,
  ) async {
    // Get current language and languages from any valid state
    final currentLanguage = state.currentLanguage;
    final languages = state.languages;

    if (currentLanguage == null || languages == null) {
      emit(LanguageChangeFailure(
        error: 'Invalid state: missing language data',
        currentLanguage: LanguageRepository.supportedLanguages.first,
        languages: LanguageRepository.supportedLanguages,
      ));
      return;
    }

    // Don't change if it's the same language
    if (currentLanguage.code == event.language.code) {
      return;
    }

    emit(LanguageChangeInProgress(
      currentLanguage: currentLanguage,
      languages: languages,
    ));

    try {
      final success = await languageRepository.updateLanguage(event.language);
      if (success) {
        emit(LanguageChangeSuccess(
          currentLanguage: event.language,
          languages: languages,
        ));
      } else {
        emit(LanguageChangeFailure(
          error: 'Failed to update language on server',
          currentLanguage: currentLanguage,
          languages: languages,
        ));
      }
    } catch (e) {
      emit(LanguageChangeFailure(
        error: 'Network error: ${e.toString()}',
        currentLanguage: currentLanguage,
        languages: languages,
      ));
    }
  }
}
