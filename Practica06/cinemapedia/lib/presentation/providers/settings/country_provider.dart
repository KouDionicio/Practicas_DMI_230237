import 'package:flutter_riverpod/legacy.dart';
import 'package:cinemapedia/config/settings/country_config.dart';
import 'package:shared_preferences/shared_preferences.dart';

final selectedCountryProvider =
    StateNotifierProvider<CountryNotifier, CountryConfig>(
      (ref) => CountryNotifier(),
    );

class CountryNotifier extends StateNotifier<CountryConfig> {
  CountryNotifier({CountryConfig? initialCountry})
    : super(initialCountry ?? CountryConfig.options.first);

  Future<void> select(CountryConfig country) async {
    if (state.code == country.code) return;
    state = country;
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString('selected_country', country.code);
  }
}
