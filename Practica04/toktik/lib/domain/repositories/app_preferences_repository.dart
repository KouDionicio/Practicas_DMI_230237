abstract class AppPreferencesRepository {
  Future<String?> getSeasonMode();
  Future<String?> getManualSeason();
  Future<void> saveSeasonMode(String mode);
  Future<void> saveManualSeason(String season);
  Future<Set<String>> getLikedVideoIds();
  Future<void> saveLikedVideoIds(Set<String> ids);
  Future<Map<String, int>> getVideoLikeCounts();
  Future<void> saveVideoLikeCounts(Map<String, int> counts);
  Future<Map<String, Map<String, Object?>>> getLikedExternalVideos();
  Future<void> saveLikedExternalVideos(
    Map<String, Map<String, Object?>> videos,
  );
}
