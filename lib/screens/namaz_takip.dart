import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:ezan_asistani/services/gamification_service.dart' as gamification_service;

class NamazTakip extends StatefulWidget {
  const NamazTakip({Key? key}) : super(key: key);

  @override
  State<NamazTakip> createState() => _NamazTakipState();
}

class _NamazTakipState extends State<NamazTakip> {
  final List<String> _namazlar = ['Sabah', 'Öğle', 'İkindi', 'Akşam', 'Yatsı'];
  Map<String, bool> _bugunKilinan = {};
  Map<String, int> _istatistikler = {};
  int _toplam = 0;
  int _buAyToplam = 0;
  String _selectedDate = DateFormat('yyyy-MM-dd').format(DateTime.now());

  String _todayKey() {
    final now = DateTime.now();
    return DateFormat('yyyy-MM-dd').format(now);
  }

  Future<void> _handleGamificationOnPrayerMarked() async {
    try {
      // Puan ekle
      final result = await gamification_service.GamificationService.addPoints(
        'Namaz',
        gamification_service.GamificationService.pointsPerPrayer,
      );

      // İlk namaz rozeti
      if ((result['points'] as int? ?? 0) > 0) {
        await gamification_service.GamificationService.addBadge('first_prayer');
      }

      // Seviye 10 rozeti
      final level = result['level'] as int? ?? 1;
      if (level >= 10) {
        await gamification_service.GamificationService.addBadge('level_10');
      }

      // Toplam namaz sayısını achievement olarak kaydet
      await gamification_service.GamificationService.recordAchievement(
        'prayer_count',
        _toplam,
      );

      // 100 namaz rozeti
      if (_toplam >= 100) {
        await gamification_service.GamificationService.addBadge('prayer_master');
      }
    } catch (_) {
      // ignore
    }
  }

