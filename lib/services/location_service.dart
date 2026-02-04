import 'dart:math' as math;
import 'package:geolocator/geolocator.dart';
import 'package:ezan_asistani/utils/logger.dart';

class LocationService {
  // Konum izinlerini kontrol et ve iste
  Future<bool> checkAndRequestPermission() async {
    bool serviceEnabled;
    LocationPermission permission;

    // Konum servisi aktif mi kontrol et
    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      AppLogger.warning('Konum servisi kapalı');
      return false;
    }

    // İzin durumunu kontrol et
    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        AppLogger.warning('Konum izni reddedildi');
        return false;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      AppLogger.warning('Konum izni kalıcı olarak reddedildi');
      return false;
    }

    return true;
  }

  // Mevcut konumu al
  Future<Position?> getCurrentLocation() async {
    try {
      bool hasPermission = await checkAndRequestPermission();
      if (!hasPermission) {
        return null;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      return position;
    } catch (e) {
      AppLogger.error('Konum alınamadı', error: e);
      return null;
    }
  }

  // Kıble yönünü hesapla (Kabe koordinatları: 21.4225, 39.8262)
  double calculateQiblaDirection(double latitude, double longitude) {
    const double kaabaLat = 21.4225;
    const double kaabaLon = 39.8262;

    // Radyan cinsine çevir
    double lat1 = latitude * math.pi / 180.0;
    double lon1 = longitude * math.pi / 180.0;
    double lat2 = kaabaLat * math.pi / 180.0;
    double lon2 = kaabaLon * math.pi / 180.0;

    double dLon = lon2 - lon1;

    double y = math.sin(dLon) * math.cos(lat2);
    double x = math.cos(lat1) * math.sin(lat2) -
        math.sin(lat1) * math.cos(lat2) * math.cos(dLon);

    double bearing = math.atan2(y, x);
    bearing = bearing * 180.0 / math.pi;
    bearing = (bearing + 360) % 360;

    return bearing;
  }
}
