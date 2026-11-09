import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:cinemapedia/domain/datasources/favorites_datasource.dart';
import 'package:cinemapedia/domain/entities/movie.dart';
import 'package:cinemapedia/infrastructure/mappers/movie_storage_mapper.dart';

/// Guarda los favoritos como JSON en SharedPreferences (dependencia que el
/// proyecto ya tenía), así se conservan al cerrar la app y funcionan sin red.
class SharedPrefsFavoritesDatasource extends FavoritesDatasource {
  static const storageKey = 'cinemapedia.favorites';

  final SharedPreferences prefs;

  SharedPrefsFavoritesDatasource(this.prefs);

  @override
  List<Movie> loadFavorites() {
    final raw = prefs.getString(storageKey);
    if (raw == null || raw.isEmpty) return [];
    try {
      final list = jsonDecode(raw) as List;
      return list
          .map((item) => MovieStorageMapper.fromJson(Map<String, dynamic>.from(item)))
          .toList();
    } catch (error) {
      // Datos dañados: se ignoran en lugar de bloquear la app.
      debugPrint('SharedPrefsFavoritesDatasource: $error');
      return [];
    }
  }

  @override
  Future<void> saveFavorites(List<Movie> movies) async {
    final raw = jsonEncode(movies.map(MovieStorageMapper.toJson).toList());
    await prefs.setString(storageKey, raw);
  }
}
