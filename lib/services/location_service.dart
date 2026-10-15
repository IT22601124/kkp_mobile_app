import 'dart:math';
import 'package:flutter/foundation.dart';

class LocationService {
  static final LocationService _instance = LocationService._internal();
  factory LocationService() => _instance;
  LocationService._internal();

  double? _userLatitude;
  double? _userLongitude;

  double? get userLatitude => _userLatitude;
  double? get userLongitude => _userLongitude;

  static const double defaultReachedThresholdMeters = 200.0;

  /// Updates the user's current GPS location coordinates.
  void updateUserLocation(double latitude, double longitude) {
    _userLatitude = latitude;
    _userLongitude = longitude;
    debugPrint('LocationService updated user GPS: $latitude, $longitude');
  }

  /// Calculates distance in meters between two lat/lng points using Haversine formula.
  static double calculateDistanceMeters(
    double lat1,
    double lon1,
    double lat2,
    double lon2,
  ) {
    if (lat1 == 0.0 || lon1 == 0.0 || lat2 == 0.0 || lon2 == 0.0) {
      return 999999.0; // Unknown or unconfigured location
    }

    const p = 0.017453292519943295; // Math.PI / 180
    const c = cos;
    final a = 0.5 -
        c((lat2 - lat1) * p) / 2 +
        c(lat1 * p) * c(lat2 * p) * (1 - c((lon2 - lon1) * p)) / 2;
    return 12742000 * asin(sqrt(a)); // 2 * R * 1000 meters
  }

  /// Checks if the shop location is reached based on current position or given coordinates.
  bool isShopReached(
    double shopLat,
    double shopLng, {
    double? currentLat,
    double? currentLng,
    double thresholdMeters = defaultReachedThresholdMeters,
  }) {
    final lat = currentLat ?? _userLatitude;
    final lng = currentLng ?? _userLongitude;

    if (lat == null || lng == null || shopLat == 0.0 || shopLng == 0.0) {
      return false;
    }
    final distance = calculateDistanceMeters(lat, lng, shopLat, shopLng);
    return distance <= thresholdMeters;
  }

  /// Returns calculated distance in meters from user position to shop.
  double getDistanceToShopMeters(
    double shopLat,
    double shopLng, {
    double? currentLat,
    double? currentLng,
  }) {
    final lat = currentLat ?? _userLatitude;
    final lng = currentLng ?? _userLongitude;

    if (lat == null || lng == null) return 999999.0;
    return calculateDistanceMeters(lat, lng, shopLat, shopLng);
  }

  /// Formats distance in meters into user-friendly display string.
  static String formatDistance(double distanceMeters) {
    if (distanceMeters >= 999000.0) {
      return 'Location N/A';
    }
    if (distanceMeters < 1000) {
      return '${distanceMeters.toStringAsFixed(0)} m away';
    }
    return '${(distanceMeters / 1000).toStringAsFixed(1)} km away';
  }
}
