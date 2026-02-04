import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ezan_asistani/utils/logger.dart';
import 'dart:math' as math;

class Mosque {
  final String name;
  final double latitude;
  final double longitude;
  final double distance; // km cinsinden
  final String? address;
  final String? phone;

  Mosque({
    required this.name,
    required this.latitude,
    required this.longitude,
    required this.distance,
    this.address,
    this.phone,
  });

  factory Mosque.fromJson(Map<String, dynamic> json, double userLat, double userLon) {
    double lat = json['lat'] is String ? double.parse(json['lat']) : json['lat'];
    double lon = json['lon'] is String ? double.parse(json['lon']) : json['lon'];
    
    double distance = _calculateDistance(userLat, userLon, lat, lon);
    
    return Mosque(
      name: json['name'] ?? 'Cami',
      latitude: lat,
      longitude: lon,
      distance: distance,
      address: json['address'],
      phone: json['phone'],
    );
  }

  static double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const double earthRadius = 6371; // km
    double dLat = _toRad(lat2 - lat1);
    double dLon = _toRad(lon2 - lon1);
    
    double a = math.sin(dLat / 2) * math.sin(dLat / 2) +
        math.cos(_toRad(lat1)) * math.cos(_toRad(lat2)) *
        math.sin(dLon / 2) * math.sin(dLon / 2);
    
    double c = 2 * math.atan2(math.sqrt(a), math.sqrt(1 - a));
    return earthRadius * c;
  }

  static double _toRad(double deg) {
    return deg * (math.pi / 180);
  }
}

class MosqueFinderService {
  static const String _nominatimBaseUrl = 'https://nominatim.openstreetmap.org';
  static const String _overpassBaseUrl = 'https://overpass-api.de/api/interpreter';

  // Overpass API kullanarak yakındaki camileri bul
  Future<List<Mosque>> findNearbyMosques(
    double latitude,
    double longitude, {
    double radiusKm = 5.0,
  }) async {
    try {
      AppLogger.info('Yakındaki camileri aranıyor: Lat=$latitude, Lon=$longitude, Radius=${radiusKm}km');
      
      // Bbox hesapla (latitude/longitude farkı)
      double latDelta = radiusKm / 111.0;
      double lonDelta = radiusKm / (111.0 * math.cos(latitude * math.pi / 180.0));
      
      double south = latitude - latDelta;
      double west = longitude - lonDelta;
      double north = latitude + latDelta;
      double east = longitude + lonDelta;
      
      // Overpass API sorgusu - camileri bul (bbox: south, west, north, east)
      final query = '''[out:json];
(
  node["amenity"="place_of_worship"]["religion"="islam"](${south},${west},${north},${east});
  way["amenity"="place_of_worship"]["religion"="islam"](${south},${west},${north},${east});
  node["building"="mosque"](${south},${west},${north},${east});
  way["building"="mosque"](${south},${west},${north},${east});
  relation["amenity"="place_of_worship"]["religion"="islam"](${south},${west},${north},${east});
  relation["building"="mosque"](${south},${west},${north},${east});
);
out center;
      ''';

      final response = await http.post(
        Uri.parse(_overpassBaseUrl),
        body: query,
      ).timeout(const Duration(seconds: 20));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        List<Mosque> mosques = [];

        if (data['elements'] != null) {
          for (var element in data['elements']) {
            double? lat;
            double? lon;

            // Koordinatları al (center veya direct)
            if (element['center'] != null) {
              lat = element['center']['lat'];
              lon = element['center']['lon'];
            } else if (element['lat'] != null && element['lon'] != null) {
              lat = element['lat'];
              lon = element['lon'];
            }

            if (lat != null && lon != null) {
              String name = element['tags']?['name'] ?? 'Cami';
              
              // Adres bilgisini al
              String? address = element['tags']?['addr:full'] ??
                  element['tags']?['addr:street'];
              
              String? phone = element['tags']?['phone'];

              double distance = Mosque._calculateDistance(latitude, longitude, lat, lon);

              // Sadece 5km içindeki camileri ekle
              if (distance <= radiusKm) {
                mosques.add(Mosque(
                  name: name,
                  latitude: lat,
                  longitude: lon,
                  distance: distance,
                  address: address,
                  phone: phone,
                ));
              }
            }
          }
        }

        // Mesafeye göre sırala
        mosques.sort((a, b) => a.distance.compareTo(b.distance));
        
        AppLogger.success('${mosques.length} cami bulundu');
        return mosques;
      } else {
        AppLogger.error('Overpass API hatası', error: 'Status: ${response.statusCode}');
        return [];
      }
    } catch (e) {
      AppLogger.error('Cami arama hatası', error: e);
      return [];
    }
  }

  // Nominatim API kullanarak alternatif arama (yedek)
  Future<List<Mosque>> findMosquesByNominatim(
    double latitude,
    double longitude, {
    double radiusKm = 5.0,
  }) async {
    try {
      AppLogger.info('Nominatim ile cami aranıyor');
      
      // Türkçe arama terimleri
      final searchTerms = ['cami', 'mosque', 'mescit', 'camii'];
      List<Mosque> allMosques = [];

      for (String term in searchTerms) {
        try {
          final response = await http.get(
            Uri.parse(
              '$_nominatimBaseUrl/search?q=$term&format=json&lat=$latitude&lon=$longitude&limit=100&viewbox=${longitude - 0.1},${latitude - 0.1},${longitude + 0.1},${latitude + 0.1}&bounded=1',
            ),
            headers: {'User-Agent': 'EzanAsistani/1.0'},
          ).timeout(const Duration(seconds: 10));

          if (response.statusCode == 200) {
            final List<dynamic> data = json.decode(response.body);

            for (var item in data) {
              try {
                double lat = double.parse(item['lat'].toString());
                double lon = double.parse(item['lon'].toString());
                double distance = Mosque._calculateDistance(latitude, longitude, lat, lon);

                if (distance <= radiusKm) {
                  String displayName = item['display_name'] ?? 'Cami';
                  // Kısaltılmış ad al
                  String shortName = item['name'] ?? displayName;
                  
                  allMosques.add(Mosque(
                    name: shortName,
                    latitude: lat,
                    longitude: lon,
                    distance: distance,
                    address: displayName,
                  ));
                }
              } catch (e) {
                AppLogger.warning('Nominatim öğesi işlenirken hata', error: e);
                continue;
              }
            }
          }
        } catch (e) {
          AppLogger.warning('$term araması başarısız', error: e);
          continue;
        }
      }

      // Duplikatları kaldır (aynı koordinatlar)
      Map<String, Mosque> uniqueMosques = {};
      for (var mosque in allMosques) {
        String key = '${mosque.latitude.toStringAsFixed(4)}_${mosque.longitude.toStringAsFixed(4)}';
        if (!uniqueMosques.containsKey(key)) {
          uniqueMosques[key] = mosque;
        }
      }

      List<Mosque> result = uniqueMosques.values.toList();
      result.sort((a, b) => a.distance.compareTo(b.distance));
      AppLogger.success('${result.length} cami bulundu (Nominatim)');
      return result;
    } catch (e) {
      AppLogger.error('Nominatim arama hatası', error: e);
      return [];
    }
  }
}
