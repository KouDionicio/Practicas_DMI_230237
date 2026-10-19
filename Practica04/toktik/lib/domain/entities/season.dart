enum SeasonMode { automatic, manual }

enum Season {
  normal(
    splashLogoAsset: 'assets/icons/normal.png',
    launcherAlias: 'MainActivityNormal',
    launcherIconResource: 'ic_launcher_normal',
  ),
  halloween(
    splashLogoAsset: 'assets/icons/halloween.png',
    launcherAlias: 'MainActivityHalloween',
    launcherIconResource: 'ic_launcher_halloween',
  ),
  christmas(
    splashLogoAsset: 'assets/icons/navidad.png',
    launcherAlias: 'MainActivityChristmas',
    launcherIconResource: 'ic_launcher_christmas',
  ),
  valentines(
    splashLogoAsset: 'assets/icons/san_valentin.png',
    launcherAlias: 'MainActivityValentines',
    launcherIconResource: 'ic_launcher_valentines',
  );

  const Season({
    required this.splashLogoAsset,
    required this.launcherAlias,
    required this.launcherIconResource,
  });

  final String splashLogoAsset;
  final String launcherAlias;
  final String launcherIconResource;

  String get iconAsset => splashLogoAsset;
}

class SeasonCalendar {
  const SeasonCalendar._();

  static Season forDate(DateTime date) {
    final day = date.day;
    final month = date.month;
    if (month == DateTime.october) return Season.halloween;
    if (month == DateTime.december ||
        (month == DateTime.january && day <= 6)) {
      return Season.christmas;
    }
    if (month == DateTime.february && day <= 14) {
      return Season.valentines;
    }
    return Season.normal;
  }
}
