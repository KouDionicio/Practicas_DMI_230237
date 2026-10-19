import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:toktik/domain/repositories/app_preferences_repository.dart';

class SharedPreferencesRepository implements AppPreferencesRepository {
  static const _seasonModeKey = 'season_mode';
  static const _manualSeasonKey = 'manual_season';
  static const _likedVideoIdsKey = 'liked_video_ids';
  static const _videoLikeCountsKey = 'video_like_counts';
  static const _likedExternalVideosKey = 'liked_external_videos';
  static const _mutedVideosKey = 'videos_muted';
  static const _discoverSeenIdsKey = 'discover_seen_ids';
  static const _unembeddableYouTubeIdsKey = 'unembeddable_youtube_ids';

  Future<SharedPreferences> get _preferences => SharedPreferences.getInstance();

  Future<bool> getVideosMuted() async =>
      (await _preferences).getBool(_mutedVideosKey) ?? true;

  Future<void> saveVideosMuted(bool muted) async =>
      (await _preferences).setBool(_mutedVideosKey, muted);

  Future<Set<String>> getDiscoverSeenIds() async =>
      (await _preferences).getStringList(_discoverSeenIdsKey)?.toSet() ?? {};

  Future<void> saveDiscoverSeenIds(Set<String> ids) async =>
      (await _preferences).setStringList(_discoverSeenIdsKey, ids.toList());

  Future<Set<String>> getUnembeddableYouTubeIds() async =>
      (await _preferences).getStringList(_unembeddableYouTubeIdsKey)?.toSet() ?? {};

  Future<void> saveUnembeddableYouTubeIds(Set<String> ids) async =>
      (await _preferences).setStringList(_unembeddableYouTubeIdsKey, ids.toList());

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
      counts.entries.toList()
        ..sort((first, second) => first.key.compareTo(second.key)),
    );
    await (await _preferences).setString(
      _videoLikeCountsKey,
      jsonEncode(sortedCounts),
    );
  }

  @override
  Future<Map<String, Map<String, Object?>>> getLikedExternalVideos() async {
    final raw = (await _preferences).getString(_likedExternalVideosKey);
    if (raw == null) return {};
    final decoded = jsonDecode(raw);
    if (decoded is! Map<String, dynamic>) {
      throw const FormatException('Saved external favorites are invalid.');
    }
    return {
      for (final entry in decoded.entries)
        if (entry.value is Map<String, dynamic>)
          entry.key: Map<String, Object?>.from(
            entry.value as Map<String, dynamic>,
          ),
    };
  }

  @override
  Future<void> saveLikedExternalVideos(
    Map<String, Map<String, Object?>> videos,
  ) async {
    final sorted = Map.fromEntries(
      videos.entries.toList()..sort((a, b) => a.key.compareTo(b.key)),
    );
    await (await _preferences).setString(
      _likedExternalVideosKey,
      jsonEncode(sorted),
    );
  }
}
