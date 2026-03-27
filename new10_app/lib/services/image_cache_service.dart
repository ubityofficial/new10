import 'package:flutter/material.dart';
import 'package:flutter_cache_manager/flutter_cache_manager.dart';

class ImageCacheService {
  static final ImageCacheService _instance = ImageCacheService._internal();
  late CacheManager cacheManager;

  factory ImageCacheService() {
    return _instance;
  }

  ImageCacheService._internal() {
    cacheManager = CacheManager(
      Config(
        'rapido_image_cache',
        stalePeriod: const Duration(days: 30),
        maxNrOfCacheObjects: 100,
      ),
    );
  }

  // Get cached image with fallback
  Future<ImageProvider> getCachedImage(String imageUrl) async {
    try {
      final file = await cacheManager.getSingleFile(imageUrl);
      return FileImage(file);
    } catch (e) {
      // Return network image as fallback
      return NetworkImage(imageUrl);
    }
  }

  // Preload image to cache
  Future<void> preloadImage(String imageUrl) async {
    try {
      await cacheManager.getSingleFile(imageUrl);
    } catch (e) {
      // Silently fail
    }
  }

  // Clear cache
  Future<void> clearCache() async {
    await cacheManager.emptyCache();
  }
}
