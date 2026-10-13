import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:toktik/domain/repositories/app_preferences_repository.dart';

class SharedPreferencesRepository implements AppPreferencesRepository {
  static const _seasonModeKey = 'season_mode';
  static const _manualSeasonKey = 'manual_season';
  static const _likedVideoIdsKey = 'liked_video_ids';
  static const _videoLikeCountsKey = 'video_like_counts';

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

  @override
  Future<Map<String, int>> getVideoLikeCounts() async {
    final serialized = (await _preferences).getString(_videoLikeCountsKey);
    if (serialized == null) return <String, int>{};

    final decoded = jsonDecode(serialized);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Saved video like counts are invalid.');
    }

    final counts = <String, int>{};
    for (final entry in decoded.entries) {
      final value = entry.value;
      if (value is! int || value < 0) {
        throw FormatException(
          'Saved like count for ${entry.key} must be a non-negative integer.',
        );
      }
      counts[entry.key] = value;
    }
    return counts;
  }

  @override
  Future<void> saveVideoLikeCounts(Map<String, int> counts) async {
    for (final entry in counts.entries) {
      if (entry.value < 0) {
        throw ArgumentError.value(
          entry.value,
          'counts[${entry.key}]',
          'Like counts cannot be negative.',
        );
      }
    }
    final sortedCounts = Map.fromEntries(
      counts.entries.toList()..sort((first, second) => first.key.compareTo(second.key)),
    );
    await (await _preferences).setString(
      _videoLikeCountsKey,
      jsonEncode(sortedCounts),
    );
  }
}
