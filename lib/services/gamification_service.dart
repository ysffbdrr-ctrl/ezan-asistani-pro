import 'package:shared_preferences/shared_preferences.dart';

class GamificationService {
  static const String _pointsKey = 'total_points';
  static const String _levelKey = 'user_level';
  static const String _badgesKey = 'earned_badges';
  // static const String _achievementsKey = 'achievements'; // Future use

  // Puan kazanma eylemleri
  static const int pointsPerPrayer = 10;
  static const int pointsPerQuran = 20;
  static const int pointsPerDua = 5;
  static const int pointsPerQuiz = 15;
  static const int pointsPerDailyQuestion = 10;
  static const int pointsPerStreak = 25;

  // Seviye hesaplama
  static int calculateLevel(int points) {
    return (points / 100).floor() + 1;
  }

  static int pointsForNextLevel(int currentPoints) {
    int currentLevel = calculateLevel(currentPoints);
    return (currentLevel * 100) - currentPoints;
  }

  // Puan ekleme
  static Future<Map<String, dynamic>> addPoints(String action, int points) async {
    final prefs = await SharedPreferences.getInstance();
    int currentPoints = prefs.getInt(_pointsKey) ?? 0;
    int newPoints = currentPoints + points;
    
    int oldLevel = calculateLevel(currentPoints);
    int newLevel = calculateLevel(newPoints);
    bool leveledUp = newLevel > oldLevel;

    await prefs.setInt(_pointsKey, newPoints);
    await prefs.setInt(_levelKey, newLevel);

    return {
      'points': newPoints,
      'level': newLevel,
      'leveledUp': leveledUp,
      'action': action,
      'earnedPoints': points,
    };
  }

  // Toplam puan getir
  static Future<int> getTotalPoints() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_pointsKey) ?? 0;
  }

  // Seviye getir
  static Future<int> getLevel() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_levelKey) ?? 1;
  }

  // Rozet ekleme
  static Future<void> addBadge(String badgeId) async {
    final prefs = await SharedPreferences.getInstance();
    List<String> badges = prefs.getStringList(_badgesKey) ?? [];
    if (!badges.contains(badgeId)) {
      badges.add(badgeId);
      await prefs.setStringList(_badgesKey, badges);
    }
  }

  // Rozetleri getir
  static Future<List<String>> getBadges() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getStringList(_badgesKey) ?? [];
  }

  // Rozet kontrolü
  static Future<bool> hasBadge(String badgeId) async {
    final badges = await getBadges();
    return badges.contains(badgeId);
  }

  // Başarı kaydetme
  static Future<void> recordAchievement(String achievementId, int value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('achievement_$achievementId', value);
  }

  // Başarı getirme
  static Future<int> getAchievement(String achievementId) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('achievement_$achievementId') ?? 0;
  }

  // Seri günler (streak)
  static Future<int> getStreak() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('prayer_streak') ?? 0;
  }

  static Future<void> updateStreak(bool completed) async {
    final prefs = await SharedPreferences.getInstance();
    if (completed) {
      int streak = await getStreak();
      await prefs.setInt('prayer_streak', streak + 1);
    } else {
      await prefs.setInt('prayer_streak', 0);
    }
  }
}

// Rozet tanımları
class Badge {
  final String id;
  final String name;
  final String description;
  final String icon;
  final int requiredValue;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.icon,
    required this.requiredValue,
  });
}

class BadgeDefinitions {
  static final List<Badge> allBadges = [
    Badge(
      id: 'first_prayer',
      name: 'İlk Namaz',
      description: 'İlk namazını takip ettin!',
      icon: '🕌',
      requiredValue: 1,
    ),
    Badge(
      id: 'prayer_master',
      name: 'Namaz Ustası',
      description: '100 namaz kıldın!',
      icon: '⭐',
      requiredValue: 100,
    ),
    Badge(
      id: 'quran_reader',
      name: 'Kur\'an Okuyucusu',
      description: '10 sure okudun!',
      icon: '📖',
      requiredValue: 10,
    ),
    Badge(
      id: 'knowledge_seeker',
      name: 'İlim Arayan',
      description: '50 quiz sorusunu doğru cevapladın!',
      icon: '🎓',
      requiredValue: 50,
    ),
    Badge(
      id: 'streak_7',
      name: '7 Gün Serisi',
      description: '7 gün üst üste namaz kıldın!',
      icon: '🔥',
      requiredValue: 7,
    ),
    Badge(
      id: 'streak_30',
      name: '30 Gün Serisi',
      description: '30 gün üst üste namaz kıldın!',
      icon: '💎',
      requiredValue: 30,
    ),
    Badge(
      id: 'level_10',
      name: 'Seviye 10',
      description: '10. seviyeye ulaştın!',
      icon: '🏆',
      requiredValue: 10,
    ),
    Badge(
      id: 'dua_lover',
      name: 'Dua Seven',
      description: '50 dua okudun!',
      icon: '🤲',
      requiredValue: 50,
    ),
    Badge(
      id: 'zikr_1000',
      name: 'Zikir Alışkanlığı',
      description: 'Toplam 1000 zikir yaptın!',
      icon: '📿',
      requiredValue: 1000,
    ),
    Badge(
      id: 'zikr_10000',
      name: 'Zikir Ustası',
      description: 'Toplam 10.000 zikir yaptın!',
      icon: '💫',
      requiredValue: 10000,
    ),
  ];

  static Badge? getBadgeById(String id) {
    try {
      return allBadges.firstWhere((badge) => badge.id == id);
    } catch (e) {
      return null;
    }
  }
}
