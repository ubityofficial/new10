// Data Cache Service - Enables instant loading with background refresh
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

class CacheService {
  static const String SERVICES_CACHE_KEY = 'rapido_services_cache';
  static const String PROMOTIONS_CACHE_KEY = 'rapido_promotions_cache';
  static const String BANNER_CACHE_KEY = 'rapido_banner_cache';
  static const String SETTINGS_CACHE_KEY = 'rapido_settings_cache';
  
  static const int CACHE_EXPIRY_HOURS = 6; // Cache expires after 6 hours

  // Cache timestamp keys
  static const String SERVICES_TIMESTAMP_KEY = 'rapido_services_timestamp';
  static const String PROMOTIONS_TIMESTAMP_KEY = 'rapido_promotions_timestamp';
  static const String BANNER_TIMESTAMP_KEY = 'rapido_banner_timestamp';
  static const String SETTINGS_TIMESTAMP_KEY = 'rapido_settings_timestamp';

  // Get cached services data
  static Future<List<dynamic>?> getCachedServices() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(SERVICES_CACHE_KEY);
      
      if (cachedData != null) {
        print('✅ Loaded services from cache');
        return jsonDecode(cachedData) as List<dynamic>;
      }
      return null;
    } catch (e) {
      print('❌ Error reading services cache: $e');
      return null;
    }
  }

  // Save services data to cache
  static Future<void> setCachedServices(List<dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(SERVICES_CACHE_KEY, jsonEncode(data));
      await prefs.setInt(SERVICES_TIMESTAMP_KEY, DateTime.now().millisecondsSinceEpoch);
      print('✅ Cached services (${data.length} items)');
    } catch (e) {
      print('❌ Error caching services: $e');
    }
  }

  // Get cached promotions data
  static Future<Map<String, dynamic>?> getCachedPromotions() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(PROMOTIONS_CACHE_KEY);
      
      if (cachedData != null) {
        print('✅ Loaded promotions from cache');
        return jsonDecode(cachedData) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('❌ Error reading promotions cache: $e');
      return null;
    }
  }

  // Save promotions data to cache
  static Future<void> setCachedPromotions(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(PROMOTIONS_CACHE_KEY, jsonEncode(data));
      await prefs.setInt(PROMOTIONS_TIMESTAMP_KEY, DateTime.now().millisecondsSinceEpoch);
      print('✅ Cached promotions');
    } catch (e) {
      print('❌ Error caching promotions: $e');
    }
  }

  // Get cached banner data
  static Future<Map<String, dynamic>?> getCachedBanner() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(BANNER_CACHE_KEY);
      
      if (cachedData != null) {
        print('✅ Loaded banner from cache');
        return jsonDecode(cachedData) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('❌ Error reading banner cache: $e');
      return null;
    }
  }

  // Save banner data to cache
  static Future<void> setCachedBanner(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(BANNER_CACHE_KEY, jsonEncode(data));
      await prefs.setInt(BANNER_TIMESTAMP_KEY, DateTime.now().millisecondsSinceEpoch);
      print('✅ Cached banner');
    } catch (e) {
      print('❌ Error caching banner: $e');
    }
  }

  // Get cached settings data
  static Future<Map<String, dynamic>?> getCachedSettings() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedData = prefs.getString(SETTINGS_CACHE_KEY);
      
      if (cachedData != null) {
        print('✅ Loaded settings from cache');
        return jsonDecode(cachedData) as Map<String, dynamic>;
      }
      return null;
    } catch (e) {
      print('❌ Error reading settings cache: $e');
      return null;
    }
  }

  // Save settings data to cache
  static Future<void> setCachedSettings(Map<String, dynamic> data) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(SETTINGS_CACHE_KEY, jsonEncode(data));
      await prefs.setInt(SETTINGS_TIMESTAMP_KEY, DateTime.now().millisecondsSinceEpoch);
      print('✅ Cached settings');
    } catch (e) {
      print('❌ Error caching settings: $e');
    }
  }

  // Check if cache is still fresh (not expired)
  static Future<bool> isCacheFresh(String timestampKey) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final timestamp = prefs.getInt(timestampKey);
      
      if (timestamp == null) return false;
      
      final cacheTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
      final now = DateTime.now();
      final difference = now.difference(cacheTime).inHours;
      
      return difference < CACHE_EXPIRY_HOURS;
    } catch (e) {
      return false;
    }
  }

  // Clear all cache
  static Future<void> clearAllCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(SERVICES_CACHE_KEY);
      await prefs.remove(PROMOTIONS_CACHE_KEY);
      await prefs.remove(BANNER_CACHE_KEY);
      await prefs.remove(SETTINGS_CACHE_KEY);
      await prefs.remove(SERVICES_TIMESTAMP_KEY);
      await prefs.remove(PROMOTIONS_TIMESTAMP_KEY);
      await prefs.remove(BANNER_TIMESTAMP_KEY);
      await prefs.remove(SETTINGS_TIMESTAMP_KEY);
      print('✅ Cleared all cache');
    } catch (e) {
      print('❌ Error clearing cache: $e');
    }
  }

  // Clear specific cache
  static Future<void> clearServiceCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(SERVICES_CACHE_KEY);
      await prefs.remove(SERVICES_TIMESTAMP_KEY);
      print('✅ Cleared services cache');
    } catch (e) {
      print('❌ Error clearing services cache: $e');
    }
  }
}
