// models/language_model.dart
class Language {
  final String code;
  final String name;
  final String nativeName;

  const Language({
    required this.code,
    required this.name,
    required this.nativeName,
  });

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Language &&
          runtimeType == other.runtimeType &&
          code == other.code;

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() {
    return 'Language{code: $code, name: $name, nativeName: $nativeName}';
  }
}

enum ApplicationStatus {
  notStarted,
  personalInfoComplete,
  documentsComplete,
  vehicleInfoComplete,
  fareAndCitiesComplete,
  submitted,
  approved,
  rejected
}
