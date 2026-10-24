import 'package:shared_preferences/shared_preferences.dart';

class FavoritesService {
  static const String _keyFavorites = 'favorite_channel_ids';
  static const String _keyCustomM3uUrl = 'custom_m3u_url';

  static Future<List<String>> getFavoriteIds() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_keyFavorites) ?? [];
  }

  static Future<bool> isFavorite(String channelId) async {
    final favorites = await getFavoriteIds();
    return favorites.contains(channelId);
  }

  static Future<void> toggleFavorite(String channelId) async {
    final prefs = await SharedPreferences.getInstance();
    final favorites = prefs.getStringList(_keyFavorites) ?? [];
    if (favorites.contains(channelId)) {
      favorites.remove(channelId);
    } else {
      favorites.add(channelId);
    }
    await prefs.setStringList(_keyFavorites, favorites);
  }

  static Future<String?> getCustomM3uUrl() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(_keyCustomM3uUrl);
  }

  static Future<void> saveCustomM3uUrl(String url) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_keyCustomM3uUrl, url);
  }
}
