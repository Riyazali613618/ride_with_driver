import 'dart:ui';
import 'package:shared_preferences/shared_preferences.dart';

class CountryPhoneCode {
  final String countryName;
  final String countryCode;
  final String dialCode;
  final String flag;
  final int phoneNumberLength;
  final int? maxPhoneNumberLength; // For countries with variable length

  const CountryPhoneCode({
    required this.countryName,
    required this.countryCode,
    required this.dialCode,
    required this.flag,
    required this.phoneNumberLength,
    this.maxPhoneNumberLength,
  });

  // Check if a phone number length is valid for this country
  bool isValidLength(int length) {
    if (maxPhoneNumberLength != null) {
      return length >= phoneNumberLength && length <= maxPhoneNumberLength!;
    }
    return length == phoneNumberLength;
  }

  String get displayText => '$flag $dialCode';

  String get fullDisplayText => '$flag $countryName $dialCode';

  // Map dial code to ISO country code for API headers
  String get isoCountryCode {
    switch (dialCode) {
      case '+91':
        return 'IND';
      case '+62':
        return 'IDN';
      case '+971':
        return 'ARE';
      case '+1':
        return 'USA';
      case '+44':
        return 'GBR';
      case '+86':
        return 'CHN';
      case '+81':
        return 'JPN';
      case '+82':
        return 'KOR';
      case '+33':
        return 'FRA';
      case '+49':
        return 'DEU';
      case '+55':
        return 'BRA';
      case '+61':
        return 'AUS';
      case '+7':
        return 'RUS';
      case '+34':
        return 'ESP';
      case '+39':
        return 'ITA';
      case '+60':
        return 'MYS';
      case '+65':
        return 'SGP';
      case '+66':
        return 'THA';
      case '+84':
        return 'VNM';
      case '+63':
        return 'PHL';
      default:
        // Use the country code from the country name instead of hardcoded fallback
        return _getCountryCodeFromName();
    }
  }

  // Helper method to get country code from country name
  String _getCountryCodeFromName() {
    // Map common country names to their ISO codes
    switch (countryName.toLowerCase()) {
      case 'india':
        return 'IND';
      case 'indonesia':
        return 'IDN';
      case 'united arab emirates':
      case 'uae':
        return 'ARE';
      case 'united states':
      case 'usa':
        return 'USA';
      case 'united kingdom':
      case 'uk':
        return 'GBR';
      case 'china':
        return 'CHN';
      case 'japan':
        return 'JPN';
      case 'south korea':
      case 'korea':
        return 'KOR';
      case 'france':
        return 'FRA';
      case 'germany':
        return 'DEU';
      case 'brazil':
        return 'BRA';
      case 'australia':
        return 'AUS';
      case 'russia':
        return 'RUS';
      case 'spain':
        return 'ESP';
      case 'italy':
        return 'ITA';
      case 'malaysia':
        return 'MYS';
      case 'singapore':
        return 'SGP';
      case 'thailand':
        return 'THA';
      case 'vietnam':
        return 'VNM';
      case 'philippines':
        return 'PHL';
      default:
        // If no match found, try to extract from country code
        return countryCode.toUpperCase();
    }
  }

  // Helper method to get currency from country name
  String _getCurrencyFromCountryName() {
    // Extract currency from country name for unsupported dial codes
    switch (countryName.toLowerCase()) {
      case 'india':
        return 'INR';
      case 'indonesia':
        return 'IDR';
      case 'united arab emirates':
      case 'uae':
        return 'AED';
      case 'united states':
      case 'usa':
        return 'USD';
      case 'united kingdom':
      case 'uk':
        return 'GBP';
      case 'china':
        return 'CNY';
      case 'japan':
        return 'JPY';
      case 'south korea':
      case 'korea':
        return 'KRW';
      case 'france':
      case 'germany':
      case 'spain':
      case 'italy':
        return 'EUR';
      case 'brazil':
        return 'BRL';
      case 'australia':
        return 'AUD';
      case 'russia':
        return 'RUB';
      case 'malaysia':
        return 'MYR';
      case 'singapore':
        return 'SGD';
      case 'thailand':
        return 'THB';
      case 'vietnam':
        return 'VND';
      case 'philippines':
        return 'PHP';
      default:
        // For unknown countries, try to use USD as international fallback
        return 'USD';
    }
  }

  // Map country to appropriate currency code
  String get currencyCode {
    switch (dialCode) {
      case '+91':
        return 'INR';
      case '+62':
        return 'IDR';
      case '+971':
        return 'AED';
      case '+1':
        return 'USD';
      case '+44':
        return 'GBP';
      case '+86':
        return 'CNY';
      case '+81':
        return 'JPY';
      case '+82':
        return 'KRW';
      case '+33':
        return 'EUR';
      case '+49':
        return 'EUR';
      case '+55':
        return 'BRL';
      case '+61':
        return 'AUD';
      case '+7':
        return 'RUB';
      case '+34':
        return 'EUR';
      case '+39':
        return 'EUR';
      case '+60':
        return 'MYR';
      case '+65':
        return 'SGD';
      case '+66':
        return 'THB';
      case '+84':
        return 'VND';
      case '+63':
        return 'PHP';
      default:
        // Use dynamic currency detection based on country name
        return _getCurrencyFromCountryName();
    }
  }
}

