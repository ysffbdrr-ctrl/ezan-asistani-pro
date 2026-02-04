import 'package:flutter/material.dart';
import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:ezan_asistani/services/gamification_service.dart' as gamification_service;

class ProfilIstatistik extends StatefulWidget {
  const ProfilIstatistik({Key? key}) : super(key: key);

  @override
  State<ProfilIstatistik> createState() => _ProfilIstatistikState();
}

class _ProfilIstatistikState extends State<ProfilIstatistik> {
  int _totalPoints = 0;
  int _level = 1;
  List<String> _earnedBadges = [];
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadStats();
  }

  Future<void> _loadStats() async {
    final points = await gamification_service.GamificationService.getTotalPoints();
    final level = await gamification_service.GamificationService.getLevel();
    final badges = await gamification_service.GamificationService.getBadges();
    final streak = await gamification_service.GamificationService.getStreak();

    setState(() {
      _totalPoints = points;
      _level = level;
      _earnedBadges = badges;
      _streak = streak;
    });
  }

  @override
  Widget build(BuildContext context) {
    int pointsForNext = gamification_service.GamificationService.pointsForNextLevel(_totalPoints);
    double progress = (_totalPoints % 100) / 100;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profilim & İstatistikler'),
        elevation: 2,
      ),
      body: RefreshIndicator(
        onRefresh: _loadStats,
        color: AppTheme.primaryYellow,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // Seviye Kartı
            Card(
              elevation: 4,
              color: AppTheme.primaryYellow,
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
                            const Text(
                              'Seviyeniz',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              'Seviye $_level',
                              style: const TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          width: 80,
                          height: 80,
                          decoration: BoxDecoration(
                            color: Colors.black.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(40),
                          ),
                          child: Center(
                            child: Text(
                              _getLevelEmoji(_level),
                              style: const TextStyle(fontSize: 40),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              '$_totalPoints Puan',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            Text(
                              'Sonraki seviyeye: $pointsForNext',
                              style: const TextStyle(
                                fontSize: 12,
                                color: Colors.black87,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        LinearProgressIndicator(
                          value: progress,
                          backgroundColor: Colors.black.withOpacity(0.2),
                          color: Colors.black,
                          minHeight: 8,
                          borderRadius: BorderRadius.circular(4),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Streak Kartı
            Card(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: _streak >= 7 ? Colors.orange : AppTheme.lightYellow,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        _streak >= 7 ? '🔥' : '⭐',
                        style: const TextStyle(fontSize: 32),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Günlük Seri',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _streak == 0
                                ? 'Henüz seri yok'
                                : '$_streak gün üst üste namaz kıldın!',
                            style: TextStyle(
                              fontSize: 13,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                    Text(
                      '$_streak',
                      style: const TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryYellow,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Rozetler Bölümü
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Rozetlerim',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  '${_earnedBadges.length}/${gamification_service.BadgeDefinitions.allBadges.length}',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),

            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 0.85,
              ),
              itemCount: gamification_service.BadgeDefinitions.allBadges.length,
              itemBuilder: (context, index) {
                final badge = gamification_service.BadgeDefinitions.allBadges[index];
                final isEarned = _earnedBadges.contains(badge.id);

                return GestureDetector(
                  onTap: () => _showBadgeDetails(badge, isEarned),
                  child: Card(
                    color: isEarned ? AppTheme.primaryYellow : Colors.grey[300],
                    child: Padding(
                      padding: const EdgeInsets.all(12),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            badge.icon,
                            style: TextStyle(
                              fontSize: 40,
                              color: isEarned ? null : Colors.grey[400],
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            badge.name,
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.bold,
                              color: isEarned ? Colors.black : Colors.grey[600],
                            ),
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 24),

            // Puan Kazanma Rehberi
            const Text(
              'Puan Nasıl Kazanılır?',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            _buildPointCard('Namaz Kıl', '+${gamification_service.GamificationService.pointsPerPrayer} puan', Icons.mosque),
            _buildPointCard('Kur\'an Oku', '+${gamification_service.GamificationService.pointsPerQuran} puan', Icons.menu_book),
            _buildPointCard('Dua Et', '+${gamification_service.GamificationService.pointsPerDua} puan', Icons.volunteer_activism),
            _buildPointCard('Quiz Çöz', '+${gamification_service.GamificationService.pointsPerQuiz} puan', Icons.quiz),
            _buildPointCard('Günlük Soru', '+${gamification_service.GamificationService.pointsPerDailyQuestion} puan', Icons.question_answer),
            _buildPointCard('Seri Bonus', '+${gamification_service.GamificationService.pointsPerStreak} puan', Icons.local_fire_department),
          ],
        ),
      ),
    );
  }

  Widget _buildPointCard(String title, String points, IconData icon) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppTheme.lightYellow,
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(icon, color: AppTheme.darkYellow),
        ),
        title: Text(title),
        trailing: Text(
          points,
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryYellow,
          ),
        ),
      ),
    );
  }

  String _getLevelEmoji(int level) {
    if (level >= 50) return '👑';
    if (level >= 40) return '💎';
    if (level >= 30) return '🏆';
    if (level >= 20) return '⭐';
    if (level >= 10) return '🌟';
    return '✨';
  }

  void _showBadgeDetails(gamification_service.Badge badge, bool isEarned) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(badge.icon, style: const TextStyle(fontSize: 32)),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                badge.name,
                style: const TextStyle(fontSize: 18),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(badge.description),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isEarned ? Colors.green[50] : Colors.grey[200],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                children: [
                  Icon(
                    isEarned ? Icons.check_circle : Icons.lock,
                    color: isEarned ? Colors.green : Colors.grey,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    isEarned ? 'Kazanıldı!' : 'Henüz kazanılmadı',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isEarned ? Colors.green : Colors.grey,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Kapat'),
          ),
        ],
      ),
    );
  }
}
