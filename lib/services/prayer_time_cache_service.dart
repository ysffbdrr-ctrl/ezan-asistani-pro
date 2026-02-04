import 'dart:convert';
import 'dart:io';
import 'package:path_provider/path_provider.dart';

class PrayerTimeCacheService {
  static const _fileName = 'prayer_times_cache.json';

  Future<File> get _localFile async {
    final directory = await getApplicationDocumentsDirectory();
    return File('${directory.path}/$_fileName');
  }

  Future<void> savePrayerTimes(List<Map<String, dynamic>> prayerTimes) async {
    final file = await _localFile;
    final data = {
      'timestamp': DateTime.now().toIso8601String(),
      'prayerTimes': prayerTimes,
    };
    await file.writeAsString(json.encode(data));
  }

  Future<List<Map<String, dynamic>>?> loadPrayerTimes() async {
    try {
      final file = await _localFile;
      if (!await file.exists()) {
        return null;
      }

      final contents = await file.readAsString();
      final data = json.decode(contents) as Map<String, dynamic>;

      // Cache is considered stale after 24 hours
      final timestamp = DateTime.parse(data['timestamp'] as String);
      if (DateTime.now().difference(timestamp).inHours > 24) {
        return null;
      }

      return List<Map<String, dynamic>>.from(data['prayerTimes'] as List);
    } catch (e) {
      return null;
    }
  }

  Future<void> clearCache() async {
    final file = await _localFile;
    if (await file.exists()) {
      await file.delete();
    }
  }
}
