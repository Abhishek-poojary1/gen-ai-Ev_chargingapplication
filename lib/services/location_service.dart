import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationService {
  static Future<bool> requestLocationPermission() async {
    final status = await Permission.location.request();
    return status.isGranted;
  }

  static Future<bool> isLocationServiceEnabled() async {
    return await Geolocator.isLocationServiceEnabled();
  }

  static Future<Position?> getCurrentPosition() async {
    try {
      bool serviceEnabled = await isLocationServiceEnabled();
      if (!serviceEnabled) {
        return null;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          return null;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        return null;
      }

      return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 10),
      );
    } catch (e) {
      return null;
    }
  }

  static Stream<Position> getPositionStream() {
    return Geolocator.getPositionStream(
      locationSettings: const LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10, // Update every 10 meters
      ),
    );
  }

  static double calculateDistance(LatLng point1, LatLng point2) {
    return Geolocator.distanceBetween(
      point1.latitude,
      point1.longitude,
      point2.latitude,
      point2.longitude,
    );
  }

  static String formatDistance(double distanceInMeters) {
    if (distanceInMeters < 1000) {
      return '${distanceInMeters.round()} m';
    } else {
      final km = distanceInMeters / 1000;
      return '${km.toStringAsFixed(1)} km';
    }
  }

  static Future<List<LatLng>> getNearbyChargingPoints(
    LatLng userLocation,
    List<LatLng> allPoints,
    double radiusKm,
  ) async {
    final List<LatLng> nearbyPoints = [];
    final radiusInMeters = radiusKm * 1000;

    for (final point in allPoints) {
      final distance = calculateDistance(userLocation, point);
      if (distance <= radiusInMeters) {
        nearbyPoints.add(point);
      }
    }

    // Sort by distance
    nearbyPoints.sort((a, b) {
      final distanceA = calculateDistance(userLocation, a);
      final distanceB = calculateDistance(userLocation, b);
      return distanceA.compareTo(distanceB);
    });

    return nearbyPoints;
  }

  static Future<LatLng?> getDefaultLocation() async {
    // Return Delhi coordinates as default
    return const LatLng(28.6139, 77.2090);
  }
}
