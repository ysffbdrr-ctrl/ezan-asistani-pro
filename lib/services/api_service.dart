import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:ezan_asistani/utils/performance_utils.dart';
import 'package:ezan_asistani/utils/logger.dart';

class ApiService {
  static const String baseUrl = 'https://api.aladhan.com/v1';
  
  // Cache - API çağrılarını azaltır
  final _cache = CacheManager<Map<String, dynamic>>(
    expiry: const Duration(hours: 12), // 12 saat cache
  );

  final _calendarCache = CacheManager<List<dynamic>>(
    expiry: const Duration(hours: 24),
  );

  // Şehre göre ezan vakitlerini getir
  Future<Map<String, dynamic>?> getPrayerTimesByCity(
      String city, String country) async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/timingsByCity?city=$city&country=$country'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        AppLogger.error('API Hatası', error: 'Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      AppLogger.error('Bağlantı hatası', error: e);
      return null;
    }
  }

  Future<List<dynamic>?> getPrayerCalendarByCoordinates(
      double latitude,
      double longitude, {
        required int month,
        required int year,
      }) async {
    final cacheKey = 'calendar_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}_${month}_$year';
    final cached = _calendarCache.get(cacheKey);
    if (cached != null) {
      AppLogger.info('Takvim cache\'den yüklendi', tag: 'API');
      return cached;
    }

    try {
      final response = await http.get(
        Uri.parse(
          '$baseUrl/calendar?latitude=$latitude&longitude=$longitude&method=13&month=$month&year=$year',
        ),
      ).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = (data['data'] as List<dynamic>?) ?? <dynamic>[];
        _calendarCache.set(cacheKey, result);
        AppLogger.success('Takvim API\'den yüklendi ve cache\'lendi');
        return result;
      } else {
        AppLogger.error('Takvim API hatası', error: 'Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      AppLogger.error('Takvim bağlantı hatası', error: e);
      return null;
    }
  }

  // Koordinatlara göre ezan vakitlerini getir (Cache'li)
  Future<Map<String, dynamic>?> getPrayerTimesByCoordinates(
      double latitude, double longitude) async {
    // Cache key oluştur
    final cacheKey = 'prayer_${latitude.toStringAsFixed(2)}_${longitude.toStringAsFixed(2)}';
    
    // Cache'de var mı kontrol et
    final cached = _cache.get(cacheKey);
    if (cached != null) {
      AppLogger.info('Cache\'den yüklendi', tag: 'API');
      return cached;
    }
    
    try {
      // Method 13 = Diyanet İşleri Başkanlığı (Türkiye)
      final response = await http.get(
        Uri.parse(
            '$baseUrl/timings?latitude=$latitude&longitude=$longitude&method=13'),
      ).timeout(const Duration(seconds: 10)); // Timeout ekle

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final result = data['data'] as Map<String, dynamic>;
        
        // Cache'e kaydet
        _cache.set(cacheKey, result);
        AppLogger.success('API\'den yüklendi ve cache\'lendi');
        
        return result;
      } else {
        AppLogger.error('API Hatası', error: 'Status: ${response.statusCode}');
        return null;
      }
    } catch (e) {
      AppLogger.error('Bağlantı hatası', error: e);
      return null;
    }
  }

  // 40 günlük takvimi getir
  Future<List<Map<String, dynamic>>?> getPrayerCalendarFor40Days(
      double latitude, double longitude) async {
    final now = DateTime.now();
    final List<dynamic> allDays = [];

    // Mevcut ayı al
    final currentMonthData = await getPrayerCalendarByCoordinates(
      latitude,
      longitude,
      month: now.month,
      year: now.year,
    );
    if (currentMonthData != null) {
      allDays.addAll(currentMonthData);
    }

    // 40 gün sonrası bir sonraki aya taşıyor mu kontrol et
    final endDate = now.add(const Duration(days: 40));
    if (endDate.month != now.month) {
      // Bir sonraki ayın verilerini de al
      final nextMonthDate = DateTime(now.year, now.month + 1, 1);
      final nextMonthData = await getPrayerCalendarByCoordinates(
        latitude,
        longitude,
        month: nextMonthDate.month,
        year: nextMonthDate.year,
      );
      if (nextMonthData != null) {
        allDays.addAll(nextMonthData);
      }
    }

    if (allDays.isEmpty) {
      return null;
    }

    // Bugünden itibaren 40 günü filtrele
    final today = DateTime(now.year, now.month, now.day);

    final filteredData = allDays.where((dayData) {
      try {
        final dateStr = dayData['date']['gregorian']['date'] as String; // dd-MM-yyyy formatında
        final dateParts = dateStr.split('-');
        final date = DateTime(int.parse(dateParts[2]), int.parse(dateParts[1]), int.parse(dateParts[0]));
        return !date.isBefore(today);
      } catch (e) {
        AppLogger.warning('Takvim tarihi parse edilemedi: $e');
        return false;
      }
    }).toList();

    // Sadece 40 gün al
    if (filteredData.length > 40) {
      return filteredData.sublist(0, 40).cast<Map<String, dynamic>>();
    }

    return filteredData.cast<Map<String, dynamic>>();
  }

  // Hicri takvim bilgisini getir
  Future<Map<String, dynamic>?> getHijriCalendar() async {
    try {
      final response = await http.get(
        Uri.parse('$baseUrl/gToH'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        return data['data'];
      } else {
        AppLogger.error('Hicri takvim API hatası');
        return null;
      }
    } catch (e) {
      AppLogger.error('Hicri takvim hatası', error: e);
      return null;
    }
  }
}
