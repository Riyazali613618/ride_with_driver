import 'package:equatable/equatable.dart';

import '../../../api/api_model/language/language_model.dart';

abstract class LanguageEvent extends Equatable {
  const LanguageEvent();

  @override
  List<Object> get props => [];
}

class LoadLanguage extends LanguageEvent {
  const LoadLanguage();
}

class ChangeLanguage extends LanguageEvent {
  final Language language;

  const ChangeLanguage(this.language);

  @override
  List<Object> get props => [language];
}
