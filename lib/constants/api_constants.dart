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

  static const String dummyImageUrl =
      "https://media.ridewithdriver.s3.ap-south-1.amazonaws.com/profile/695a64266b7c3a198e8dc03b/1767554947519-77e51c11.jpg";
}