  Future<void> _updateStreakIfNeeded() async {
    if (_selectedDate != _todayKey()) return;

    final prefs = await SharedPreferences.getInstance();
    final streakKey = 'streak_updated_${_selectedDate}';
    final already = prefs.getBool(streakKey) ?? false;

    final completedToday = _bugunKilinan.values.where((v) => v).length == 5;

    // Gün tamamlandıysa streak'i 1 artır (günde 1 kez)
    if (completedToday && !already) {
      await gamification_service.GamificationService.updateStreak(true);
      await prefs.setBool(streakKey, true);

      final streak = await gamification_service.GamificationService.getStreak();
      if (streak >= 7) {
        await gamification_service.GamificationService.addBadge('streak_7');
      }
      if (streak >= 30) {
        await gamification_service.GamificationService.addBadge('streak_30');
      }
    }

    // Tamamlanmış günü bozarsa streak'i sıfırla ve işareti kaldır
    if (!completedToday && already) {
      await gamification_service.GamificationService.updateStreak(false);
      await prefs.setBool(streakKey, false);
    }
  }

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      for (var namaz in _namazlar) {
        String key = '${_selectedDate}_$namaz';
        _bugunKilinan[namaz] = prefs.getBool(key) ?? false;
        _istatistikler[namaz] = prefs.getInt('total_$namaz') ?? 0;
      }
      _toplam = prefs.getInt('total_all') ?? 0;
      _buAyToplam = prefs.getInt('month_${DateTime.now().month}_${DateTime.now().year}') ?? 0;
    });
  }

  Future<void> _toggleNamaz(String namaz) async {
    final prefs = await SharedPreferences.getInstance();
    String key = '${_selectedDate}_$namaz';
    
    bool yeniDurum = !(_bugunKilinan[namaz] ?? false);
    
    setState(() {
      _bugunKilinan[namaz] = yeniDurum;
    });

    await prefs.setBool(key, yeniDurum);

    // İstatistikleri güncelle
    if (yeniDurum) {
      int total = _istatistikler[namaz] ?? 0;
      _istatistikler[namaz] = total + 1;
      await prefs.setInt('total_$namaz', total + 1);

      _toplam++;
      await prefs.setInt('total_all', _toplam);

      _buAyToplam++;
      String monthKey = 'month_${DateTime.now().month}_${DateTime.now().year}';
      await prefs.setInt(monthKey, _buAyToplam);

      await _handleGamificationOnPrayerMarked();
    } else {
      int total = _istatistikler[namaz] ?? 0;
      if (total > 0) {
        _istatistikler[namaz] = total - 1;
        await prefs.setInt('total_$namaz', total - 1);

        if (_toplam > 0) _toplam--;
        await prefs.setInt('total_all', _toplam);

        if (_buAyToplam > 0) _buAyToplam--;
        String monthKey = 'month_${DateTime.now().month}_${DateTime.now().year}';
        await prefs.setInt(monthKey, _buAyToplam);
      }
    }

    await _updateStreakIfNeeded();

    setState(() {});
  }

  IconData _getNamazIcon(String namaz) {
    switch (namaz) {
      case 'Sabah':
        return Icons.wb_sunny_outlined;
      case 'Öğle':
        return Icons.wb_sunny;
      case 'İkindi':
        return Icons.wb_twilight;
      case 'Akşam':
        return Icons.nightlight_round;
      case 'Yatsı':
        return Icons.nights_stay;
      default:
        return Icons.mosque;
    }
  }

  @override
  Widget build(BuildContext context) {
    int bugunKilindi = _bugunKilinan.values.where((v) => v).length;
    double bugunYuzde = (bugunKilindi / 5) * 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Namaz Takip'),
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Bugünkü Özet Kartı
          Card(
            elevation: 4,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            DateFormat('d MMMM yyyy', 'tr_TR').format(DateTime.now()),
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            DateFormat('EEEE', 'tr_TR').format(DateTime.now()),
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryYellow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(
                          Icons.mosque,
                          size: 32,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  LinearProgressIndicator(
                    value: bugunYuzde / 100,
                    backgroundColor: Colors.grey[300],
                    color: AppTheme.primaryYellow,
                    minHeight: 8,
                    borderRadius: BorderRadius.circular(4),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        '$bugunKilindi / 5 Namaz',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        '${bugunYuzde.toStringAsFixed(0)}%',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.primaryYellow,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Bugünkü Namazlar
          const Text(
            'Bugünkü Namazlar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          ...List.generate(_namazlar.length, (index) {
            String namaz = _namazlar[index];
            bool kilindi = _bugunKilinan[namaz] ?? false;

            return Card(
              margin: const EdgeInsets.only(bottom: 12),
              child: ListTile(
                contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                leading: Container(
                  width: 56,
                  height: 56,
                  decoration: BoxDecoration(
                    color: kilindi ? AppTheme.primaryYellow : Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    _getNamazIcon(namaz),
                    color: kilindi ? Colors.black : Colors.grey[600],
                    size: 28,
                  ),
                ),
                title: Text(
                  '$namaz Namazı',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    decoration: kilindi ? TextDecoration.lineThrough : null,
                  ),
                ),
                subtitle: Text(
                  kilindi ? 'Kılındı ✓' : 'Kılınmadı',
                  style: TextStyle(
                    color: kilindi ? Colors.green : Colors.grey[600],
                    fontSize: 14,
                  ),
                ),
                trailing: Checkbox(
                  value: kilindi,
                  onChanged: (value) => _toggleNamaz(namaz),
                  activeColor: AppTheme.primaryYellow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
                onTap: () => _toggleNamaz(namaz),
              ),
            );
          }),

          const SizedBox(height: 24),

          // İstatistikler
          const Text(
            'İstatistikler',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Genel İstatistikler
          Row(
            children: [
              Expanded(
                child: Card(
                  color: AppTheme.lightYellow,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.check_circle,
                          size: 32,
                          color: AppTheme.darkYellow,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_toplam',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Toplam Namaz',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Card(
                  color: AppTheme.lightYellow,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      children: [
                        const Icon(
                          Icons.calendar_month,
                          size: 32,
                          color: AppTheme.darkYellow,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '$_buAyToplam',
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Bu Ay',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Namaz Bazlı İstatistikler
          Card(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Namaz Bazlı İstatistikler',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ...List.generate(_namazlar.length, (index) {
                    String namaz = _namazlar[index];
                    int sayi = _istatistikler[namaz] ?? 0;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Row(
                        children: [
                          Icon(
                            _getNamazIcon(namaz),
                            size: 20,
                            color: AppTheme.primaryYellow,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              namaz,
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.lightYellow,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              '$sayi',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Motivasyon Kartı
          Card(
            color: AppTheme.primaryYellow,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(
                    Icons.emoji_events,
                    size: 48,
                    color: Colors.black,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    _getMotivationText(bugunKilindi),
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _getMotivationSubtext(bugunKilindi),
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  String _getMotivationText(int kilindi) {
    if (kilindi == 5) return 'Mükemmel! 🎉';
    if (kilindi >= 4) return 'Harika gidiyorsun! 👏';
    if (kilindi >= 3) return 'Güzel! Devam et! 💪';
    if (kilindi >= 2) return 'İyi başlangıç! 🌟';
    if (kilindi >= 1) return 'Bir adım bile değerli! ✨';
    return 'Başla şimdi! 🤲';
  }

  String _getMotivationSubtext(int kilindi) {
    if (kilindi == 5) return 'Bugün tüm namazlarını kıldın!';
    if (kilindi >= 4) return 'Sadece ${5 - kilindi} namaz kaldı!';
    if (kilindi >= 3) return 'Yarıyı geçtin, devam et!';
    if (kilindi >= 2) return 'Güne güzel başladın!';
    if (kilindi >= 1) return 'Bir adım bile çok değerli!';
    return 'Her an başlamak için iyi bir an!';
  }
}
