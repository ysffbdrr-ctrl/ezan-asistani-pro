import 'dart:async';
import 'dart:convert';

import 'package:ezan_asistani/l10n/app_localizations.dart';
import 'package:ezan_asistani/services/alarm_service.dart';
import 'package:ezan_asistani/services/api_service.dart';
import 'package:ezan_asistani/services/ayarlar_service.dart';
import 'package:ezan_asistani/services/location_service.dart';
import 'package:ezan_asistani/services/notification_service.dart';
import 'package:ezan_asistani/services/prayer_time_cache_service.dart';
import 'package:ezan_asistani/services/widget_service.dart';
import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:ezan_asistani/utils/logger.dart';
import 'package:ezan_asistani/widgets/admob_banner.dart';
import 'package:ezan_asistani/widgets/prayer_card.dart';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EzanVakitleri extends StatefulWidget {
  const EzanVakitleri({Key? key}) : super(key: key);

  @override
  State<EzanVakitleri> createState() => _EzanVakitleriState();
}

class PrayerScheduleDay {
  PrayerScheduleDay({
    required this.date,
    required this.fajr,
    required this.sunrise,
    required this.dhuhr,
    required this.asr,
    required this.maghrib,
    required this.isha,
  });

  final DateTime date;
  final String fajr;
  final String sunrise;
  final String dhuhr;
  final String asr;
  final String maghrib;
  final String isha;

  String getTimeForPrayer(String key) {
    switch (key) {
      case 'Fajr':
        return fajr;
      case 'Sunrise':
        return sunrise;
      case 'Dhuhr':
        return dhuhr;
      case 'Asr':
        return asr;
      case 'Maghrib':
        return maghrib;
      case 'Isha':
        return isha;
      default:
        return '';
    }
  }
}

class _EzanVakitleriState extends State<EzanVakitleri> with WidgetsBindingObserver {
  final ApiService _apiService = ApiService();
  final LocationService _locationService = LocationService();
  final NotificationService _notificationService = NotificationService();
  final PrayerTimeCacheService _cacheService = PrayerTimeCacheService();
  final AlarmService _alarmService = AlarmService();
  final AyarlarService _ayarlarService = AyarlarService();

  static const _lastLocationNameKey = 'last_location_name';
  static const _lastLocationLatKey = 'last_location_lat';
  static const _lastLocationLonKey = 'last_location_lon';
  static const _lastLocationUpdatedAtKey = 'last_location_updated_at';

  static const Duration _locationRefreshInterval = Duration(hours: 6);
  static const double _locationChangeThresholdMeters = 2000; // ~ilçe değişimi için kaba eşik

