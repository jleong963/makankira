/// Country reference data for the phone-number field: ISO 3166-1 alpha-2 code
/// (used to render the flag), international dial code (digits, no `+`), and the
/// English name. Comprehensive but easy to extend — add a row and it appears in
/// the picker automatically.
class Country {
  final String iso;
  final String dial;
  final String name;
  const Country(this.iso, this.dial, this.name);
}

/// Alphabetical by name. Malaysia is the app default (see [defaultCountry]).
const List<Country> countries = [
  Country('AF', '93', 'Afghanistan'),
  Country('AL', '355', 'Albania'),
  Country('DZ', '213', 'Algeria'),
  Country('AR', '54', 'Argentina'),
  Country('AU', '61', 'Australia'),
  Country('AT', '43', 'Austria'),
  Country('BH', '973', 'Bahrain'),
  Country('BD', '880', 'Bangladesh'),
  Country('BE', '32', 'Belgium'),
  Country('BT', '975', 'Bhutan'),
  Country('BO', '591', 'Bolivia'),
  Country('BR', '55', 'Brazil'),
  Country('BN', '673', 'Brunei'),
  Country('BG', '359', 'Bulgaria'),
  Country('KH', '855', 'Cambodia'),
  Country('CM', '237', 'Cameroon'),
  Country('CA', '1', 'Canada'),
  Country('CL', '56', 'Chile'),
  Country('CN', '86', 'China'),
  Country('CO', '57', 'Colombia'),
  Country('CR', '506', 'Costa Rica'),
  Country('HR', '385', 'Croatia'),
  Country('CY', '357', 'Cyprus'),
  Country('CZ', '420', 'Czechia'),
  Country('DK', '45', 'Denmark'),
  Country('EG', '20', 'Egypt'),
  Country('EE', '372', 'Estonia'),
  Country('ET', '251', 'Ethiopia'),
  Country('FI', '358', 'Finland'),
  Country('FR', '33', 'France'),
  Country('GE', '995', 'Georgia'),
  Country('DE', '49', 'Germany'),
  Country('GH', '233', 'Ghana'),
  Country('GR', '30', 'Greece'),
  Country('HK', '852', 'Hong Kong'),
  Country('HU', '36', 'Hungary'),
  Country('IS', '354', 'Iceland'),
  Country('IN', '91', 'India'),
  Country('ID', '62', 'Indonesia'),
  Country('IR', '98', 'Iran'),
  Country('IQ', '964', 'Iraq'),
  Country('IE', '353', 'Ireland'),
  Country('IL', '972', 'Israel'),
  Country('IT', '39', 'Italy'),
  Country('JP', '81', 'Japan'),
  Country('JO', '962', 'Jordan'),
  Country('KZ', '7', 'Kazakhstan'),
  Country('KE', '254', 'Kenya'),
  Country('KW', '965', 'Kuwait'),
  Country('LA', '856', 'Laos'),
  Country('LV', '371', 'Latvia'),
  Country('LB', '961', 'Lebanon'),
  Country('LT', '370', 'Lithuania'),
  Country('LU', '352', 'Luxembourg'),
  Country('MO', '853', 'Macau'),
  Country('MY', '60', 'Malaysia'),
  Country('MV', '960', 'Maldives'),
  Country('MT', '356', 'Malta'),
  Country('MX', '52', 'Mexico'),
  Country('MN', '976', 'Mongolia'),
  Country('MA', '212', 'Morocco'),
  Country('MM', '95', 'Myanmar'),
  Country('NP', '977', 'Nepal'),
  Country('NL', '31', 'Netherlands'),
  Country('NZ', '64', 'New Zealand'),
  Country('NG', '234', 'Nigeria'),
  Country('NO', '47', 'Norway'),
  Country('OM', '968', 'Oman'),
  Country('PK', '92', 'Pakistan'),
  Country('PS', '970', 'Palestine'),
  Country('PA', '507', 'Panama'),
  Country('PG', '675', 'Papua New Guinea'),
  Country('PE', '51', 'Peru'),
  Country('PH', '63', 'Philippines'),
  Country('PL', '48', 'Poland'),
  Country('PT', '351', 'Portugal'),
  Country('QA', '974', 'Qatar'),
  Country('RO', '40', 'Romania'),
  Country('RU', '7', 'Russia'),
  Country('SA', '966', 'Saudi Arabia'),
  Country('RS', '381', 'Serbia'),
  Country('SG', '65', 'Singapore'),
  Country('SK', '421', 'Slovakia'),
  Country('SI', '386', 'Slovenia'),
  Country('ZA', '27', 'South Africa'),
  Country('KR', '82', 'South Korea'),
  Country('ES', '34', 'Spain'),
  Country('LK', '94', 'Sri Lanka'),
  Country('SE', '46', 'Sweden'),
  Country('CH', '41', 'Switzerland'),
  Country('TW', '886', 'Taiwan'),
  Country('TZ', '255', 'Tanzania'),
  Country('TH', '66', 'Thailand'),
  Country('TR', '90', 'Türkiye'),
  Country('UG', '256', 'Uganda'),
  Country('UA', '380', 'Ukraine'),
  Country('AE', '971', 'United Arab Emirates'),
  Country('GB', '44', 'United Kingdom'),
  Country('US', '1', 'United States'),
  Country('UY', '598', 'Uruguay'),
  Country('UZ', '998', 'Uzbekistan'),
  Country('VN', '84', 'Vietnam'),
  Country('YE', '967', 'Yemen'),
  Country('ZM', '260', 'Zambia'),
  Country('ZW', '263', 'Zimbabwe'),
];

/// The app default (Malaysia-localized).
final Country defaultCountry = countries.firstWhere((c) => c.iso == 'MY');

/// For dial codes shared by several countries, the one [parsePhone] should pick.
const Map<String, String> _dialPrimaryIso = {'1': 'US', '7': 'RU'};

/// Split a stored number (E.164 digits, e.g. `60123456789` or `+60…`) into its
/// country and national part. Uses the longest matching dial code. Falls back to
/// [defaultCountry] with the raw digits when nothing matches (e.g. legacy or
/// blank values), so the field always has a sensible starting country.
({Country country, String national}) parsePhone(String? stored) {
  final digits = (stored ?? '').replaceAll(RegExp(r'[^0-9]'), '');
  if (digits.isEmpty) return (country: defaultCountry, national: '');

  Country? best;
  for (final c in countries) {
    if (!digits.startsWith(c.dial)) continue;
    if (best == null || c.dial.length > best.dial.length) {
      best = c;
    } else if (c.dial.length == best.dial.length && _dialPrimaryIso[c.dial] == c.iso) {
      best = c; // prefer the designated primary for shared codes (+1, +7)
    }
  }
  if (best == null) return (country: defaultCountry, national: digits);
  return (country: best, national: digits.substring(best.dial.length));
}
