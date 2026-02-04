import 'package:home_widget/home_widget.dart';

class PrayerWidgetService {
  static const _widgetNames = <String>{
    'PrayerTimesLargeWidgetProvider',
    'PrayerTimesCompactWidgetProvider',
    'PrayerTimesNextWidgetProvider',
    'PrayerTimesHorizontalWidgetProvider',
  };

  static Future<void> updatePrayerTimes({
    required Map<String, String> prayerTimes,
    String? cityName,
    String? nextPrayerName,
    String? nextPrayerTime,
  }) async {
    try {
      await HomeWidget.saveWidgetData<String>('city', cityName ?? '');
      await HomeWidget.saveWidgetData<String>('nextPrayer', nextPrayerName ?? '');
      await HomeWidget.saveWidgetData<String>('nextPrayerTime', nextPrayerTime ?? '');
      await HomeWidget.saveWidgetData<String>(
        'updatedAt',
        _formatUpdatedAt(),
      );
      for (final entry in prayerTimes.entries) {
        await HomeWidget.saveWidgetData<String>('time_${entry.key}', entry.value);
      }
      for (final widgetName in _widgetNames) {
        await HomeWidget.updateWidget(name: widgetName);
      }
    } catch (_) {
      // Widget updates shouldn't crash the app; fail silently.
    }
  }

  static String _formatUpdatedAt() {
    final now = DateTime.now();
    final twoDigits = (int value) => value.toString().padLeft(2, '0');
    final day = twoDigits(now.day);
    final month = twoDigits(now.month);
    final hour = twoDigits(now.hour);
    final minute = twoDigits(now.minute);
    return '$day.$month - $hour:$minute';
  }
}