class CountryPhoneCodes {
  static const List<CountryPhoneCode> allCountries = [
    CountryPhoneCode(
        countryName: 'Afghanistan',
        countryCode: 'AF',
        dialCode: '+93',
        flag: '🇦🇫',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Albania',
        countryCode: 'AL',
        dialCode: '+355',
        flag: '🇦🇱',
        phoneNumberLength: 8,
        maxPhoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Algeria',
        countryCode: 'DZ',
        dialCode: '+213',
        flag: '🇩🇿',
        phoneNumberLength: 8,
        maxPhoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'American Samoa',
        countryCode: 'AS',
        dialCode: '+1',
        flag: '🇦🇸',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Andorra',
        countryCode: 'AD',
        dialCode: '+376',
        flag: '🇦🇩',
        phoneNumberLength: 6),
    CountryPhoneCode(
        countryName: 'Angola',
        countryCode: 'AO',
        dialCode: '+244',
        flag: '🇦🇴',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Anguilla',
        countryCode: 'AI',
        dialCode: '+1',
        flag: '🇦🇮',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Antarctica',
        countryCode: 'AQ',
        dialCode: '+672',
        flag: '🇦🇶',
        phoneNumberLength: 6),
    CountryPhoneCode(
        countryName: 'Antigua and Barbuda',
        countryCode: 'AG',
        dialCode: '+1',
        flag: '🇦🇬',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Argentina',
        countryCode: 'AR',
        dialCode: '+54',
        flag: '🇦🇷',
        phoneNumberLength: 10,
        maxPhoneNumberLength: 11),
    CountryPhoneCode(
        countryName: 'Armenia',
        countryCode: 'AM',
        dialCode: '+374',
        flag: '🇦🇲',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Aruba',
        countryCode: 'AW',
        dialCode: '+297',
        flag: '🇦🇼',
        phoneNumberLength: 7),
    CountryPhoneCode(
        countryName: 'Australia',
        countryCode: 'AU',
        dialCode: '+61',
        flag: '🇦🇺',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Austria',
        countryCode: 'AT',
        dialCode: '+43',
        flag: '🇦🇹',
        phoneNumberLength: 10,
        maxPhoneNumberLength: 12),
    CountryPhoneCode(
        countryName: 'Azerbaijan',
        countryCode: 'AZ',
        dialCode: '+994',
        flag: '🇦🇿',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Bahamas',
        countryCode: 'BS',
        dialCode: '+1',
        flag: '🇧🇸',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Bahrain',
        countryCode: 'BH',
        dialCode: '+973',
        flag: '🇧🇭',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Bangladesh',
        countryCode: 'BD',
        dialCode: '+880',
        flag: '🇧🇩',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Barbados',
        countryCode: 'BB',
        dialCode: '+1',
        flag: '🇧🇧',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Belarus',
        countryCode: 'BY',
        dialCode: '+375',
        flag: '🇧🇾',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Belgium',
        countryCode: 'BE',
        dialCode: '+32',
        flag: '🇧🇪',
        phoneNumberLength: 8,
        maxPhoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Belize',
        countryCode: 'BZ',
        dialCode: '+501',
        flag: '🇧🇿',
        phoneNumberLength: 7),
    CountryPhoneCode(
        countryName: 'Benin',
        countryCode: 'BJ',
        dialCode: '+229',
        flag: '🇧🇯',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Bermuda',
        countryCode: 'BM',
        dialCode: '+1',
        flag: '🇧🇲',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Bhutan',
        countryCode: 'BT',
        dialCode: '+975',
        flag: '🇧🇹',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Bolivia',
        countryCode: 'BO',
        dialCode: '+591',
        flag: '🇧🇴',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Bosnia and Herzegovina',
        countryCode: 'BA',
        dialCode: '+387',
        flag: '🇧🇦',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Botswana',
        countryCode: 'BW',
        dialCode: '+267',
        flag: '🇧🇼',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Brazil',
        countryCode: 'BR',
        dialCode: '+55',
        flag: '🇧🇷',
        phoneNumberLength: 10,
        maxPhoneNumberLength: 11),
    CountryPhoneCode(
        countryName: 'British Indian Ocean Territory',
        countryCode: 'IO',
        dialCode: '+246',
        flag: '🇮🇴',
        phoneNumberLength: 7),
    CountryPhoneCode(
        countryName: 'British Virgin Islands',
        countryCode: 'VG',
        dialCode: '+1',
        flag: '🇻🇬',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Brunei',
        countryCode: 'BN',
        dialCode: '+673',
        flag: '🇧🇳',
        phoneNumberLength: 7),
    CountryPhoneCode(
        countryName: 'Bulgaria',
        countryCode: 'BG',
        dialCode: '+359',
        flag: '🇧🇬',
        phoneNumberLength: 8,
        maxPhoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Burkina Faso',
        countryCode: 'BF',
        dialCode: '+226',
        flag: '🇧🇫',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Burundi',
        countryCode: 'BI',
        dialCode: '+257',
        flag: '🇧🇮',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Cambodia',
        countryCode: 'KH',
        dialCode: '+855',
        flag: '🇰🇭',
        phoneNumberLength: 8,
        maxPhoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Cameroon',
        countryCode: 'CM',
        dialCode: '+237',
        flag: '🇨🇲',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Canada',
        countryCode: 'CA',
        dialCode: '+1',
        flag: '🇨🇦',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Cape Verde',
        countryCode: 'CV',
        dialCode: '+238',
        flag: '🇨🇻',
        phoneNumberLength: 7),
    CountryPhoneCode(
        countryName: 'Cayman Islands',
        countryCode: 'KY',
        dialCode: '+1',
        flag: '🇰🇾',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Central African Republic',
        countryCode: 'CF',
        dialCode: '+236',
        flag: '🇨🇫',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Chad',
        countryCode: 'TD',
        dialCode: '+235',
        flag: '🇹🇩',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Chile',
        countryCode: 'CL',
        dialCode: '+56',
        flag: '🇨🇱',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'China',
        countryCode: 'CN',
        dialCode: '+86',
        flag: '🇨🇳',
        phoneNumberLength: 10,
        maxPhoneNumberLength: 11),
    CountryPhoneCode(
        countryName: 'Christmas Island',
        countryCode: 'CX',
        dialCode: '+61',
        flag: '🇨🇽',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Cocos Islands',
        countryCode: 'CC',
        dialCode: '+61',
        flag: '🇨🇨',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Colombia',
        countryCode: 'CO',
        dialCode: '+57',
        flag: '🇨🇴',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Comoros',
        countryCode: 'KM',
        dialCode: '+269',
        flag: '🇰🇲',
        phoneNumberLength: 7),
    CountryPhoneCode(
        countryName: 'Cook Islands',
        countryCode: 'CK',
        dialCode: '+682',
        flag: '🇨🇰',
        phoneNumberLength: 5),
    CountryPhoneCode(
        countryName: 'Costa Rica',
        countryCode: 'CR',
        dialCode: '+506',
        flag: '🇨🇷',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Croatia',
        countryCode: 'HR',
        dialCode: '+385',
        flag: '🇭🇷',
        phoneNumberLength: 8,
        maxPhoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Cuba',
        countryCode: 'CU',
        dialCode: '+53',
        flag: '🇨🇺',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Curacao',
        countryCode: 'CW',
        dialCode: '+599',
        flag: '🇨🇼',
        phoneNumberLength: 7),
    CountryPhoneCode(
        countryName: 'Cyprus',
        countryCode: 'CY',
        dialCode: '+357',
        flag: '🇨🇾',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Czech Republic',
        countryCode: 'CZ',
        dialCode: '+420',
        flag: '🇨🇿',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Democratic Republic of the Congo',
        countryCode: 'CD',
        dialCode: '+243',
        flag: '🇨🇩',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Denmark',
        countryCode: 'DK',
        dialCode: '+45',
        flag: '🇩🇰',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Djibouti',
        countryCode: 'DJ',
        dialCode: '+253',
        flag: '🇩🇯',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Dominica',
        countryCode: 'DM',
        dialCode: '+1',
        flag: '🇩🇲',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Dominican Republic',
        countryCode: 'DO',
        dialCode: '+1',
        flag: '🇩🇴',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'East Timor',
        countryCode: 'TL',
        dialCode: '+670',
        flag: '🇹🇱',
        phoneNumberLength: 7,
        maxPhoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Ecuador',
        countryCode: 'EC',
        dialCode: '+593',
        flag: '🇪🇨',
        phoneNumberLength: 8,
        maxPhoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Egypt',
        countryCode: 'EG',
        dialCode: '+20',
        flag: '🇪🇬',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'El Salvador',
        countryCode: 'SV',
        dialCode: '+503',
        flag: '🇸🇻',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Equatorial Guinea',
        countryCode: 'GQ',
        dialCode: '+240',
        flag: '🇬🇶',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Eritrea',
        countryCode: 'ER',
        dialCode: '+291',
        flag: '🇪🇷',
        phoneNumberLength: 7),
    CountryPhoneCode(
        countryName: 'Estonia',
        countryCode: 'EE',
        dialCode: '+372',
        flag: '🇪🇪',
        phoneNumberLength: 7,
        maxPhoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Ethiopia',
        countryCode: 'ET',
        dialCode: '+251',
        flag: '🇪🇹',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Falkland Islands',
        countryCode: 'FK',
        dialCode: '+500',
        flag: '🇫🇰',
        phoneNumberLength: 5),
    CountryPhoneCode(
        countryName: 'Faroe Islands',
        countryCode: 'FO',
        dialCode: '+298',
        flag: '🇫🇴',
        phoneNumberLength: 6),
    CountryPhoneCode(
        countryName: 'Fiji',
        countryCode: 'FJ',
        dialCode: '+679',
        flag: '🇫🇯',
        phoneNumberLength: 7),
    CountryPhoneCode(
        countryName: 'Finland',
        countryCode: 'FI',
        dialCode: '+358',
        flag: '🇫🇮',
        phoneNumberLength: 9,
        maxPhoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'France',
        countryCode: 'FR',
        dialCode: '+33',
        flag: '🇫🇷',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'French Polynesia',
        countryCode: 'PF',
        dialCode: '+689',
        flag: '🇵🇫',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Gabon',
        countryCode: 'GA',
        dialCode: '+241',
        flag: '🇬🇦',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Gambia',
        countryCode: 'GM',
        dialCode: '+220',
        flag: '🇬🇲',
        phoneNumberLength: 7),
    CountryPhoneCode(
        countryName: 'Georgia',
        countryCode: 'GE',
        dialCode: '+995',
        flag: '🇬🇪',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Germany',
        countryCode: 'DE',
        dialCode: '+49',
        flag: '🇩🇪',
        phoneNumberLength: 10,
        maxPhoneNumberLength: 12),
    CountryPhoneCode(
        countryName: 'Ghana',
        countryCode: 'GH',
        dialCode: '+233',
        flag: '🇬🇭',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Gibraltar',
        countryCode: 'GI',
        dialCode: '+350',
        flag: '🇬🇮',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Greece',
        countryCode: 'GR',
        dialCode: '+30',
        flag: '🇬🇷',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Greenland',
        countryCode: 'GL',
        dialCode: '+299',
        flag: '🇬🇱',
        phoneNumberLength: 6),
    CountryPhoneCode(
        countryName: 'Grenada',
        countryCode: 'GD',
        dialCode: '+1',
        flag: '🇬🇩',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Guam',
        countryCode: 'GU',
        dialCode: '+1',
        flag: '🇬🇺',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Guatemala',
        countryCode: 'GT',
        dialCode: '+502',
        flag: '🇬🇹',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Guernsey',
        countryCode: 'GG',
        dialCode: '+44',
        flag: '🇬🇬',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Guinea',
        countryCode: 'GN',
        dialCode: '+224',
        flag: '🇬🇳',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Guinea-Bissau',
        countryCode: 'GW',
        dialCode: '+245',
        flag: '🇬🇼',
        phoneNumberLength: 7),
    CountryPhoneCode(
        countryName: 'Guyana',
        countryCode: 'GY',
        dialCode: '+592',
        flag: '🇬🇾',
        phoneNumberLength: 7),
    CountryPhoneCode(
        countryName: 'Haiti',
        countryCode: 'HT',
        dialCode: '+509',
        flag: '🇭🇹',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Honduras',
        countryCode: 'HN',
        dialCode: '+504',
        flag: '🇭🇳',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Hong Kong',
        countryCode: 'HK',
        dialCode: '+852',
        flag: '🇭🇰',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Hungary',
        countryCode: 'HU',
        dialCode: '+36',
        flag: '🇭🇺',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Iceland',
        countryCode: 'IS',
        dialCode: '+354',
        flag: '🇮🇸',
        phoneNumberLength: 7),
    CountryPhoneCode(
        countryName: 'India',
        countryCode: 'IN',
        dialCode: '+91',
        flag: '🇮🇳',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Indonesia',
        countryCode: 'ID',
        dialCode: '+62',
        flag: '🇮🇩',
        phoneNumberLength: 7,
        maxPhoneNumberLength: 13),
    CountryPhoneCode(
        countryName: 'Iran',
        countryCode: 'IR',
        dialCode: '+98',
        flag: '🇮🇷',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Iraq',
        countryCode: 'IQ',
        dialCode: '+964',
        flag: '🇮🇶',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Ireland',
        countryCode: 'IE',
        dialCode: '+353',
        flag: '🇮🇪',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Isle of Man',
        countryCode: 'IM',
        dialCode: '+44',
        flag: '🇮🇲',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Israel',
        countryCode: 'IL',
        dialCode: '+972',
        flag: '🇮🇱',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Italy',
        countryCode: 'IT',
        dialCode: '+39',
        flag: '🇮🇹',
        phoneNumberLength: 9,
        maxPhoneNumberLength: 11),
    CountryPhoneCode(
        countryName: 'Ivory Coast',
        countryCode: 'CI',
        dialCode: '+225',
        flag: '🇨🇮',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Jamaica',
        countryCode: 'JM',
        dialCode: '+1',
        flag: '🇯🇲',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Japan',
        countryCode: 'JP',
        dialCode: '+81',
        flag: '🇯🇵',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Jersey',
        countryCode: 'JE',
        dialCode: '+44',
        flag: '🇯🇪',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Jordan',
        countryCode: 'JO',
        dialCode: '+962',
        flag: '🇯🇴',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Kazakhstan',
        countryCode: 'KZ',
        dialCode: '+7',
        flag: '🇰🇿',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Kenya',
        countryCode: 'KE',
        dialCode: '+254',
        flag: '🇰🇪',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Kiribati',
        countryCode: 'KI',
        dialCode: '+686',
        flag: '🇰🇮',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Kosovo',
        countryCode: 'XK',
        dialCode: '+383',
        flag: '🇽🇰',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Kuwait',
        countryCode: 'KW',
        dialCode: '+965',
        flag: '🇰🇼',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Kyrgyzstan',
        countryCode: 'KG',
        dialCode: '+996',
        flag: '🇰🇬',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Laos',
        countryCode: 'LA',
        dialCode: '+856',
        flag: '🇱🇦',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Latvia',
        countryCode: 'LV',
        dialCode: '+371',
        flag: '🇱🇻',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Lebanon',
        countryCode: 'LB',
        dialCode: '+961',
        flag: '🇱🇧',
        phoneNumberLength: 7,
        maxPhoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Lesotho',
        countryCode: 'LS',
        dialCode: '+266',
        flag: '🇱🇸',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Liberia',
        countryCode: 'LR',
        dialCode: '+231',
        flag: '🇱🇷',
        phoneNumberLength: 7,
        maxPhoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Libya',
        countryCode: 'LY',
        dialCode: '+218',
        flag: '🇱🇾',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Liechtenstein',
        countryCode: 'LI',
        dialCode: '+423',
        flag: '🇱🇮',
        phoneNumberLength: 7),
    CountryPhoneCode(
        countryName: 'Lithuania',
        countryCode: 'LT',
        dialCode: '+370',
        flag: '🇱🇹',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Luxembourg',
        countryCode: 'LU',
        dialCode: '+352',
        flag: '🇱🇺',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Macau',
        countryCode: 'MO',
        dialCode: '+853',
        flag: '🇲🇴',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Macedonia',
        countryCode: 'MK',
        dialCode: '+389',
        flag: '🇲🇰',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Madagascar',
        countryCode: 'MG',
        dialCode: '+261',
        flag: '🇲🇬',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Malawi',
        countryCode: 'MW',
        dialCode: '+265',
        flag: '🇲🇼',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Malaysia',
        countryCode: 'MY',
        dialCode: '+60',
        flag: '🇲🇾',
        phoneNumberLength: 9,
        maxPhoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Maldives',
        countryCode: 'MV',
        dialCode: '+960',
        flag: '🇲🇻',
        phoneNumberLength: 7),
    CountryPhoneCode(
        countryName: 'Mali',
        countryCode: 'ML',
        dialCode: '+223',
        flag: '🇲🇱',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Malta',
        countryCode: 'MT',
        dialCode: '+356',
        flag: '🇲🇹',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Marshall Islands',
        countryCode: 'MH',
        dialCode: '+692',
        flag: '🇲🇭',
        phoneNumberLength: 7),
    CountryPhoneCode(
        countryName: 'Mauritania',
        countryCode: 'MR',
        dialCode: '+222',
        flag: '🇲🇷',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Mauritius',
        countryCode: 'MU',
        dialCode: '+230',
        flag: '🇲🇺',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Mayotte',
        countryCode: 'YT',
        dialCode: '+262',
        flag: '🇾🇹',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Mexico',
        countryCode: 'MX',
        dialCode: '+52',
        flag: '🇲🇽',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Micronesia',
        countryCode: 'FM',
        dialCode: '+691',
        flag: '🇫🇲',
        phoneNumberLength: 7),
    CountryPhoneCode(
        countryName: 'Moldova',
        countryCode: 'MD',
        dialCode: '+373',
        flag: '🇲🇩',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Monaco',
        countryCode: 'MC',
        dialCode: '+377',
        flag: '🇲🇨',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Mongolia',
        countryCode: 'MN',
        dialCode: '+976',
        flag: '🇲🇳',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Montenegro',
        countryCode: 'ME',
        dialCode: '+382',
        flag: '🇲🇪',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Montserrat',
        countryCode: 'MS',
        dialCode: '+1',
        flag: '🇲🇸',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Morocco',
        countryCode: 'MA',
        dialCode: '+212',
        flag: '🇲🇦',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Mozambique',
        countryCode: 'MZ',
        dialCode: '+258',
        flag: '🇲🇿',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Myanmar',
        countryCode: 'MM',
        dialCode: '+95',
        flag: '🇲🇲',
        phoneNumberLength: 8,
        maxPhoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Namibia',
        countryCode: 'NA',
        dialCode: '+264',
        flag: '🇳🇦',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Nauru',
        countryCode: 'NR',
        dialCode: '+674',
        flag: '🇳🇷',
        phoneNumberLength: 7),
    CountryPhoneCode(
        countryName: 'Nepal',
        countryCode: 'NP',
        dialCode: '+977',
        flag: '🇳🇵',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Netherlands',
        countryCode: 'NL',
        dialCode: '+31',
        flag: '🇳🇱',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'New Caledonia',
        countryCode: 'NC',
        dialCode: '+687',
        flag: '🇳🇨',
        phoneNumberLength: 6),
    CountryPhoneCode(
        countryName: 'New Zealand',
        countryCode: 'NZ',
        dialCode: '+64',
        flag: '🇳🇿',
        phoneNumberLength: 8,
        maxPhoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Nicaragua',
        countryCode: 'NI',
        dialCode: '+505',
        flag: '🇳🇮',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Niger',
        countryCode: 'NE',
        dialCode: '+227',
        flag: '🇳🇪',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Nigeria',
        countryCode: 'NG',
        dialCode: '+234',
        flag: '🇳🇬',
        phoneNumberLength: 8,
        maxPhoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Niue',
        countryCode: 'NU',
        dialCode: '+683',
        flag: '🇳🇺',
        phoneNumberLength: 4),
    CountryPhoneCode(
        countryName: 'Norfolk Island',
        countryCode: 'NF',
        dialCode: '+672',
        flag: '🇳🇫',
        phoneNumberLength: 6),
    CountryPhoneCode(
        countryName: 'North Korea',
        countryCode: 'KP',
        dialCode: '+850',
        flag: '🇰🇵',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Northern Mariana Islands',
        countryCode: 'MP',
        dialCode: '+1',
        flag: '🇲🇵',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Norway',
        countryCode: 'NO',
        dialCode: '+47',
        flag: '🇳🇴',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Oman',
        countryCode: 'OM',
        dialCode: '+968',
        flag: '🇴🇲',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Pakistan',
        countryCode: 'PK',
        dialCode: '+92',
        flag: '🇵🇰',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Palau',
        countryCode: 'PW',
        dialCode: '+680',
        flag: '🇵🇼',
        phoneNumberLength: 7),
    CountryPhoneCode(
        countryName: 'Palestine',
        countryCode: 'PS',
        dialCode: '+970',
        flag: '🇵🇸',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Panama',
        countryCode: 'PA',
        dialCode: '+507',
        flag: '🇵🇦',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Papua New Guinea',
        countryCode: 'PG',
        dialCode: '+675',
        flag: '🇵🇬',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Paraguay',
        countryCode: 'PY',
        dialCode: '+595',
        flag: '🇵🇾',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Peru',
        countryCode: 'PE',
        dialCode: '+51',
        flag: '🇵🇪',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Philippines',
        countryCode: 'PH',
        dialCode: '+63',
        flag: '🇵🇭',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Pitcairn',
        countryCode: 'PN',
        dialCode: '+64',
        flag: '🇵🇳',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Poland',
        countryCode: 'PL',
        dialCode: '+48',
        flag: '🇵🇱',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Portugal',
        countryCode: 'PT',
        dialCode: '+351',
        flag: '🇵🇹',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Puerto Rico',
        countryCode: 'PR',
        dialCode: '+1',
        flag: '🇵🇷',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Qatar',
        countryCode: 'QA',
        dialCode: '+974',
        flag: '🇶🇦',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Republic of the Congo',
        countryCode: 'CG',
        dialCode: '+242',
        flag: '🇨🇬',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Reunion',
        countryCode: 'RE',
        dialCode: '+262',
        flag: '🇷🇪',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Romania',
        countryCode: 'RO',
        dialCode: '+40',
        flag: '🇷🇴',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Russia',
        countryCode: 'RU',
        dialCode: '+7',
        flag: '🇷🇺',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Rwanda',
        countryCode: 'RW',
        dialCode: '+250',
        flag: '🇷🇼',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Saint Barthelemy',
        countryCode: 'BL',
        dialCode: '+590',
        flag: '🇧🇱',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Saint Helena',
        countryCode: 'SH',
        dialCode: '+290',
        flag: '🇸🇭',
        phoneNumberLength: 4),
    CountryPhoneCode(
        countryName: 'Saint Kitts and Nevis',
        countryCode: 'KN',
        dialCode: '+1',
        flag: '🇰🇳',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Saint Lucia',
        countryCode: 'LC',
        dialCode: '+1',
        flag: '🇱🇨',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Saint Martin',
        countryCode: 'MF',
        dialCode: '+590',
        flag: '🇲🇫',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Saint Pierre and Miquelon',
        countryCode: 'PM',
        dialCode: '+508',
        flag: '🇵🇲',
        phoneNumberLength: 6),
    CountryPhoneCode(
        countryName: 'Saint Vincent and the Grenadines',
        countryCode: 'VC',
        dialCode: '+1',
        flag: '🇻🇨',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Samoa',
        countryCode: 'WS',
        dialCode: '+685',
        flag: '🇼🇸',
        phoneNumberLength: 7),
    CountryPhoneCode(
        countryName: 'San Marino',
        countryCode: 'SM',
        dialCode: '+378',
        flag: '🇸🇲',
        phoneNumberLength: 6),
    CountryPhoneCode(
        countryName: 'Sao Tome and Principe',
        countryCode: 'ST',
        dialCode: '+239',
        flag: '🇸🇹',
        phoneNumberLength: 7),
    CountryPhoneCode(
        countryName: 'Saudi Arabia',
        countryCode: 'SA',
        dialCode: '+966',
        flag: '🇸🇦',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Senegal',
        countryCode: 'SN',
        dialCode: '+221',
        flag: '🇸🇳',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Serbia',
        countryCode: 'RS',
        dialCode: '+381',
        flag: '🇷🇸',
        phoneNumberLength: 8,
        maxPhoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Seychelles',
        countryCode: 'SC',
        dialCode: '+248',
        flag: '🇸🇨',
        phoneNumberLength: 7),
    CountryPhoneCode(
        countryName: 'Sierra Leone',
        countryCode: 'SL',
        dialCode: '+232',
        flag: '🇸🇱',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Singapore',
        countryCode: 'SG',
        dialCode: '+65',
        flag: '🇸🇬',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Sint Maarten',
        countryCode: 'SX',
        dialCode: '+1',
        flag: '🇸🇽',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Slovakia',
        countryCode: 'SK',
        dialCode: '+421',
        flag: '🇸🇰',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Slovenia',
        countryCode: 'SI',
        dialCode: '+386',
        flag: '🇸🇮',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Solomon Islands',
        countryCode: 'SB',
        dialCode: '+677',
        flag: '🇸🇧',
        phoneNumberLength: 7),
    CountryPhoneCode(
        countryName: 'Somalia',
        countryCode: 'SO',
        dialCode: '+252',
        flag: '🇸🇴',
        phoneNumberLength: 8,
        maxPhoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'South Africa',
        countryCode: 'ZA',
        dialCode: '+27',
        flag: '🇿🇦',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'South Georgia and the South Sandwich Islands',
        countryCode: 'GS',
        dialCode: '+500',
        flag: '🇬🇸',
        phoneNumberLength: 5),
    CountryPhoneCode(
        countryName: 'South Korea',
        countryCode: 'KR',
        dialCode: '+82',
        flag: '🇰🇷',
        phoneNumberLength: 8,
        maxPhoneNumberLength: 11),
    CountryPhoneCode(
        countryName: 'South Sudan',
        countryCode: 'SS',
        dialCode: '+211',
        flag: '🇸🇸',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Spain',
        countryCode: 'ES',
        dialCode: '+34',
        flag: '🇪🇸',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Sri Lanka',
        countryCode: 'LK',
        dialCode: '+94',
        flag: '🇱🇰',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Sudan',
        countryCode: 'SD',
        dialCode: '+249',
        flag: '🇸🇩',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Suriname',
        countryCode: 'SR',
        dialCode: '+597',
        flag: '🇸🇷',
        phoneNumberLength: 7),
    CountryPhoneCode(
        countryName: 'Svalbard and Jan Mayen',
        countryCode: 'SJ',
        dialCode: '+47',
        flag: '🇸🇯',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Swaziland',
        countryCode: 'SZ',
        dialCode: '+268',
        flag: '🇸🇿',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Sweden',
        countryCode: 'SE',
        dialCode: '+46',
        flag: '🇸🇪',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Switzerland',
        countryCode: 'CH',
        dialCode: '+41',
        flag: '🇨🇭',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Syria',
        countryCode: 'SY',
        dialCode: '+963',
        flag: '🇸🇾',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Taiwan',
        countryCode: 'TW',
        dialCode: '+886',
        flag: '🇹🇼',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Tajikistan',
        countryCode: 'TJ',
        dialCode: '+992',
        flag: '🇹🇯',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Tanzania',
        countryCode: 'TZ',
        dialCode: '+255',
        flag: '🇹🇿',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Thailand',
        countryCode: 'TH',
        dialCode: '+66',
        flag: '🇹🇭',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Togo',
        countryCode: 'TG',
        dialCode: '+228',
        flag: '🇹🇬',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Tokelau',
        countryCode: 'TK',
        dialCode: '+690',
        flag: '🇹🇰',
        phoneNumberLength: 4),
    CountryPhoneCode(
        countryName: 'Tonga',
        countryCode: 'TO',
        dialCode: '+676',
        flag: '🇹🇴',
        phoneNumberLength: 5),
    CountryPhoneCode(
        countryName: 'Trinidad and Tobago',
        countryCode: 'TT',
        dialCode: '+1',
        flag: '🇹🇹',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Tunisia',
        countryCode: 'TN',
        dialCode: '+216',
        flag: '🇹🇳',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Turkey',
        countryCode: 'TR',
        dialCode: '+90',
        flag: '🇹🇷',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Turkmenistan',
        countryCode: 'TM',
        dialCode: '+993',
        flag: '🇹🇲',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Turks and Caicos Islands',
        countryCode: 'TC',
        dialCode: '+1',
        flag: '🇹🇨',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Tuvalu',
        countryCode: 'TV',
        dialCode: '+688',
        flag: '🇹🇻',
        phoneNumberLength: 5),
    CountryPhoneCode(
        countryName: 'U.S. Virgin Islands',
        countryCode: 'VI',
        dialCode: '+1',
        flag: '🇻🇮',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Uganda',
        countryCode: 'UG',
        dialCode: '+256',
        flag: '🇺🇬',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Ukraine',
        countryCode: 'UA',
        dialCode: '+380',
        flag: '🇺🇦',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'United Arab Emirates',
        countryCode: 'AE',
        dialCode: '+971',
        flag: '🇦🇪',
        phoneNumberLength: 8,
        maxPhoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'United Kingdom',
        countryCode: 'GB',
        dialCode: '+44',
        flag: '🇬🇧',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'United States',
        countryCode: 'US',
        dialCode: '+1',
        flag: '🇺🇸',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Uruguay',
        countryCode: 'UY',
        dialCode: '+598',
        flag: '🇺🇾',
        phoneNumberLength: 8),
    CountryPhoneCode(
        countryName: 'Uzbekistan',
        countryCode: 'UZ',
        dialCode: '+998',
        flag: '🇺🇿',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Vanuatu',
        countryCode: 'VU',
        dialCode: '+678',
        flag: '🇻🇺',
        phoneNumberLength: 7),
    CountryPhoneCode(
        countryName: 'Vatican',
        countryCode: 'VA',
        dialCode: '+379',
        flag: '🇻🇦',
        phoneNumberLength: 6),
    CountryPhoneCode(
        countryName: 'Venezuela',
        countryCode: 'VE',
        dialCode: '+58',
        flag: '🇻🇪',
        phoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Vietnam',
        countryCode: 'VN',
        dialCode: '+84',
        flag: '🇻🇳',
        phoneNumberLength: 9,
        maxPhoneNumberLength: 10),
    CountryPhoneCode(
        countryName: 'Wallis and Futuna',
        countryCode: 'WF',
        dialCode: '+681',
        flag: '🇼🇫',
        phoneNumberLength: 6),
    CountryPhoneCode(
        countryName: 'Western Sahara',
        countryCode: 'EH',
        dialCode: '+212',
        flag: '🇪🇭',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Yemen',
        countryCode: 'YE',
        dialCode: '+967',
        flag: '🇾🇪',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Zambia',
        countryCode: 'ZM',
        dialCode: '+260',
        flag: '🇿🇲',
        phoneNumberLength: 9),
    CountryPhoneCode(
        countryName: 'Zimbabwe',
        countryCode: 'ZW',
        dialCode: '+263',
        flag: '🇿🇼',
        phoneNumberLength: 9),
  ];

