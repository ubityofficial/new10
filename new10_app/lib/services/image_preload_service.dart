import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:io';

/// Service to preload all images at app startup
class ImagePreloadService {
  static const String baseUrl = 'https://new10-yk1r.onrender.com/api';

  /// Preload all service images and banner on app startup
  static Future<void> preloadAllImages() async {
    print('🚀 Starting aggressive image preload on app startup...');
    
    try {
      // 1. Preload services first (includes images)
      await _preloadServices();
      
      // 2. Preload banner image
      await _preloadBannerImage();
      
      // 3. Preload promotions
      await _preloadPromotions();
      
      print('✅ ALL IMAGES PRELOADED SUCCESSFULLY AT STARTUP');
    } catch (e) {
      print('⚠️ Preload error: $e');
    }
  }

  /// Preload all service images
  static Future<void> _preloadServices() async {
    try {
      final url = '$baseUrl/services';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final List<dynamic> services = json.decode(response.body);
        print('📥 Preloading ${services.length} services with images...');
        
        // Preload image1 and image2 for each service in parallel
        final futures = <Future>[];
        for (var service in services) {
          final image1 = service['image1'];
          final image2 = service['image2'];
          
          if (image1 != null) {
            futures.add(_cacheImage(image1, 'image1'));
          }
          if (image2 != null) {
            futures.add(_cacheImage(image2, 'image2'));
          }
        }
        
        await Future.wait(futures, eagerError: false);
        print('✅ All ${services.length} services preloaded');
      }
    } catch (e) {
      print('⚠️ Services preload error: $e');
    }
  }

  /// Preload banner image
  static Future<void> _preloadBannerImage() async {
    try {
      final url = '$baseUrl/settings';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final bannerUrl = data['bannerImageUrl'];
        
        if (bannerUrl != null && bannerUrl.isNotEmpty) {
          print('📥 Preloading banner image...');
          await _cacheImage(bannerUrl, 'banner');
          print('✅ Banner image preloaded');
        }
      }
    } catch (e) {
      print('⚠️ Banner preload error: $e');
    }
  }

  /// Preload promotions (banner + offer)
  static Future<void> _preloadPromotions() async {
    try {
      final url = '$baseUrl/promotions';
      final response = await http.get(
        Uri.parse(url),
        headers: {'Content-Type': 'application/json'},
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final bannerData = data['banner'];
        
        if (bannerData != null && bannerData['url'] != null) {
          print('📥 Preloading promotions banner...');
          await _cacheImage(bannerData['url'], 'promo-banner');
          print('✅ Promotions banner preloaded');
        }
      }
    } catch (e) {
      print('⚠️ Promotions preload error: $e');
    }
  }

  /// Cache a single image by URL
  static Future<void> _cacheImage(String imageUrl, String label) async {
    try {
      final uri = Uri.parse(imageUrl);
      final request = http.Request('GET', uri);
      
      final streamResponse = await request.send().timeout(const Duration(seconds: 15));
      
      if (streamResponse.statusCode == 200) {
        print('  ✓ Cached $label: ${imageUrl.substring(0, 50)}...');
      } else {
        print('  ✗ Failed to cache $label (${streamResponse.statusCode})');
      }
    } catch (e) {
      print('  ⚠️ Cache error for $label: $e');
    }
  }
}
