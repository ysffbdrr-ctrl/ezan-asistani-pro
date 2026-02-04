import 'package:ezan_asistani/services/prayer_time_cache_service.dart';
import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class RamazanModu extends StatefulWidget {
  const RamazanModu({Key? key}) : super(key: key);

  @override
  State<RamazanModu> createState() => _RamazanModuState();
}

class _RamazanModuState extends State<RamazanModu> {
  final PrayerTimeCacheService _cacheService = PrayerTimeCacheService();

  bool _isLoading = true;
  String? _error;

  DateTime? _gregorianDate;
  String? _hijriDateText;

  String? _imsak;
  String? _iftar;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      setState(() {
        _isLoading = true;
        _error = null;
      });

      final cached = await _cacheService.loadPrayerTimes();
      if (cached == null || cached.isEmpty) {
        setState(() {
          _isLoading = false;
          _error = 'Ramazan Modu için önce Ezan Vakitleri ekranından vakitleri yüklemelisin.';
        });
        return;
      }

      final today = DateTime.now();
      final todayKey = DateFormat('dd-MM-yyyy').format(DateTime(today.year, today.month, today.day));

      Map<String, dynamic>? todayEntry;
      for (final entry in cached) {
        try {
          final dateData = entry['date'] as Map<String, dynamic>?;
          final gregorian = dateData?['gregorian'] as Map<String, dynamic>?;
          final dateStr = gregorian?['date'] as String?;
          if (dateStr == todayKey) {
            todayEntry = entry;
            break;
          }
        } catch (_) {
          // ignore
        }
      }

      if (todayEntry == null) {
        setState(() {
          _isLoading = false;
          _error = 'Bugünün vakitleri bulunamadı. Lütfen Ezan Vakitleri ekranından yenile.';
        });
        return;
      }

      final timings = todayEntry['timings'] as Map<String, dynamic>?;
      if (timings == null) {
        setState(() {
          _isLoading = false;
          _error = 'Vakit verisi okunamadı. Lütfen yenile.';
        });
        return;
      }

      String cleanTime(dynamic time) {
        final raw = (time ?? '').toString();
        if (raw.isEmpty) return '';
        return raw.split(' ')[0];
      }

      final imsak = cleanTime(timings['Fajr']);
      final iftar = cleanTime(timings['Maghrib']);

      final dateData = todayEntry['date'] as Map<String, dynamic>?;
      final hijri = dateData?['hijri'] as Map<String, dynamic>?;
      final hijriDay = hijri?['day']?.toString();
      final hijriMonth = (hijri?['month'] as Map?)?['en']?.toString() ?? (hijri?['month'] as Map?)?['ar']?.toString();
      final hijriYear = hijri?['year']?.toString();

      String? hijriText;
      if ((hijriDay ?? '').isNotEmpty && (hijriMonth ?? '').isNotEmpty && (hijriYear ?? '').isNotEmpty) {
        hijriText = '$hijriDay $hijriMonth $hijriYear';
      }

      DateTime? greg;
      try {
        final gregorian = dateData?['gregorian'] as Map<String, dynamic>?;
        final dateStr = gregorian?['date'] as String?;
        if (dateStr != null && dateStr.contains('-')) {
          greg = DateFormat('dd-MM-yyyy').parse(dateStr);
        }
      } catch (_) {
        greg = null;
      }

      setState(() {
        _isLoading = false;
        _error = null;
        _gregorianDate = greg;
        _hijriDateText = hijriText;
        _imsak = imsak;
        _iftar = iftar;
      });
    } catch (_) {
      setState(() {
        _isLoading = false;
        _error = 'Bir hata oluştu. Lütfen tekrar dene.';
      });
    }
  }

  DateTime? _parseTodayTime(String? hhmm) {
    if (hhmm == null || hhmm.trim().isEmpty) return null;
    final parts = hhmm.split(':');
    if (parts.length < 2) return null;
    final now = DateTime.now();
    final h = int.tryParse(parts[0]);
    final m = int.tryParse(parts[1]);
    if (h == null || m == null) return null;
    return DateTime(now.year, now.month, now.day, h, m);
  }

  String _formatDuration(Duration d) {
    final totalMinutes = d.inMinutes;
    final hours = totalMinutes ~/ 60;
    final minutes = totalMinutes % 60;
    if (hours <= 0) return '$minutes dk';
    return '$hours sa $minutes dk';
  }

  ({String title, String timeText, Duration? remaining}) _status() {
    final now = DateTime.now();
    final imsakDt = _parseTodayTime(_imsak);
    final iftarDt = _parseTodayTime(_iftar);

    if (imsakDt == null || iftarDt == null) {
      return (title: 'Bugün', timeText: '', remaining: null);
    }

    if (now.isBefore(imsakDt)) {
      return (
        title: 'İmsaka Kalan',
        timeText: _imsak ?? '',
        remaining: imsakDt.difference(now),
      );
    }

    if (now.isBefore(iftarDt)) {
      return (
        title: 'İftara Kalan',
        timeText: _iftar ?? '',
        remaining: iftarDt.difference(now),
      );
    }

    final nextImsak = imsakDt.add(const Duration(days: 1));
    return (
      title: 'Yarın İmsak',
      timeText: _imsak ?? '',
      remaining: nextImsak.difference(now),
    );
  }

  @override
  Widget build(BuildContext context) {
    final status = _status();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ramazan Modu'),
        actions: [
          IconButton(
            onPressed: _load,
            icon: const Icon(Icons.refresh),
            tooltip: 'Yenile',
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryYellow))
          : _error != null
              ? Center(
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.info_outline, size: 48, color: Colors.grey),
                        const SizedBox(height: 12),
                        Text(
                          _error!,
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: _load,
                          icon: const Icon(Icons.refresh),
                          label: const Text('Tekrar Dene'),
                        ),
                      ],
                    ),
                  ),
                )
              : ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    Card(
                      color: AppTheme.primaryYellow,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            const Icon(Icons.nights_stay, color: Colors.white, size: 32),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    _gregorianDate == null
                                        ? DateFormat('dd MMMM yyyy', 'tr_TR').format(DateTime.now())
                                        : DateFormat('dd MMMM yyyy', 'tr_TR').format(_gregorianDate!),
                                    style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
                                  ),
                                  if ((_hijriDateText ?? '').isNotEmpty) ...[
                                    const SizedBox(height: 4),
                                    Text(
                                      _hijriDateText!,
                                      style: TextStyle(color: Colors.white.withOpacity(0.9), fontSize: 13),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    Card(
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              status.title,
                              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 8),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    status.remaining == null ? '-' : _formatDuration(status.remaining!),
                                    style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.primaryYellow),
                                  ),
                                ),
                                if ((status.timeText).isNotEmpty)
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                                    decoration: BoxDecoration(
                                      color: AppTheme.primaryYellow.withOpacity(0.12),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Text(
                                      status.timeText,
                                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.primaryYellow),
                                    ),
                                  ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('İmsak', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Text(
                                    _imsak ?? '-',
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Card(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text('İftar', style: TextStyle(fontWeight: FontWeight.bold)),
                                  const SizedBox(height: 6),
                                  Text(
                                    _iftar ?? '-',
                                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
    );
  }
}
