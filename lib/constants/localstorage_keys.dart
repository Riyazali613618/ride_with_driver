enum LocalStorageKeys {
  accessToken('user_access_token_123'),
  name('name'),
  email('email'),
  latitude('LAT'),
  longitude('LONG'),
  profileAvatar('profile_avatar'),
  location('location'),
  phone('phone'),
  firstLogin("first_login"),
  countryCode("country_code"),
  languageSelected("language_selected");
  final String token;
  const LocalStorageKeys(this.token);
}
