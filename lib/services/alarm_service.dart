import 'package:android_alarm_manager_plus/android_alarm_manager_plus.dart';
import 'package:ezan_asistani/services/notification_service.dart';
import 'package:ezan_asistani/utils/logger.dart';

// Arka planda çalışacak olan callback fonksiyonu (native tarafından çağrılır)
@pragma('vm:entry-point')
void alarmCallbackDispatcher(int id, Map<String, dynamic> params) async {
  try {
    AppLogger.info('Alarm tetiklendi: ID $id');
    final notificationService = NotificationService();

    // Bildirim servisini başlat
    final initialized = await notificationService.initialize();
    if (!initialized) {
      AppLogger.error('Bildirim servisi başlatılamadı');
      return;
    }

    // Bildirim gönder
    await notificationService.showNotification(
      id: id,
      title: params['title'] as String? ?? 'Ezan Vakti',
      body: params['body'] as String? ?? 'Ezan okunuyor!',
    );
    AppLogger.success('Bildirim gönderildi: ID $id');
  } catch (e) {
    AppLogger.error('Alarm callback hatası: $e');
  }
}

@pragma('vm:entry-point')
class AlarmService {
  final NotificationService _notificationService = NotificationService();

  Future<void> schedulePrayerAlarm({
    required int id,
    required DateTime scheduledTime,
    required String prayerName,
  }) async {
    try {
      // Geçmiş zamanı kontrol et
      if (scheduledTime.isBefore(DateTime.now())) {
        AppLogger.warning('Alarm zamanı geçmiş, atlanıyor: $prayerName - $scheduledTime');
        return;
      }

      await AndroidAlarmManager.oneShotAt(
        scheduledTime,
        id,
        alarmCallbackDispatcher,
        exact: true,
        wakeup: true,
        alarmClock: true,
        params: {
          'title': '$prayerName Vakti',
          'body': '$prayerName ezanı okunuyor. Haydi namaza!',
        },
      );
      
      AppLogger.success('Alarm planlandı: $prayerName - $scheduledTime');
    } catch (e) {
      AppLogger.error('Alarm planlama hatası: $prayerName - $e');
    }
  }

  Future<void> cancelAlarm(int id) async {
    await AndroidAlarmManager.cancel(id);
  }

  Future<void> cancelAllAlarms() async {
    // Bu paket tüm alarmları tek seferde iptal etme fonksiyonu sunmuyor.
    // Alarmları ID'leri ile tek tek iptal etmemiz gerekiyor.
    // Örneğin, 1'den 6'ya kadar olan namaz ID'lerini iptal edebiliriz.
    for (int i = 1; i <= 6; i++) {
      await cancelAlarm(i);
    }
  }
}
