class CountryCodeItem {
  final String name;
  final String code;
  final String dialCode;
  final String flag;

  const CountryCodeItem({
    required this.name,
    required this.code,
    required this.dialCode,
    required this.flag,
  });

  String get displayText => '$flag $dialCode ($name)';
}

class CountryCodes {
  CountryCodes._();

  static const CountryCodeItem defaultCountry = CountryCodeItem(
    name: 'Việt Nam',
    code: 'VN',
    dialCode: '+84',
    flag: '🇻🇳',
  );

  static const List<CountryCodeItem> list = [
    CountryCodeItem(name: 'Việt Nam', code: 'VN', dialCode: '+84', flag: '🇻🇳'),
    CountryCodeItem(name: 'Hoa Kỳ', code: 'US', dialCode: '+1', flag: '🇺🇸'),
    CountryCodeItem(name: 'Nhật Bản', code: 'JP', dialCode: '+81', flag: '🇯🇵'),
    CountryCodeItem(name: 'Hàn Quốc', code: 'KR', dialCode: '+82', flag: '🇰🇷'),
    CountryCodeItem(name: 'Singapore', code: 'SG', dialCode: '+65', flag: '🇸🇬'),
    CountryCodeItem(name: 'Thái Lan', code: 'TH', dialCode: '+66', flag: '🇹🇭'),
    CountryCodeItem(name: 'Vương quốc Anh', code: 'GB', dialCode: '+44', flag: '🇬🇧'),
    CountryCodeItem(name: 'Úc', code: 'AU', dialCode: '+61', flag: '🇦🇺'),
    CountryCodeItem(name: 'Pháp', code: 'FR', dialCode: '+33', flag: '🇫🇷'),
    CountryCodeItem(name: 'Đức', code: 'DE', dialCode: '+49', flag: '🇩🇪'),
    CountryCodeItem(name: 'Đài Loan', code: 'TW', dialCode: '+886', flag: '🇹🇼'),
    CountryCodeItem(name: 'Trung Quốc', code: 'CN', dialCode: '+86', flag: '🇨🇳'),
    CountryCodeItem(name: 'Canada', code: 'CA', dialCode: '+1', flag: '🇨🇦'),
    CountryCodeItem(name: 'Malaysia', code: 'MY', dialCode: '+60', flag: '🇲🇾'),
    CountryCodeItem(name: 'Indonesia', code: 'ID', dialCode: '+62', flag: '🇮🇩'),
    CountryCodeItem(name: 'Philippines', code: 'PH', dialCode: '+63', flag: '🇵🇭'),
  ];
}
