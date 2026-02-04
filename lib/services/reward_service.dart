import 'package:shared_preferences/shared_preferences.dart';
import 'package:ezan_asistani/utils/logger.dart';

class Badge {
  final int id;
  final String name;
  final String emoji;
  final int requiredPoints;
  final String description;
  final DateTime? unlockedAt;

  Badge({
    required this.id,
    required this.name,
    required this.emoji,
    required this.requiredPoints,
    required this.description,
    this.unlockedAt,
  });

  bool get isUnlocked => unlockedAt != null;

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'emoji': emoji,
    'requiredPoints': requiredPoints,
    'description': description,
    'unlockedAt': unlockedAt?.toIso8601String(),
  };

  factory Badge.fromJson(Map<String, dynamic> json) => Badge(
    id: json['id'] as int,
    name: json['name'] as String,
    emoji: json['emoji'] as String,
    requiredPoints: json['requiredPoints'] as int,
    description: json['description'] as String,
    unlockedAt: json['unlockedAt'] != null 
        ? DateTime.parse(json['unlockedAt'] as String)
        : null,
  );
}

class RewardService {
  static final RewardService _instance = RewardService._internal();
  factory RewardService() => _instance;
  RewardService._internal();

  late SharedPreferences _prefs;
  int _totalPoints = 0;
  List<Badge> _badges = [];

  // Ödül seviyeleri
  final List<Badge> _allBadges = [
    Badge(
      id: 1,
      name: 'İlk Adım',
      emoji: '🥉',
      requiredPoints: 100,
      description: 'İlk 100 puanına ulaştın!',
    ),
    Badge(
      id: 2,
      name: 'Tutarlı',
      emoji: '🌟',
      requiredPoints: 250,
      description: '250 puan kazandın!',
    ),
    Badge(
      id: 3,
      name: 'Sadık',
      emoji: '🥈',
      requiredPoints: 500,
      description: '500 puan kazandın!',
    ),
    Badge(
      id: 4,
      name: 'Efsane',
      emoji: '🥇',
      requiredPoints: 1000,
      description: '1000 puan kazandın!',
    ),
    Badge(
      id: 5,
      name: 'Kutsal',
      emoji: '💎',
      requiredPoints: 2500,
      description: '2500 puan kazandın!',
    ),
    Badge(
      id: 6,
      name: 'İmam',
      emoji: '👑',
      requiredPoints: 5000,
      description: '5000 puan kazandın!',
    ),
  ];

  // Başlat
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      _totalPoints = _prefs.getInt('total_points') ?? 0;
      
      // Rozetleri yükle
      _badges = _allBadges.map((badge) {
        final unlockedAtStr = _prefs.getString('badge_${badge.id}_unlocked_at');
        if (unlockedAtStr != null) {
          return Badge(
            id: badge.id,
            name: badge.name,
            emoji: badge.emoji,
            requiredPoints: badge.requiredPoints,
            description: badge.description,
            unlockedAt: DateTime.parse(unlockedAtStr),
          );
        }
        return badge;
      }).toList();

      AppLogger.success('Ödül servisi başlatıldı. Toplam puan: $_totalPoints');
    } catch (e) {
      AppLogger.error('Ödül servisi başlatma hatası', error: e);
    }
  }

  // Puan ekle
  Future<Badge?> addPoints(int points, String reason) async {
    try {
      _totalPoints += points;
      await _prefs.setInt('total_points', _totalPoints);
      
      AppLogger.info('Puan eklendi: +$points ($reason). Toplam: $_totalPoints');

      // Yeni rozet açıldı mı kontrol et
      return _checkForNewBadge();
    } catch (e) {
      AppLogger.error('Puan ekleme hatası', error: e);
      return null;
    }
  }

  // Yeni rozet kontrol et
  Future<Badge?> _checkForNewBadge() async {
    try {
      for (var badge in _badges) {
        if (!badge.isUnlocked && _totalPoints >= badge.requiredPoints) {
          // Rozeti aç
          final unlockedBadge = Badge(
            id: badge.id,
            name: badge.name,
            emoji: badge.emoji,
            requiredPoints: badge.requiredPoints,
            description: badge.description,
            unlockedAt: DateTime.now(),
          );

          // Kaydet
          await _prefs.setString(
            'badge_${badge.id}_unlocked_at',
            unlockedBadge.unlockedAt!.toIso8601String(),
          );

          // Listede güncelle
          final index = _badges.indexWhere((b) => b.id == badge.id);
          if (index != -1) {
            _badges[index] = unlockedBadge;
          }

          AppLogger.success('Yeni rozet açıldı: ${badge.name} (${badge.emoji})');
          return unlockedBadge;
        }
      }
      return null;
    } catch (e) {
      AppLogger.error('Rozet kontrol hatası', error: e);
      return null;
    }
  }

  // Toplam puan al
  int getTotalPoints() => _totalPoints;

  // Tüm rozetleri al
  List<Badge> getAllBadges() => _badges;

  // Açılan rozetleri al
  List<Badge> getUnlockedBadges() => _badges.where((b) => b.isUnlocked).toList();

  // Kilitli rozetleri al
  List<Badge> getLockedBadges() => _badges.where((b) => !b.isUnlocked).toList();

  // Sonraki rozete kaç puan kaldı
  int getPointsUntilNextBadge() {
    final nextBadge = _badges.firstWhere(
      (b) => !b.isUnlocked,
      orElse: () => _badges.last,
    );
    return (nextBadge.requiredPoints - _totalPoints).clamp(0, double.infinity).toInt();
  }

  // Sonraki rozet bilgisi
  Badge? getNextBadge() {
    try {
      return _badges.firstWhere((b) => !b.isUnlocked);
    } catch (e) {
      return null;
    }
  }

  // İstatistikler
  Map<String, dynamic> getStats() => {
    'totalPoints': _totalPoints,
    'unlockedBadges': getUnlockedBadges().length,
    'totalBadges': _badges.length,
    'nextBadge': getNextBadge(),
    'pointsUntilNext': getPointsUntilNextBadge(),
  };
}
