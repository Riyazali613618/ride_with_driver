import 'package:equatable/equatable.dart';

import '../../../api/api_model/language/language_model.dart';

abstract class LanguageState extends Equatable {
  const LanguageState();

  Language? get currentLanguage {
    switch (this.runtimeType) {
      case LanguageLoadSuccess:
        return (this as LanguageLoadSuccess).currentLanguage;
      case LanguageChangeSuccess:
        return (this as LanguageChangeSuccess).currentLanguage;
      case LanguageChangeInProgress:
        return (this as LanguageChangeInProgress).currentLanguage;
      case LanguageChangeFailure:
        return (this as LanguageChangeFailure).currentLanguage;
      case LanguageLoadFailure:
        return (this as LanguageLoadFailure).currentLanguage;
      default:
        return null;
    }
  }

  List<Language>? get languages {
    switch (this.runtimeType) {
      case LanguageLoadSuccess:
        return (this as LanguageLoadSuccess).languages;
      case LanguageChangeSuccess:
        return (this as LanguageChangeSuccess).languages;
      case LanguageChangeInProgress:
        return (this as LanguageChangeInProgress).languages;
      case LanguageChangeFailure:
        return (this as LanguageChangeFailure).languages;
      case LanguageLoadFailure:
        return (this as LanguageLoadFailure).languages;
      default:
        return null;
    }
  }

  @override
  List<Object> get props => [];
}

class LanguageInitial extends LanguageState {}

class LanguageLoadInProgress extends LanguageState {}

class LanguageLoadSuccess extends LanguageState {
  final Language currentLanguage;
  final List<Language> languages;

  const LanguageLoadSuccess({
    required this.currentLanguage,
    required this.languages,
  });

  @override
  List<Object> get props => [currentLanguage, languages];
}

class LanguageLoadFailure extends LanguageState {
  final String error;
  final Language currentLanguage;
  final List<Language> languages;

  const LanguageLoadFailure({
    required this.error,
    required this.currentLanguage,
    required this.languages,
  });

  @override
  List<Object> get props => [error, currentLanguage, languages];
}

class LanguageChangeInProgress extends LanguageState {
  final Language currentLanguage;
  final List<Language> languages;

  const LanguageChangeInProgress({
    required this.currentLanguage,
    required this.languages,
  });

  @override
  List<Object> get props => [currentLanguage, languages];
}

class LanguageChangeSuccess extends LanguageState {
  final Language currentLanguage;
  final List<Language> languages;

  const LanguageChangeSuccess({
    required this.currentLanguage,
    required this.languages,
  });

  @override
  List<Object> get props => [currentLanguage, languages];
}

class LanguageChangeFailure extends LanguageState {
  final String error;
  final Language currentLanguage;
  final List<Language> languages;

  const LanguageChangeFailure({
    required this.error,
    required this.currentLanguage,
    required this.languages,
  });

  @override
  List<Object> get props => [error, currentLanguage, languages];
}