  static CountryPhoneCode? getByCountryCode(String countryCode) {
    try {
      return allCountries.firstWhere(
        (country) =>
            country.countryCode.toLowerCase() == countryCode.toLowerCase(),
      );
    } catch (e) {
      return null;
    }
  }

  static CountryPhoneCode? getByDialCode(String dialCode) {
    try {
      return allCountries.firstWhere(
        (country) => country.dialCode == dialCode,
      );
    } catch (e) {
      return null;
    }
  }

  static Future<CountryPhoneCode> get defaultCountry async {
    // Try to get user's previously selected country first
    try {
      final pref = await SharedPreferences.getInstance();
      final userCountryCode = pref.getString('selectedCountryDialCode');
      if (userCountryCode != null && userCountryCode.isNotEmpty) {
        final userCountry = getByDialCode(userCountryCode);
        if (userCountry != null) {
          return userCountry;
        }
      }
    } catch (e) {
      // Fallback to device locale detection
    }

    // Fallback to device locale detection
    final detected = detectCountryFromLocale();
    if (detected != null) {
      return detected;
    }

    // Final fallback to India
    return getByCountryCode('IN') ?? allCountries.first;
  }

  // Detect country from device locale
  static CountryPhoneCode? detectCountryFromLocale() {
    try {
      final deviceLocale = PlatformDispatcher.instance.locale;
      final countryCode = deviceLocale.countryCode?.toUpperCase();

      if (countryCode != null) {
        return getByCountryCode(countryCode);
      }
    } catch (e) {
      // Fallback to default if detection fails
    }
    return null;
  }

  // Get country by device region with fallback
  static Future<CountryPhoneCode> getCountryForUser() async {
    final detected = detectCountryFromLocale();
    final value = (detected ?? await defaultCountry);
    return value;
  }

  // Force update country based on phone number selection
  static Future<void> updateCountryFromPhoneNumber(String dialCode) async {
    final country = getByDialCode(dialCode);
    if (country != null) {
      final pref = await SharedPreferences.getInstance();
      pref.setString('selectedCountryDialCode', country.dialCode);
      pref.setString('selectedCurrencyCode', country.currencyCode);
      // Update the main country code used by API headers
      pref.setString('countryCode', country.isoCountryCode);
      print(
          'Updated country to: ${country.countryName} (${country.isoCountryCode})');
    }
  }
}
