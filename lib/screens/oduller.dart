import 'package:flutter/material.dart';
import 'package:ezan_asistani/services/reward_service.dart';
import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:share_plus/share_plus.dart';
import 'package:intl/intl.dart';

class Oduller extends StatefulWidget {
  const Oduller({Key? key}) : super(key: key);

  @override
  State<Oduller> createState() => _OdullerState();
}

class _OdullerState extends State<Oduller> {
  final RewardService _rewardService = RewardService();
  late Future<void> _initFuture;

  @override
  void initState() {
    super.initState();
    _initFuture = _rewardService.initialize();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🏆 Ödüllerim'),
        backgroundColor: AppTheme.primaryYellow,
        elevation: 0,
      ),
      body: FutureBuilder<void>(
        future: _initFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          return SingleChildScrollView(
            child: Column(
              children: [
                // Puan Kartı
                _buildPointsCard(),
                const SizedBox(height: 24),
                // Sonraki Rozet
                _buildNextBadgeCard(),
                const SizedBox(height: 24),
                // Açılan Rozetler
                _buildUnlockedBadges(),
                const SizedBox(height: 24),
                // Kilitli Rozetler
                _buildLockedBadges(),
                const SizedBox(height: 24),
              ],
            ),
          );
        },
      ),
    );
  }

  // Puan Kartı
  Widget _buildPointsCard() {
    final stats = _rewardService.getStats();
    final totalPoints = stats['totalPoints'] as int;
    final unlockedBadges = stats['unlockedBadges'] as int;
    final totalBadges = stats['totalBadges'] as int;

    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryYellow,
            AppTheme.primaryYellow.withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: AppTheme.primaryYellow.withOpacity(0.3),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          Text(
            'Toplam Puanın',
            style: TextStyle(
              fontSize: 16,
              color: Colors.white.withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$totalPoints ⭐',
            style: const TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              Column(
                children: [
                  Text(
                    '$unlockedBadges',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Rozet',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
              Container(
                width: 1,
                height: 40,
                color: Colors.white.withOpacity(0.3),
              ),
              Column(
                children: [
                  Text(
                    '$totalBadges',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Toplam',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.8),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }

  // Sonraki Rozet Kartı
  Widget _buildNextBadgeCard() {
    final nextBadge = _rewardService.getNextBadge();
    final pointsUntilNext = _rewardService.getPointsUntilNextBadge();
    final totalPoints = _rewardService.getTotalPoints();

    if (nextBadge == null) {
      return Container(
        margin: const EdgeInsets.symmetric(horizontal: 16),
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: Colors.green[50],
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.green[300]!),
        ),
        child: Column(
          children: [
            const Text(
              '🎉 Tüm Rozetleri Açtın!',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Harika! Tüm ödülleri kazandın.',
              style: TextStyle(
                fontSize: 14,
                color: Colors.green[700],
              ),
            ),
          ],
        ),
      );
    }

    final progress = (totalPoints / nextBadge.requiredPoints).clamp(0.0, 1.0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.blue[50],
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.blue[300]!),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Sonraki Rozet',
                    style: TextStyle(
                      fontSize: 12,
                      color: Colors.blue[700],
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${nextBadge.emoji} ${nextBadge.name}',
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              Text(
                '$pointsUntilNext puan kaldı',
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.blue[700],
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.blue[200],
              valueColor: AlwaysStoppedAnimation<Color>(Colors.blue[700]!),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '$totalPoints / ${nextBadge.requiredPoints}',
            style: TextStyle(
              fontSize: 12,
              color: Colors.blue[700],
            ),
          ),
        ],
      ),
    );
  }

  // Açılan Rozetler
  Widget _buildUnlockedBadges() {
    final unlockedBadges = _rewardService.getUnlockedBadges();

    if (unlockedBadges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '✅ Kazanılan Rozetler (${unlockedBadges.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: unlockedBadges.length,
          itemBuilder: (context, index) {
            final badge = unlockedBadges[index];
            return _buildBadgeCard(badge, isUnlocked: true);
          },
        ),
      ],
    );
  }

  // Kilitli Rozetler
  Widget _buildLockedBadges() {
    final lockedBadges = _rewardService.getLockedBadges();

    if (lockedBadges.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Text(
            '🔒 Kilitli Rozetler (${lockedBadges.length})',
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 12),
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
          ),
          itemCount: lockedBadges.length,
          itemBuilder: (context, index) {
            final badge = lockedBadges[index];
            return _buildBadgeCard(badge, isUnlocked: false);
          },
        ),
      ],
    );
  }

  // Rozet Kartı
  Widget _buildBadgeCard(Badge badge, {required bool isUnlocked}) {
    return GestureDetector(
      onLongPress: isUnlocked
          ? () => _showBadgeDetails(badge)
          : null,
      child: Container(
        decoration: BoxDecoration(
          color: isUnlocked ? Colors.green[50] : Colors.grey[100],
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isUnlocked ? Colors.green[300]! : Colors.grey[300]!,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              badge.emoji,
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(height: 8),
            Text(
              badge.name,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: isUnlocked ? Colors.green[700] : Colors.grey[600],
              ),
            ),
            const SizedBox(height: 4),
            Text(
              '${badge.requiredPoints}p',
              style: TextStyle(
                fontSize: 10,
                color: isUnlocked ? Colors.green[600] : Colors.grey[500],
              ),
            ),
            if (isUnlocked && badge.unlockedAt != null)
              Padding(
                padding: const EdgeInsets.only(top: 4),
                child: Text(
                  DateFormat('dd.MM.yy').format(badge.unlockedAt!),
                  style: TextStyle(
                    fontSize: 8,
                    color: Colors.green[500],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  // Rozet Detayları
  void _showBadgeDetails(Badge badge) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              badge.emoji,
              style: const TextStyle(fontSize: 60),
            ),
            const SizedBox(height: 16),
            Text(
              badge.name,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              badge.description,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Açılış Tarihi: ${DateFormat('dd MMMM yyyy', 'tr_TR').format(badge.unlockedAt!)}',
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[500],
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                Navigator.pop(context);
                _shareBadge(badge);
              },
              icon: const Icon(Icons.share),
              label: const Text('Paylaş'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryYellow,
                minimumSize: const Size(double.infinity, 48),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Rozeti Paylaş
  void _shareBadge(Badge badge) {
    final message = '''
🎉 Ezan Asistanı Pro'da ${badge.name} rozetini kazandım! ${badge.emoji}

${badge.description}

Seni de davet ediyorum! Namaz vakitlerini takip et ve rozetler kazan.
''';

    Share.share(message);
  }
}
