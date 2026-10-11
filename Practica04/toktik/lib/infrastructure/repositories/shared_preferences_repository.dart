import 'package:shared_preferences/shared_preferences.dart';
import 'package:toktik/domain/repositories/app_preferences_repository.dart';

class SharedPreferencesRepository implements AppPreferencesRepository {
  static const _seasonModeKey = 'season_mode';
  static const _manualSeasonKey = 'manual_season';
  static const _likedVideoIdsKey = 'liked_video_ids';

  Future<SharedPreferences> get _preferences => SharedPreferences.getInstance();

  @override
  Future<String?> getSeasonMode() async =>
      (await _preferences).getString(_seasonModeKey);

  @override
  Future<String?> getManualSeason() async =>
      (await _preferences).getString(_manualSeasonKey);

  @override
  Future<void> saveSeasonMode(String mode) async {
    await (await _preferences).setString(_seasonModeKey, mode);
  }

  @override
  Future<void> saveManualSeason(String season) async {
    await (await _preferences).setString(_manualSeasonKey, season);
  }

  @override
  Future<Set<String>> getLikedVideoIds() async =>
      (await _preferences).getStringList(_likedVideoIdsKey)?.toSet() ??
      <String>{};

  @override
  Future<void> saveLikedVideoIds(Set<String> ids) async {
    await (await _preferences).setStringList(
      _likedVideoIdsKey,
      ids.toList()..sort(),
    );
  }
}