  Map<String, String>? prayerTimes;
  List<PrayerScheduleDay> _scheduleFor40Days = [];
  Position? _lastPosition;
  String? cityName;
  bool isLoading = true;
  String? errorMessage;
  String? nextPrayer;
  bool _use12HourFormat = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _initializeAndLoad();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      () async {
        try {
          final newValue = await _ayarlarService.use12HourFormat;
          if (mounted) {
            setState(() {
              _use12HourFormat = newValue;
            });
          }
        } catch (_) {
          // sessiz
        }
      }();
      _loadPrayerTimes(forceRefresh: false);
    }
  }

  Future<void> _initializeAndLoad() async {
    try {
      final initialized = await _notificationService.initialize();
      if (initialized) {
        print('Bildirim servisi başarıyla başlatıldı');
        _setupNotificationHandler();
      } else {
        print('Bildirim servisi başlatılamadı');
      }
    } catch (e) {
      print('Bildirim servisi başlatma hatası: $e');
    }
    try {
      _use12HourFormat = await _ayarlarService.use12HourFormat;
    } catch (_) {
      _use12HourFormat = false;
    }
    await _loadPrayerTimes(forceRefresh: false);
  }

  void _setupNotificationHandler() {}

  String _normalizeTime(String raw) {
    final match = RegExp(r"(\d{1,2}):(\d{2})").firstMatch(raw);
    if (match != null) {
      final h = int.parse(match.group(1)!);
      final m = int.parse(match.group(2)!);
      return "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}";
    }
    if (raw.length >= 5) return raw.substring(0, 5);
    return raw;
  }

  String _addMinutes(String hhmm, int delta) {
    final parts = hhmm.split(':');
    final now = DateTime.now();
    final dt = DateTime(
      now.year,
      now.month,
      now.day,
      int.parse(parts[0]),
      int.parse(parts[1]),
    ).add(Duration(minutes: delta));
    return "${dt.hour.toString().padLeft(2, '0')}:${dt.minute.toString().padLeft(2, '0')}";
  }

  String _formatTimeForDisplay(String rawTime) {
    final normalized = _normalizeTime(rawTime);
    if (!_use12HourFormat) return normalized;

    final parts = normalized.split(':');
    if (parts.length < 2) return normalized;
    final now = DateTime.now();
    final dt = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
    final localeTag = Localizations.localeOf(context).toLanguageTag();
    return DateFormat('h:mm a', localeTag).format(dt);
  }

  Future<String> _resolveLocationNameForCache() async {
    try {
      final otomatikKonum = await _ayarlarService.otomatikKonum;
      if (!otomatikKonum) {
        final manuelSehir = await _ayarlarService.manuelSehir;
        if (manuelSehir != null && manuelSehir.trim().isNotEmpty) {
          return manuelSehir;
        }
      } else {
        final prefs = await SharedPreferences.getInstance();
        final cachedName = prefs.getString(_lastLocationNameKey);
        if (cachedName != null && cachedName.trim().isNotEmpty) {
          return cachedName;
        }
      }
    } catch (_) {
      return 'Cache';
    }
    return 'Cache';
  }

  Future<void> _maybeRefreshLocationNameInBackground() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final lastUpdatedIso = prefs.getString(_lastLocationUpdatedAtKey);
      if (lastUpdatedIso != null) {
        final lastUpdated = DateTime.tryParse(lastUpdatedIso);
        if (lastUpdated != null &&
            DateTime.now().difference(lastUpdated) < _locationRefreshInterval) {
          return;
        }
      }
      await _updateLocationName();
    } catch (_) {
      // sessiz
    }
  }

  Future<void> _loadPrayerTimes({bool forceRefresh = false}) async {
    final loc = AppLocalizations.of(context);
    if (mounted) {
      setState(() {
        isLoading = true;
        errorMessage = null;
      });
    }

    try {
      if (!forceRefresh) {
        final cachedData = await _cacheService.loadPrayerTimes();
        if (cachedData != null && cachedData.isNotEmpty) {
          AppLogger.info('40 günlük takvim cache\'den yüklendi');
          final cachedLocationName = await _resolveLocationNameForCache();
          _processAndSetPrayerData(cachedData, cachedLocationName);
          // Cache gösterirken GPS/Reverse-Geocode'u her girişte çalıştırma.
          // Sadece belirli aralıklarla arka planda güncelle.
          unawaited(_maybeRefreshLocationNameInBackground());
          return;
        }
      }

      final otomatikKonum = await _ayarlarService.otomatikKonum;
      double? latitude;
      double? longitude;
      Future<String> locationNameFuture =
          Future.value(loc.translate('location_unknown'));

      if (otomatikKonum) {
        final position = await _locationService.getCurrentLocation();
        if (position != null) {
          _lastPosition = position;
          latitude = position.latitude;
          longitude = position.longitude;
          locationNameFuture = _fetchCityName(position);
        } else {
          AppLogger.warning('GPS konumu alınamadı, manuel konum deneniyor');
        }
      }

      if (latitude == null || longitude == null) {
        final manuelLat = await _ayarlarService.manuelLat;
        final manuelLon = await _ayarlarService.manuelLon;
        final manuelSehir = await _ayarlarService.manuelSehir;

        if (manuelLat != null && manuelLon != null) {
          latitude = manuelLat;
          longitude = manuelLon;
          if (manuelSehir != null && manuelSehir.trim().isNotEmpty) {
            locationNameFuture = Future.value(manuelSehir);
          } else {
            locationNameFuture = _fetchCityNameByCoordinates(manuelLat, manuelLon);
          }
        }
      }

      if (latitude == null || longitude == null) {
        if (mounted) {
          setState(() {
            errorMessage = loc.translate('error_location_not_set');
            isLoading = false;
          });
        }
        return;
      }

      AppLogger.info('Konum kullanılacak: Lat=$latitude, Lon=$longitude');

      final calendarFuture =
          _apiService.getPrayerCalendarFor40Days(latitude, longitude);

      final calendarData = await calendarFuture;
      String locationName;
      try {
        locationName = await locationNameFuture;
      } catch (e) {
        AppLogger.warning('Şehir adı alınamadı', error: e);
        locationName = loc.translate('location_unknown');
      }

      if (calendarData != null && calendarData.isNotEmpty) {
        AppLogger.success('40 günlük takvim API\'den başarıyla çekildi');
        await _cacheService.savePrayerTimes(calendarData);
        _processAndSetPrayerData(calendarData, locationName);
      } else {
        final cachedData = await _cacheService.loadPrayerTimes();
        if (cachedData != null && cachedData.isNotEmpty) {
          AppLogger.warning('API hatası, eski cache verisi kullanılıyor');
          final cachedLocationName = await _resolveLocationNameForCache();
          _processAndSetPrayerData(cachedData, cachedLocationName);
        } else {
          if (mounted) {
            setState(() {
              errorMessage = loc.translate('error_loading_prayer_times');
              isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      final cachedData = await _cacheService.loadPrayerTimes();
      if (cachedData != null && cachedData.isNotEmpty) {
        AppLogger.error('Genel hata, eski cache verisi kullanılıyor', error: e);
        final cachedLocationName = await _resolveLocationNameForCache();
        _processAndSetPrayerData(cachedData, cachedLocationName);
      } else {
        if (mounted) {
          setState(() {
            errorMessage = loc.translate('error_generic', params: {'error': e.toString()});
            isLoading = false;
          });
        }
      }
    }
  }

  Future<String> _fetchCityName(Position position) async {
    return _fetchCityNameByCoordinates(position.latitude, position.longitude);
  }

  Future<String> _fetchCityNameByCoordinates(double latitude, double longitude) async {
    try {
      AppLogger.info('Şehir adı alınıyor: $latitude, $longitude');
      final languageCode = Localizations.localeOf(context).languageCode;
      final geoResponse = await http.get(
        Uri.parse(
            'https://nominatim.openstreetmap.org/reverse?format=json&lat=$latitude&lon=$longitude&accept-language=$languageCode'),
        headers: {'User-Agent': 'EzanAsistani/1.0'},
      ).timeout(const Duration(seconds: 5));
      
      if (geoResponse.statusCode == 200) {
        final geoData = json.decode(geoResponse.body);
        String cityName = geoData['address']?['city'] ?? 
                         geoData['address']?['town'] ?? 
                         geoData['address']?['province'] ?? 
                         geoData['address']?['state'] ?? 
                         'Bilinmiyor';

        try {
          final prefs = await SharedPreferences.getInstance();
          await prefs.setString(_lastLocationNameKey, cityName);
          await prefs.setDouble(_lastLocationLatKey, latitude);
          await prefs.setDouble(_lastLocationLonKey, longitude);
          await prefs.setString(
              _lastLocationUpdatedAtKey, DateTime.now().toIso8601String());
        } catch (_) {
          // sessiz
        }
        
        AppLogger.success('Şehir adı alındı: $cityName');
        return cityName;
      } else {
        AppLogger.warning('Geocoding API hatası: ${geoResponse.statusCode}');
      }
    } catch (e) {
      AppLogger.error('Reverse geocoding hatası: $e');
    }
    return 'Bilinmiyor';
  }

  void _processAndSetPrayerData(List<Map<String, dynamic>> calendarData, String locationName) {
    try {
      AppLogger.info('Ezan vakitleri işleniyor, konum: $locationName');
      final List<PrayerScheduleDay> parsedSchedule = [];
      
      for (final entry in calendarData) {
        try {
          final dateData = entry['date'] as Map<String, dynamic>?;
          final gregorian = dateData?['gregorian'] as Map<String, dynamic>?;
          final isoDate = gregorian?['date'] as String?;
          final timings = entry['timings'] as Map<String, dynamic>?;
          if (timings == null || isoDate == null) continue;

          final date = DateFormat('dd-MM-yyyy').parse(isoDate);

          // Zaman formatlarını temizle - timezone bilgilerini kaldır
          String cleanTime(String time) {
            if (time.isEmpty) return '';
            return time.split(' ')[0]; // Sadece saat kısmını al
          }

          parsedSchedule.add(
            PrayerScheduleDay(
              date: date,
              fajr: cleanTime(timings['Fajr'] as String? ?? ''),
              sunrise: cleanTime(timings['Sunrise'] as String? ?? ''),
              dhuhr: cleanTime(timings['Dhuhr'] as String? ?? ''),
              asr: cleanTime(timings['Asr'] as String? ?? ''),
              maghrib: cleanTime(timings['Maghrib'] as String? ?? ''),
              isha: cleanTime(timings['Isha'] as String? ?? ''),
            ),
          );
        } catch (e) {
          AppLogger.error('Takvim verisi işleme hatası: $e');
          continue;
        }
      }

      if (parsedSchedule.isEmpty) {
        AppLogger.warning('İşlenmiş takvim verisi boş');
        if (mounted) {
          setState(() {
            errorMessage = 'Ezan vakitleri verisi işlenemedi';
            isLoading = false;
          });
        }
        return;
      }

      final today = parsedSchedule.first;
      final times = <String, String>{
        'Fajr': today.fajr,
        'Sunrise': today.sunrise,
        'Dhuhr': today.dhuhr,
        'Asr': today.asr,
        'Maghrib': today.maghrib,
        'Isha': today.isha,
      };

      // Konum adını düzelt - "Cache" yerine gerçek şehir adını göster
      String displayLocation = locationName;
      if (locationName == 'Cache') {
        // Cache verisi kullanılıyorsa varsa son bilinen adı göster,
        // yoksa placeholder göster. Güncellemeyi arka planda yap.
        displayLocation = 'Konum alınıyor...';
        unawaited(_maybeRefreshLocationNameInBackground());
      }

      if (mounted) {
        setState(() {
          prayerTimes = times;
          _scheduleFor40Days = parsedSchedule;
          cityName = displayLocation;
          isLoading = false;
          errorMessage = null;
        });
      }

      final calculatedNextPrayer = _calculateNextPrayer(times);
      
      // Duplicate setState kaldır - sadece bir tane kalsın
      if (mounted) {
        setState(() {
          prayerTimes = times;
          _scheduleFor40Days = parsedSchedule;
          cityName = displayLocation;
          nextPrayer = calculatedNextPrayer;
          isLoading = false;
          errorMessage = null;
        });
      }

      Future.wait([
        _schedulePrayerNotifications(),
        _updateHomeWidget(times, calculatedNextPrayer),
      ]);
      
      AppLogger.success('Ezan vakitleri başarıyla işlendi, konum: $displayLocation');
    } catch (e) {
      AppLogger.error('Ezan vakitleri işleme genel hata: $e');
      if (mounted) {
        setState(() {
          errorMessage = 'Veriler işlenemedi: ${e.toString()}';
          isLoading = false;
        });
      }
    }
  }

  Future<void> _updateLocationName() async {
    try {
      Position? position = await _locationService.getCurrentLocation();
      if (position != null) {
        final prefs = await SharedPreferences.getInstance();
        final lastLat = prefs.getDouble(_lastLocationLatKey);
        final lastLon = prefs.getDouble(_lastLocationLonKey);

        if (lastLat != null && lastLon != null) {
          final distance = Geolocator.distanceBetween(
            lastLat,
            lastLon,
            position.latitude,
            position.longitude,
          );
          if (distance < _locationChangeThresholdMeters) {
            // İlçe değişmemiş gibi; sadece timestamp'i güncelle ve çık
            await prefs.setString(
                _lastLocationUpdatedAtKey, DateTime.now().toIso8601String());
            return;
          }
        }

        String newCityName = await _fetchCityName(position);
        if (mounted && newCityName != 'Bilinmiyor') {
          setState(() {
            cityName = newCityName;
          });
          AppLogger.info('Konum adı güncellendi: $newCityName');
        }
      }
    } catch (e) {
      AppLogger.error('Konum adı güncelleme hatası: $e');
    }
  }

  Future<void> _schedulePrayerNotifications() async {
    if (prayerTimes == null) return;
    
    try {
      final now = DateTime.now();
      final today = DateTime(now.year, now.month, now.day);
      final loc = AppLocalizations.of(context);
      
      // Namaz vakitleri
      final prayers = [
        {'id': 1, 'name': loc.translate('prayer_fajr'), 'time': prayerTimes!['Fajr']!},
        {'id': 2, 'name': loc.translate('prayer_sunrise'), 'time': prayerTimes!['Sunrise']!},
        {'id': 3, 'name': loc.translate('prayer_dhuhr'), 'time': prayerTimes!['Dhuhr']!},
        {'id': 4, 'name': loc.translate('prayer_asr'), 'time': prayerTimes!['Asr']!},
        {'id': 5, 'name': loc.translate('prayer_maghrib'), 'time': prayerTimes!['Maghrib']!},
        {'id': 6, 'name': loc.translate('prayer_isha'), 'time': prayerTimes!['Isha']!},
      ];
      
      AppLogger.info('Toplam ${prayers.length} namaz alarmı planlanacak');
      
      final prefs = await SharedPreferences.getInstance();
      final notificationsEnabled = prefs.getBool('bildirimler_aktif') ?? true;
      final notificationMinutes = prefs.getInt('bildirim_suresi') ?? 10;

      if (!notificationsEnabled) {
        AppLogger.info('Bildirimler kapalı: planlama iptal ediliyor');
        for (final prayer in prayers) {
          final id = prayer['id'] as int;
          await _alarmService.cancelAlarm(id);
          await _notificationService.cancelNotification(id + 100);
        }
        await _notificationService.stopOngoingCountdownNotification();
        return;
      }
      
      for (var prayer in prayers) {
        try {
          // Namaz vakti
          String timeString = prayer['time'] as String;
          timeString = timeString.split(' ')[0]; // Sadece saat kısmını al
          
          final parts = timeString.split(':');
          if (parts.length < 2) {
            AppLogger.warning('Geçersiz zaman formatı: ${prayer['time']} -> $timeString');
            continue;
          }
          
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          var prayerTime = DateTime(today.year, today.month, today.day, hour, minute);
          
          // Eğer zaman geçmişse yarına planla
          if (prayerTime.isBefore(now)) {
            prayerTime = prayerTime.add(const Duration(days: 1));
          }
          
          // Sadece gelecekteki zamanları planla
          if (prayerTime.isAfter(now)) {
            // Akıllı bildirim - ezan vaktinden X dakika önce
            final notificationTime = prayerTime.subtract(Duration(minutes: notificationMinutes));
            
            if (notificationTime.isAfter(now)) {
              await _notificationService.scheduleSmartPrayerNotification(
                id: (prayer['id'] as int) + 100, // Farklı ID aralığı
                prayerName: prayer['name'] as String,
                scheduledTime: notificationTime,
                minutesBefore: notificationMinutes,
              );
              AppLogger.success('Akıllı bildirim planlandı: ${prayer['name']} - $notificationMinutes dakika önce');
            }
            
            // Normal alarm - ezan vaktinde
            await _alarmService.schedulePrayerAlarm(
              id: prayer['id'] as int,
              scheduledTime: prayerTime,
              prayerName: prayer['name'] as String,
            );
            AppLogger.success('Alarm planlandı: ${prayer['name']} - ${prayerTime.toString()}');
          } else {
            AppLogger.warning('Alarm zamanı geçmiş: ${prayer['name']} - ${prayerTime.toString()}');
          }
        } catch (e) {
          AppLogger.error('Alarm ayarlanamadı: ${prayer['name']} - $e');
        }
      }

      // Kalıcı geri sayım bildirimi: sonraki vakte kalan süre
      try {
        DateTime? nextTime;
        String? nextName;
        for (var prayer in prayers) {
          String timeString = (prayer['time'] as String).split(' ')[0];
          final parts = timeString.split(':');
          if (parts.length < 2) continue;
          final hour = int.parse(parts[0]);
          final minute = int.parse(parts[1]);
          var dt = DateTime(today.year, today.month, today.day, hour, minute);
          if (dt.isBefore(now)) dt = dt.add(const Duration(days: 1));
          if (nextTime == null || dt.isBefore(nextTime)) {
            nextTime = dt;
            nextName = prayer['name'] as String;
          }
        }

        if (nextTime != null && nextName != null) {
          final remaining = nextTime.difference(now);
          final hh = remaining.inHours;
          final mm = remaining.inMinutes.remainder(60);
          final ss = remaining.inSeconds.remainder(60);
          final formatted = '${hh.toString().padLeft(2, '0')}:${mm.toString().padLeft(2, '0')}:${ss.toString().padLeft(2, '0')}';

          await _notificationService.showOngoingCountdownNotification(
            id: 5000,
            title: '⏳ Sonraki Vakit: $nextName',
            body: '$nextName vaktine $formatted kaldı',
            targetTime: nextTime,
          );
        }
      } catch (e) {
        AppLogger.warning('Geri sayım bildirimi güncellenemedi', error: e);
      }
      
      AppLogger.success('Tüm namaz alarmları planlandı');
    } catch (e) {
      AppLogger.error('Bildirim planlama genel hata: $e');
    }
  }

  String _calculateNextPrayer(Map<String, String> times) {
    final now = DateTime.now();
    final loc = AppLocalizations.of(context);
    final ordered = [
      [loc.translate('prayer_fajr'), times['Fajr']!],
      [loc.translate('prayer_sunrise'), times['Sunrise']!],
      [loc.translate('prayer_dhuhr'), times['Dhuhr']!],
      [loc.translate('prayer_asr'), times['Asr']!],
      [loc.translate('prayer_maghrib'), times['Maghrib']!],
      [loc.translate('prayer_isha'), times['Isha']!],
    ];
    for (final item in ordered) {
      final parts = item[1].split(':');
      final dt = DateTime(now.year, now.month, now.day, int.parse(parts[0]), int.parse(parts[1]));
      if (dt.isAfter(now)) {
        return item[0];
      }
    }
    return loc.translate('prayer_fajr');
  }

  Future<void> _checkNotificationPermission() async {
    final hasPermission = await _notificationService.requestNotificationPermission();
    if (mounted) {
      final loc = AppLocalizations.of(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            hasPermission
                ? loc.translate('notification_permission_granted')
                : loc.translate('notification_permission_denied'),
          ),
          backgroundColor: hasPermission ? Colors.green : Colors.orange,
        ),
      );
    }
  }

  Future<void> _sendTestNotification() async {
    try {
      await _notificationService.showNotification(
        id: 999,
        title: AppLocalizations.of(context).translate('test_notification_title'),
        body: AppLocalizations.of(context).translate('test_notification_body'),
      );
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.translate('test_notification_sent')),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        final loc = AppLocalizations.of(context);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(loc.translate('error_with_detail', params: {'error': e.toString()})),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _showPrayerSchedule(String prayerKey, String displayName) async {
    final loc = AppLocalizations.of(context);
    try {
      // Loading state göster
      if (mounted) {
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) => const Center(
            child: CircularProgressIndicator(),
          ),
        );
      }

      if (_scheduleFor40Days.isEmpty) {
        AppLogger.info('40 günlük takvim verisi boş, yeniden yükleniyor');
        await _loadPrayerTimes(forceRefresh: true);
      }

      // Loading dialog'u kapat
      if (mounted) {
        Navigator.of(context).pop();
      }

      if (mounted) {
        showModalBottomSheet<void>(
          context: context,
          isScrollControlled: true,
          builder: (context) {
            if (_scheduleFor40Days.isEmpty) {
              return Center(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(Icons.error_outline, size: 48, color: Colors.red),
                      const SizedBox(height: 16),
                      Text(
                        loc.translate('prayer_schedule_error_title'),
                        style: Theme.of(context).textTheme.titleMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        loc.translate('prayer_schedule_error_body'),
                        style: Theme.of(context).textTheme.bodyMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          _showPrayerSchedule(prayerKey, displayName);
                        },
                        child: Text(loc.translate('try_again_button')),
                      ),
                    ],
                  ),
                ),
              );
            }
            
            return SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      loc.translate(
                        'prayer_schedule_title',
                        params: {
                          'prayer': displayName,
                        },
                      ),
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      height: 400,
                      child: ListView.separated(
                        itemCount: _scheduleFor40Days.length,
                        separatorBuilder: (_, __) => const Divider(),
                        itemBuilder: (context, index) {
                          final day = _scheduleFor40Days[index];
                          final time = day.getTimeForPrayer(prayerKey);
                          final localeTag = Localizations.localeOf(context).toLanguageTag();
                          return ListTile(
                            leading: CircleAvatar(
                              child: Text('${index + 1}'),
                            ),
                            title: Text(DateFormat('dd MMMM yyyy', localeTag).format(day.date)),
                            trailing: Text(
                              _formatTimeForDisplay(time),
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      }
    } catch (e) {
      AppLogger.error('40 günlük takvim gösterim hatası: $e');
      
      // Loading dialog'u kapat
      if (mounted) {
        Navigator.of(context).pop();
      }
      
      // Hata mesajı göster
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              AppLocalizations.of(context).translate(
                'schedule_show_error',
                params: {'error': e.toString()},
              ),
            ),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _updateHomeWidget(Map<String, String> currentTimes, String? nextPrayerName) async {
    if (currentTimes.isEmpty) return;
    final mapped = <String, String>{
      'Fajr': currentTimes['Fajr'] ?? '',
      'Sunrise': currentTimes['Sunrise'] ?? '',
      'Dhuhr': currentTimes['Dhuhr'] ?? '',
      'Asr': currentTimes['Asr'] ?? '',
      'Maghrib': currentTimes['Maghrib'] ?? '',
      'Isha': currentTimes['Isha'] ?? '',
    };
    final key = nextPrayerName != null ? _mapPrayerNameToKey(nextPrayerName) : null;
    final nextTime = key != null ? currentTimes[key] : null;
    await PrayerWidgetService.updatePrayerTimes(
      prayerTimes: mapped,
      cityName: cityName,
      nextPrayerName: nextPrayerName,
      nextPrayerTime: nextTime,
    );
  }

  String? _mapPrayerNameToKey(String name) {
    final loc = AppLocalizations.of(context);
    if (name == loc.translate('prayer_fajr')) return 'Fajr';
    if (name == loc.translate('prayer_sunrise')) return 'Sunrise';
    if (name == loc.translate('prayer_dhuhr')) return 'Dhuhr';
    if (name == loc.translate('prayer_asr')) return 'Asr';
    if (name == loc.translate('prayer_maghrib')) return 'Maghrib';
    if (name == loc.translate('prayer_isha')) return 'Isha';
    return null;
  }

  IconData _getPrayerIcon(String prayerName) {
    final loc = AppLocalizations.of(context);
    if (prayerName == loc.translate('prayer_fajr')) return Icons.nightlight_round;
    if (prayerName == loc.translate('prayer_sunrise')) return Icons.wb_sunny;
    if (prayerName == loc.translate('prayer_dhuhr')) return Icons.wb_sunny_outlined;
    if (prayerName == loc.translate('prayer_asr')) return Icons.wb_twilight;
    if (prayerName == loc.translate('prayer_maghrib')) return Icons.nights_stay;
    if (prayerName == loc.translate('prayer_isha')) return Icons.dark_mode;
    return Icons.access_time;
  }

  @override
  Widget build(BuildContext context) {
    final mainScaffold = Scaffold.maybeOf(context);
    final loc = AppLocalizations.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(loc.translate('bottom_nav_prayer_times')),
        leading: IconButton(
          icon: const Icon(Icons.menu),
          onPressed: () => mainScaffold?.openDrawer(),
        ),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) {
              if (value == 'test') _sendTestNotification();
              if (value == 'permission') _checkNotificationPermission();
              if (value == 'refresh') _loadPrayerTimes(forceRefresh: true);
            },
            itemBuilder: (context) => [
              PopupMenuItem(
                value: 'test',
                child: Row(children: [const Icon(Icons.notifications_active, color: Colors.green), const SizedBox(width: 8), Text(loc.translate('test_notification'))]),
              ),
              PopupMenuItem(
                value: 'permission',
                child: Row(children: [const Icon(Icons.security, color: Colors.blue), const SizedBox(width: 8), Text(loc.translate('permission_check'))]),
              ),
              PopupMenuItem(
                value: 'refresh',
                child: Row(children: [const Icon(Icons.refresh, color: Colors.orange), const SizedBox(width: 8), Text(loc.translate('refresh'))]),
              ),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: isLoading
                ? const Center(
                    child: CircularProgressIndicator(
                      color: AppTheme.primaryYellow,
                    ),
                  )
                : errorMessage != null
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Icon(Icons.error_outline, size: 64, color: Colors.red),
                            const SizedBox(height: 16),
                            Text(
                              errorMessage!,
                              textAlign: TextAlign.center,
                              style: const TextStyle(fontSize: 16),
                            ),
                            const SizedBox(height: 24),
                            ElevatedButton.icon(
                              onPressed: () => _loadPrayerTimes(forceRefresh: true),
                              icon: const Icon(Icons.refresh),
                              label: Text(loc.translate('try_again')),
                            ),
                          ],
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: () => _loadPrayerTimes(forceRefresh: true),
                        color: AppTheme.primaryYellow,
                        child: ListView(
                          padding: const EdgeInsets.all(16),
                          children: [
                            Card(
                              color: AppTheme.primaryYellow,
                              child: Padding(
                                padding: const EdgeInsets.all(16.0),
                                child: Row(
                                  children: [
                                    const Icon(Icons.location_on, color: Colors.white, size: 32),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(loc.translate('location'), style: const TextStyle(color: Colors.white70, fontSize: 14)),
                                          Text(
                                            cityName ?? loc.translate('location_unknown'),
                                            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                                          ),
                                        ],
                                      ),
                                    ),
                                    Text(
                                      DateFormat(
                                        'dd MMMM yyyy',
                                        Localizations.localeOf(context).toLanguageTag(),
                                      ).format(DateTime.now()),
                                      style: const TextStyle(color: Colors.white, fontSize: 14),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            const SizedBox(height: 16),
                            if (prayerTimes != null) ...[
                              PrayerCard(
                                prayerName: loc.translate('prayer_fajr'),
                                prayerTime: _formatTimeForDisplay(prayerTimes!['Fajr']!),
                                icon: _getPrayerIcon(loc.translate('prayer_fajr')),
                                isNext: nextPrayer == loc.translate('prayer_fajr'),
                                onTap: () => _showPrayerSchedule('Fajr', loc.translate('prayer_fajr')),
                              ),
                              const SizedBox(height: 8),
                              PrayerCard(
                                prayerName: loc.translate('prayer_sunrise'),
                                prayerTime: _formatTimeForDisplay(prayerTimes!['Sunrise']!),
                                icon: _getPrayerIcon(loc.translate('prayer_sunrise')),
                                isNext: nextPrayer == loc.translate('prayer_sunrise'),
                                onTap: () => _showPrayerSchedule('Sunrise', loc.translate('prayer_sunrise')),
                              ),
                              const SizedBox(height: 8),
                              PrayerCard(
                                prayerName: loc.translate('prayer_dhuhr'),
                                prayerTime: _formatTimeForDisplay(prayerTimes!['Dhuhr']!),
                                icon: _getPrayerIcon(loc.translate('prayer_dhuhr')),
                                isNext: nextPrayer == loc.translate('prayer_dhuhr'),
                                onTap: () => _showPrayerSchedule('Dhuhr', loc.translate('prayer_dhuhr')),
                              ),
                              const SizedBox(height: 8),
                              PrayerCard(
                                prayerName: loc.translate('prayer_asr'),
                                prayerTime: _formatTimeForDisplay(prayerTimes!['Asr']!),
                                icon: _getPrayerIcon(loc.translate('prayer_asr')),
                                isNext: nextPrayer == loc.translate('prayer_asr'),
                                onTap: () => _showPrayerSchedule('Asr', loc.translate('prayer_asr')),
                              ),
                              const SizedBox(height: 8),
                              PrayerCard(
                                prayerName: loc.translate('prayer_maghrib'),
                                prayerTime: _formatTimeForDisplay(prayerTimes!['Maghrib']!),
                                icon: _getPrayerIcon(loc.translate('prayer_maghrib')),
                                isNext: nextPrayer == loc.translate('prayer_maghrib'),
                                onTap: () => _showPrayerSchedule('Maghrib', loc.translate('prayer_maghrib')),
                              ),
                              const SizedBox(height: 8),
                              PrayerCard(
                                prayerName: loc.translate('prayer_isha'),
                                prayerTime: _formatTimeForDisplay(prayerTimes!['Isha']!),
                                icon: _getPrayerIcon(loc.translate('prayer_isha')),
                                isNext: nextPrayer == loc.translate('prayer_isha'),
                                onTap: () => _showPrayerSchedule('Isha', loc.translate('prayer_isha')),
                              ),
                            ],
                          ],
                        ),
                      ),
          ),
          const AdMobBanner(),
        ],
      ),
    );
  }
}