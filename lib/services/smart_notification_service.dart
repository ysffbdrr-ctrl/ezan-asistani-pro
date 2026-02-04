import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:permission_handler/permission_handler.dart';
import 'package:ezan_asistani/utils/logger.dart';

class SmartNotificationService {
  static final SmartNotificationService _instance = SmartNotificationService._internal();
  factory SmartNotificationService() => _instance;
  SmartNotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  // Callback for notification actions
  Function(String actionId, String prayerName)? onNotificationAction;

  // Bildirim başlat
  Future<bool> initialize() async {
    try {
      // Timezone ayarla
      tzdata.initializeTimeZones();
      final location = tz.getLocation('Europe/Istanbul');
      tz.setLocalLocation(location);

      // Android başlatma ayarları
      const AndroidInitializationSettings androidSettings =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      const InitializationSettings settings = InitializationSettings(
        android: androidSettings,
      );

      // Bildirimleri başlat
      final initialized = await _notifications.initialize(
        settings,
        onDidReceiveNotificationResponse: (NotificationResponse response) {
          _handleNotificationResponse(response);
        },
      );

      if (initialized != true) {
        AppLogger.error('Bildirim başlatılamadı');
        return false;
      }

      // Android 13+ için bildirim izni iste
      await requestNotificationPermission();

      return true;
    } catch (e) {
      AppLogger.error('Bildirim başlatma hatası', error: e);
      return false;
    }
  }

  // Bildirim izni iste (Android 13+)
  Future<bool> requestNotificationPermission() async {
    final status = await Permission.notification.request();
    if (status.isGranted) {
      AppLogger.success('Bildirim izni verildi');
      return true;
    } else {
      AppLogger.warning('Bildirim izni reddedildi');
      return false;
    }
  }

  // Akıllı ezan vakti bildirimi - AI asistan tarzı
  Future<void> scheduleSmartPrayerNotification({
    required int id,
    required String prayerName,
    required DateTime scheduledTime,
    required int minutesBefore,
  }) async {
    try {
      // Geçmiş zamanı kontrol et
      if (scheduledTime.isBefore(DateTime.now())) {
        AppLogger.warning('Bildirim zamanı geçmiş, atlanıyor: $scheduledTime');
        return;
      }

      // Akıllı mesaj oluştur
      final title = '🕌 $prayerName Ezanı Yaklaşıyor';
      final body = '$prayerName ezanı $minutesBefore dakika sonra… Abdestin var mı?';

      // Android action buttons
      final AndroidNotificationDetails androidDetails = AndroidNotificationDetails(
        'smart_prayer_channel',
        'Akıllı Ezan Bildirimleri',
        channelDescription: 'AI asistan tarzı ezan vakti bildirimleri',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound('notification'),
        actions: <AndroidNotificationAction>[
          AndroidNotificationAction(
            'abdest_var',
            '✔️ Var',
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'abdest_yok',
            '❗ Yok',
            showsUserInterface: true,
          ),
          AndroidNotificationAction(
            'abdest_rehberi',
            '🧼 Rehbere Git',
            showsUserInterface: true,
          ),
        ],
        tag: 'prayer_$id',
        groupKey: 'prayer_notifications',
        setAsGroupSummary: false,
      );

      final NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      final tzDateTime = tz.TZDateTime.from(scheduledTime, tz.local);

      await _notifications.zonedSchedule(
        id,
        title,
        body,
        tzDateTime,
        notificationDetails,
        androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        payload: 'prayer_$prayerName',
      );

      AppLogger.success('Akıllı bildirim planlandı: $prayerName - $scheduledTime');
    } catch (e) {
      AppLogger.error('Bildirim planlama hatası', error: e);
    }
  }

  // Bildirim yanıtını işle
  void _handleNotificationResponse(NotificationResponse response) {
    final actionId = response.actionId;
    final payload = response.payload ?? '';

    AppLogger.info('Bildirim eylemi: $actionId, Payload: $payload', tag: 'Notification');

    // Payload'dan dua adını çıkar
    String prayerName = '';
    if (payload.startsWith('prayer_')) {
      prayerName = payload.replaceFirst('prayer_', '');
    }

    // Callback çağır
    if (onNotificationAction != null && actionId != null) {
      onNotificationAction!(actionId, prayerName);
    }

    // İşlem yap
    _processNotificationAction(actionId, prayerName);
  }

  // Bildirim eylemini işle
  void _processNotificationAction(String? actionId, String prayerName) {
    switch (actionId) {
      case 'abdest_var':
        AppLogger.info('Kullanıcı: Abdestin var', tag: 'Notification');
        // Gamification puanı ekle
        _addGamificationPoints(prayerName, 'abdest_var');
        break;
      case 'abdest_yok':
        AppLogger.info('Kullanıcı: Abdestin yok', tag: 'Notification');
        // Abdest rehberine yönlendir (UI tarafında yapılacak)
        _addGamificationPoints(prayerName, 'abdest_yok');
        break;
      case 'abdest_rehberi':
        AppLogger.info('Kullanıcı: Abdest rehberine gitmek istiyor', tag: 'Notification');
        // Abdest rehberine yönlendir (UI tarafında yapılacak)
        break;
    }
  }

  // Gamification puanı ekle
  void _addGamificationPoints(String prayerName, String action) {
    // Bu işlem UI tarafında yapılacak
    AppLogger.info('Gamification: $prayerName - $action', tag: 'Notification');
  }

  // Anlık bildirim gönder
  Future<void> showNotification({
    required int id,
    required String title,
    required String body,
  }) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'prayer_times_channel',
        'Ezan Vakitleri',
        channelDescription: 'Ezan vakti bildirimleri',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound('notification'),
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _notifications.show(id, title, body, notificationDetails);
      AppLogger.success('Bildirim gösterildi: $title');
    } catch (e) {
      AppLogger.error('Bildirim gösterme hatası', error: e);
    }
  }

  // Tüm bildirimleri iptal et
  Future<void> cancelAllNotifications() async {
    try {
      await _notifications.cancelAll();
      AppLogger.success('Tüm bildirimler iptal edildi');
    } catch (e) {
      AppLogger.error('Bildirim iptal hatası', error: e);
    }
  }

  // Belirli bir bildirimi iptal et
  Future<void> cancelNotification(int id) async {
    try {
      await _notifications.cancel(id);
      AppLogger.success('Bildirim iptal edildi: $id');
    } catch (e) {
      AppLogger.error('Bildirim iptal hatası', error: e);
    }
  }

  // Bekleyen bildirimleri listele
  Future<List<PendingNotificationRequest>> getPendingNotifications() async {
    try {
      return await _notifications.pendingNotificationRequests();
    } catch (e) {
      AppLogger.error('Bekleyen bildirimler alınamadı', error: e);
      return [];
    }
  }
}
