import 'package:geolocator/geolocator.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Konum servislerini (GPS, İzinler) yöneten sınıf
class LocationService {
  /// Kullanıcının konum izni durumunu kontrol et ve gerekirse iste
  Future<bool> checkPermissions() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Test if location services are enabled.
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return false;
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return false;
      }
    }
    
    if (permission == LocationPermission.deniedForever) {
      return false;
    }

    return true;
  }

  /// Mevcut konumu al
  Future<Position?> getCurrentLocation() async {
    final hasPermission = await checkPermissions();
    if (!hasPermission) return null;

    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );
  }

  /// Konum değişikliklerini izle (Stream)
  Stream<Position> get locationStream => Geolocator.getPositionStream(
    locationSettings: const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 10, // 10 metrede bir güncelle
    ),
  );
}

/// Provider Tanımları
final locationServiceProvider = Provider<LocationService>((ref) => LocationService());

/// Kullanıcının anlık konumunu takip eden StreamProvider
final userLocationProvider = StreamProvider<Position>((ref) {
  return ref.watch(locationServiceProvider).locationStream;
});
