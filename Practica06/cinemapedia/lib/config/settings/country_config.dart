class CountryConfig {
  final String code;
  final String flag;
  final String name;
  final String languageName;
  final String tmdbLanguage;

  const CountryConfig({
    required this.code,
    required this.flag,
    required this.name,
    required this.languageName,
    required this.tmdbLanguage,
  });

  static const options = <CountryConfig>[
    CountryConfig(
      code: 'MX',
      flag: '🇲🇽',
      name: 'México',
      languageName: 'Español',
      tmdbLanguage: 'es-MX',
    ),
    CountryConfig(
      code: 'US',
      flag: '🇺🇸',
      name: 'United States',
      languageName: 'English',
      tmdbLanguage: 'en-US',
    ),
    CountryConfig(
      code: 'DE',
      flag: '🇩🇪',
      name: 'Deutschland',
      languageName: 'Deutsch',
      tmdbLanguage: 'de-DE',
    ),
    CountryConfig(
      code: 'KR',
      flag: '🇰🇷',
      name: '대한민국',
      languageName: '한국어',
      tmdbLanguage: 'ko-KR',
    ),
    CountryConfig(
      code: 'EG',
      flag: '🇪🇬',
      name: 'مصر',
      languageName: 'العربية',
      tmdbLanguage: 'ar-EG',
    ),
    CountryConfig(
      code: 'AU',
      flag: '🇦🇺',
      name: 'Australia',
      languageName: 'English',
      tmdbLanguage: 'en-AU',
    ),
  ];

  String get region => code;
  static CountryConfig byCode(String code) => options.firstWhere(
    (option) => option.code == code,
    orElse: () => options.first,
  );
}
