class ApiConstants {
  static const String baseUrl = "https://api.ridewithdriverr.com";
  static const String apiKey = 'AIzaSyDUkuN7zD7ApTqkkEyzOXnS_LDxEzP-t40';
  static const String defaultLanguageCodeEng = '507f1f77bcf86cd799439011';
  static const String defaultCountryCodeInd = '507f1f77bcf86cd799439036';
  static const String defaultStateCodeDel = '694d10ecdc4afcdfa9fbdb1c';

  // static const String baseUrl = "https://api.ridewithdriverr.com";

  //
  // static const String baseUrl =
  //     "https://still-rooster-presently.ngrok-free.app";

  static const int success = 200;
  static const int unauthorized = 401;
  static const int badRequest = 400;
  static const int serverError = 500;

  static const int connectionTimeout = 15;
  static const int receiveTimeout = 15;

  static const vehicles = '/user/vehicles';
}

class AppConstants {
  static const String planEligibilityKey = 'plan_eligibility_key';
  static const String preRegistration = "PRE_REGISTRATION";
}
