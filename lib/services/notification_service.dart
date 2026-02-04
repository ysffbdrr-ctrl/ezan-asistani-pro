import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest.dart' as tzdata;
import 'package:permission_handler/permission_handler.dart';
import 'package:ezan_asistani/utils/logger.dart';
import 'package:ezan_asistani/services/reward_service.dart' as reward;
import 'package:ezan_asistani/services/leaderboard_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import 'dart:io';

class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _notifications =
      FlutterLocalNotificationsPlugin();

  static const MethodChannel _countdownServiceChannel =
      MethodChannel('com.xnx.ezanasistanipro/countdown_service');

  // Notification action callback
  Function(String actionId, String prayerName)? onNotificationAction;

  // Bildirimleri başlat
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

      // Android 12+ exact alarm izni (AlarmManager exactAllowWhileIdle ve AndroidAlarmManager için)
      await _requestExactAlarmPermissionIfNeeded();

      // Bildirim kanallarını oluştur
      await _createNotificationChannels();

      AppLogger.success('Bildirim servisi başlatıldı');
      return true;
    } catch (e) {
      AppLogger.error('Bildirim başlatma hatası', error: e);
      return false;
    }
  }

  Future<void> _requestExactAlarmPermissionIfNeeded() async {
    try {
      final android = _notifications.resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin>();
      if (android == null) return;

      // Bazı cihazlarda (Android 12+) exact alarm izni yoksa schedule çalışmayabilir.
      final granted = await android.canScheduleExactNotifications();
      if (granted != true) {
        await android.requestExactAlarmsPermission();
      }
    } catch (e) {
      // Bazı sürümlerde API bulunmayabilir; sessizce geç.
      AppLogger.warning('Exact alarm izni kontrol edilemedi', error: e);
    }
  }

  // Bildirim kanallarını oluştur
  Future<void> _createNotificationChannels() async {
    try {
      const AndroidNotificationChannel prayerChannel =
          AndroidNotificationChannel(
        'prayer_times_channel',
        'Ezan Vakitleri',
        description: 'Ezan vakti bildirimleri',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound('notification'),
        enableVibration: true,
      );

      const AndroidNotificationChannel smartPrayerChannel =
          AndroidNotificationChannel(
        'smart_prayer_channel',
        'Akıllı Ezan Bildirimleri',
        description: 'AI asistan tarzı ezan vakti bildirimleri',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound('notification'),
        enableVibration: true,
      );

      const AndroidNotificationChannel countdownChannel =
          AndroidNotificationChannel(
        'countdown_channel',
        'Vakit Geri Sayım',
        description: 'Sonraki vakte kalan süreyi gösteren kalıcı bildirim',
        importance: Importance.low,
      );

      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(prayerChannel);

      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(smartPrayerChannel);

      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(countdownChannel);

      AppLogger.success('Bildirim kanalları oluşturuldu');
    } catch (e) {
      AppLogger.error('Bildirim kanalı oluşturma hatası: $e');
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

  // Ezan vakti bildirimi oluştur (eski format - backward compatibility)
  Future<void> schedulePrayerNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledTime,
  }) async {
    try {
      // Geçmiş zamanı kontrol et
      if (scheduledTime.isBefore(DateTime.now())) {
        AppLogger.warning('Bildirim zamanı geçmiş, atlanıyor: $scheduledTime');
        return;
      }

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
        // Namaz vakitleri günlük değiştiği için burada tekrar (daily) ayarlamak yanlış olur.
      );

      AppLogger.success('Bildirim planlandı: $title - $scheduledTime');
    } catch (e) {
      AppLogger.error('Bildirim planlama hatası', error: e);
    }
  }

  // Akıllı ezan vakti bildirimi - AI asistan tarzı (yeni format)
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

      // Spam yok: sadece sabah (İmsak) ve akşam (Yatsı) bildirimi
      if (prayerName != 'İmsak' && prayerName != 'Yatsı') {
        return;
      }

      // Aynı gün aynı bildirimi tekrar planlamayı engelle
      final prefs = await SharedPreferences.getInstance();
      final todayKey =
          '${DateTime.now().year}-${DateTime.now().month.toString().padLeft(2, '0')}-${DateTime.now().day.toString().padLeft(2, '0')}';
      final dedupeKey = 'smart_notif_${todayKey}_${prayerName}_$minutesBefore';
      final alreadyScheduled = prefs.getBool(dedupeKey) ?? false;
      if (alreadyScheduled) {
        return;
      }

      String title;
      String body;
      if (prayerName == 'İmsak') {
        title = 'Günaydın';
        body = 'İmsak $minutesBefore dk sonra';
      } else {
        title = 'Akşam Hatırlatması';
        body = 'Yatsıya $minutesBefore dk kaldı';
      }

      // Akıllı mesaj oluştur
      title = title;
      body = body;

      // Android action buttons
      final AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'smart_prayer_channel',
        'Akıllı Ezan Bildirimleri',
        channelDescription: 'AI asistan tarzı ezan vakti bildirimleri',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        sound: const RawResourceAndroidNotificationSound('notification'),
        actions: <AndroidNotificationAction>[
          const AndroidNotificationAction(
            'abdest_var',
            '✔️ Var',
            showsUserInterface: true,
          ),
          const AndroidNotificationAction(
            'abdest_yok',
            '❗ Yok',
            showsUserInterface: true,
          ),
          const AndroidNotificationAction(
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

      await prefs.setBool(dedupeKey, true);

      AppLogger.success(
          'Akıllı bildirim planlandı: $prayerName - $scheduledTime');
    } catch (e) {
      AppLogger.error('Bildirim planlama hatası', error: e);
    }
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

  Future<void> showOngoingCountdownNotification({
    required int id,
    required String title,
    required String body,
    DateTime? targetTime,
  }) async {
    try {
      if (Platform.isAndroid) {
        await _countdownServiceChannel.invokeMethod('startOrUpdateCountdown', {
          'title': title,
          'body': body,
          'targetEpochMs': targetTime?.millisecondsSinceEpoch ?? -1,
        });
        return;
      }

      final androidDetails = AndroidNotificationDetails(
        'countdown_channel',
        'Vakit Geri Sayım',
        channelDescription: 'Sonraki vakte kalan süreyi gösteren kalıcı bildirim',
        importance: Importance.low,
        priority: Priority.low,
        category: AndroidNotificationCategory.service,
        showProgress: false,
        ongoing: true,
        autoCancel: false,
        onlyAlertOnce: true,
        showWhen: true,
        when: targetTime?.millisecondsSinceEpoch,
        usesChronometer: targetTime != null,
        chronometerCountDown: targetTime != null,
      );

      final details = NotificationDetails(android: androidDetails);
      await _notifications.show(id, title, body, details);
    } catch (e) {
      AppLogger.error('Kalıcı geri sayım bildirimi gösterme hatası', error: e);
    }
  }

  Future<void> stopOngoingCountdownNotification() async {
    try {
      if (Platform.isAndroid) {
        await _countdownServiceChannel.invokeMethod('stopCountdown');
      }
    } catch (e) {
      AppLogger.error('Kalıcı geri sayım servisini durdurma hatası', error: e);
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

  // Bildirim response handler
  void _handleNotificationResponse(NotificationResponse response) {
    final actionId = response.actionId;
    final payload = response.payload ?? '';

    AppLogger.info('Bildirim eylemi: $actionId, Payload: $payload',
        tag: 'Notification');

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
    final rewardService = reward.RewardService();

    switch (actionId) {
      case 'abdest_var':
        AppLogger.info('Kullanıcı: Abdestin var', tag: 'Notification');
        // 10 puan ekle
        _addGamificationPoints(prayerName, 'abdest_var', 10, rewardService);
        break;
      case 'abdest_yok':
        AppLogger.info('Kullanıcı: Abdestin yok', tag: 'Notification');
        // 5 puan ekle
        _addGamificationPoints(prayerName, 'abdest_yok', 5, rewardService);
        break;
      case 'abdest_rehberi':
        AppLogger.info('Kullanıcı: Abdest rehberine gitmek istiyor',
            tag: 'Notification');
        // 15 puan ekle
        _addGamificationPoints(prayerName, 'abdest_rehberi', 15, rewardService);
        break;
    }
  }

  // Gamification puanı ekle
  void _addGamificationPoints(
    String prayerName,
    String action,
    int points,
    reward.RewardService rewardService,
  ) async {
    try {
      await rewardService.initialize();
      final newBadge = await rewardService.addPoints(
        points,
        '$action - $prayerName',
      );

      // Leaderboard'a da puan ekle
      try {
        final prefs = await SharedPreferences.getInstance();
        final userId = prefs.getString('user_id') ??
            'user_${DateTime.now().millisecondsSinceEpoch}';
        final userName = prefs.getString('kullanici_adi') ?? 'Misafir';

        final leaderboardService = LeaderboardService();
        await leaderboardService.initialize(userId, userName);
        await leaderboardService.addPoints(points, 'Haftalık');

        AppLogger.info('Leaderboard puanı eklendi: +$points');
      } catch (e) {
        AppLogger.error('Leaderboard puan ekleme hatası', error: e);
      }

      if (newBadge != null) {
        // Yeni rozet açıldı - bildirim gönder
        _showRewardNotification(newBadge);
      }
    } catch (e) {
      AppLogger.error('Puan ekleme hatası', error: e);
    }
  }

  // Ödül bildirimi gönder
  Future<void> _showRewardNotification(reward.Badge badge) async {
    try {
      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'reward_channel',
        'Ödüller',
        channelDescription: 'Rozet ve ödül bildirimleri',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound('notification'),
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      await _notifications.show(
        badge.id,
        '🎉 Yeni Rozet Açıldı!',
        '${badge.emoji} ${badge.name} rozetini kazandın!',
        notificationDetails,
      );

      AppLogger.success('Ödül bildirimi gönderildi: ${badge.name}');
    } catch (e) {
      AppLogger.error('Ödül bildirimi gönderme hatası', error: e);
    }
  }

  // Günlük hadis bildirimi kanalını oluştur
  Future<void> _createHadithNotificationChannel() async {
    try {
      const AndroidNotificationChannel hadithChannel =
          AndroidNotificationChannel(
        'daily_hadith_channel',
        'Günlük Hadis',
        description: 'Her gün hadis bildirimleri',
        importance: Importance.high,
        sound: RawResourceAndroidNotificationSound('notification'),
        enableVibration: true,
      );

      await _notifications
          .resolvePlatformSpecificImplementation<
              AndroidFlutterLocalNotificationsPlugin>()
          ?.createNotificationChannel(hadithChannel);

      AppLogger.success('Hadis bildirimi kanalı oluşturuldu');
    } catch (e) {
      AppLogger.error('Hadis bildirimi kanalı oluşturma hatası: $e');
    }
  }

  // Günlük hadis bildirimi planla
  Future<void> scheduleDailyHadithNotification({
    required String hadithText,
    required String hadithSource,
    required int hour,
    required int minute,
  }) async {
    try {
      // Hadis bildirimi kanalını oluştur
      await _createHadithNotificationChannel();

      const AndroidNotificationDetails androidDetails =
          AndroidNotificationDetails(
        'daily_hadith_channel',
        'Günlük Hadis',
        channelDescription: 'Her gün hadis bildirimleri',
        importance: Importance.high,
        priority: Priority.high,
        playSound: true,
        enableVibration: true,
        sound: RawResourceAndroidNotificationSound('notification'),
      );

      const NotificationDetails notificationDetails = NotificationDetails(
        android: androidDetails,
      );

      // Bugünün zamanını kontrol et
      var scheduledDate = tz.TZDateTime(
        tz.local,
        DateTime.now().year,
        DateTime.now().month,
        DateTime.now().day,
        hour,
        minute,
      );

      // Eğer zaman geçmiştir, yarın planla
      if (scheduledDate.isBefore(tz.TZDateTime.now(tz.local))) {
        scheduledDate = scheduledDate.add(const Duration(days: 1));
      }

      final hadithPreview = hadithText.length > 100
          ? '${hadithText.substring(0, 100)}...'
          : hadithText;

      await _notifications.zonedSchedule(
        999, // Hadis bildirimi ID
        '📖 Günlük Hadis',
        hadithPreview,
        scheduledDate,
        notificationDetails,
        uiLocalNotificationDateInterpretation:
            UILocalNotificationDateInterpretation.absoluteTime,
        matchDateTimeComponents: DateTimeComponents.time, // Her gün aynı saatte
        payload: 'hadith_notification',
      );

      AppLogger.success(
          'Günlük hadis bildirimi planlandı: $hour:${minute.toString().padLeft(2, '0')}');
    } catch (e) {
      AppLogger.error('Hadis bildirimi planlama hatası', error: e);
    }
  }

  // Günlük hadis bildirimini iptal et
  Future<void> cancelDailyHadithNotification() async {
    try {
      await _notifications.cancel(999);
      AppLogger.success('Günlük hadis bildirimi iptal edildi');
    } catch (e) {
      AppLogger.error('Hadis bildirimi iptal etme hatası', error: e);
    }
  }
}
