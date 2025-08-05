import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class FavoritesProvider with ChangeNotifier {
  List<Map<String, String>> _favorites = [];

  List<Map<String, String>> get favorites => _favorites;

  FavoritesProvider() {
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFavorites = prefs.getStringList('favorites') ?? [];
    _favorites = savedFavorites
        .map((item) => Map<String, String>.from(_decodeMap(item)))
        .toList();
    notifyListeners();
  }

  Future<void> _saveFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final savedFavorites = _favorites.map((item) => _encodeMap(item)).toList();
    prefs.setStringList('favorites', savedFavorites);
  }

  void addFavorite(Map<String, String> linha) {
    _favorites.add(linha);
    _saveFavorites();
    notifyListeners();
  }

  void removeFavorite(String numero) {
    _favorites.removeWhere((item) => item['numero'] == numero);
    _saveFavorites();
    notifyListeners();
  }

  bool isFavorite(String numero) {
    return _favorites.any((item) => item['numero'] == numero);
  }

  Map<String, String> _decodeMap(String encoded) {
    return Map<String, String>.from(Uri.splitQueryString(encoded));
  }

  String _encodeMap(Map<String, String> map) {
    return Uri(queryParameters: map).query;
  }
}