import 'package:flutter/material.dart';
import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ezan_asistani/services/leaderboard_service.dart';

class LiderlikTablosu extends StatefulWidget {
  const LiderlikTablosu({Key? key}) : super(key: key);

  @override
  State<LiderlikTablosu> createState() => _LiderlikTablosuState();
}

class _LiderlikTablosuState extends State<LiderlikTablosu> {
  String _selectedPeriod = 'Haftalık';
  String _selectedCategory = 'Genel';
  String _currentUser = '';
  late LeaderboardService _leaderboardService;
  late Future<void> _initFuture;
  
  // Mock data - Fallback
  final List<Map<String, dynamic>> _leaderboardData = [
    {
      'rank': 1,
      'name': 'Ahmet Y.',
      'score': 15420,
      'level': 15,
      'avatar': 'A',
      'change': 2,
      'badges': ['🏆', '⭐', '🎯'],
    },
    {
      'rank': 2,
      'name': 'Fatma K.',
      'score': 14850,
      'level': 14,
      'avatar': 'F',
      'change': -1,
      'badges': ['🥈', '📖'],
    },
    {
      'rank': 3,
      'name': 'Mehmet S.',
      'score': 13200,
      'level': 13,
      'avatar': 'M',
      'change': 1,
      'badges': ['🥉', '🕌'],
    },
    {
      'rank': 4,
      'name': 'Ayşe B.',
      'score': 12500,
      'level': 12,
      'avatar': 'A',
      'change': 0,
      'badges': ['📿'],
    },
    {
      'rank': 5,
      'name': 'Ali D.',
      'score': 11800,
      'level': 11,
      'avatar': 'A',
      'change': 3,
      'badges': ['🤲'],
    },
    {
      'rank': 6,
      'name': 'Zeynep T.',
      'score': 10900,
      'level': 10,
      'avatar': 'Z',
      'change': -2,
      'badges': [],
    },
    {
      'rank': 7,
      'name': 'Mustafa Ö.',
      'score': 10200,
      'level': 10,
      'avatar': 'M',
      'change': 1,
      'badges': [],
    },
    {
      'rank': 8,
      'name': 'Hatice N.',
      'score': 9500,
      'level': 9,
      'avatar': 'H',
      'change': -1,
      'badges': [],
    },
    {
      'rank': 9,
      'name': 'Ömer E.',
      'score': 8900,
      'level': 8,
      'avatar': 'Ö',
      'change': 0,
      'badges': [],
    },
    {
      'rank': 10,
      'name': 'Esra G.',
      'score': 8200,
      'level': 8,
      'avatar': 'E',
      'change': 2,
      'badges': [],
    },
  ];

  final Map<String, List<Map<String, dynamic>>> _categoryLeaders = {
    'Namaz': [
      {'name': 'Ali D.', 'score': 525, 'detail': '525 vakit'},
      {'name': 'Mehmet S.', 'score': 510, 'detail': '510 vakit'},
      {'name': 'Ayşe B.', 'score': 495, 'detail': '495 vakit'},
    ],
    'Kur\'an': [
      {'name': 'Fatma K.', 'score': 850, 'detail': '850 sayfa'},
      {'name': 'Zeynep T.', 'score': 720, 'detail': '720 sayfa'},
      {'name': 'Hatice N.', 'score': 680, 'detail': '680 sayfa'},
    ],
    'Zikir': [
      {'name': 'Ahmet Y.', 'score': 25000, 'detail': '25K zikir'},
      {'name': 'Ömer E.', 'score': 18500, 'detail': '18.5K zikir'},
      {'name': 'Mustafa Ö.', 'score': 15000, 'detail': '15K zikir'},
    ],
    'Sure Ezberi': [
      {'name': 'Esra G.', 'score': 15, 'detail': '15 sure'},
      {'name': 'Fatma K.', 'score': 12, 'detail': '12 sure'},
      {'name': 'Ayşe B.', 'score': 10, 'detail': '10 sure'},
    ],
  };

  @override
  void initState() {
    super.initState();
    _leaderboardService = LeaderboardService();
    _initFuture = _initializeLeaderboard();
  }

  Future<void> _initializeLeaderboard() async {
    final prefs = await SharedPreferences.getInstance();
    final userId = prefs.getString('user_id') ?? 'user_${DateTime.now().millisecondsSinceEpoch}';
    final userName = prefs.getString('kullanici_adi') ?? 'Misafir';
    
    // Kullanıcı ID'si kaydet
    await prefs.setString('user_id', userId);
    
    // Leaderboard servisi başlat
    await _leaderboardService.initialize(userId, userName);
    
    setState(() {
      _currentUser = userName;
    });
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return Colors.amber;
      case 2:
        return Colors.grey[400]!;
      case 3:
        return Colors.orange[700]!;
      default:
        return Colors.grey[600]!;
    }
  }

  IconData _getRankIcon(int rank) {
    switch (rank) {
      case 1:
        return Icons.looks_one;
      case 2:
        return Icons.looks_two;
      case 3:
        return Icons.looks_3;
      default:
        return Icons.circle;
    }
  }

  Widget _buildTopThree() {
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2. sıra
          Expanded(
            child: _buildPodiumItem(
              _leaderboardData[1],
              height: 140,
              isCenter: false,
            ),
          ),
          const SizedBox(width: 8),
          // 1. sıra
          Expanded(
            child: _buildPodiumItem(
              _leaderboardData[0],
              height: 160,
              isCenter: true,
            ),
          ),
          const SizedBox(width: 8),
          // 3. sıra
          Expanded(
            child: _buildPodiumItem(
              _leaderboardData[2],
              height: 120,
              isCenter: false,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPodiumItem(Map<String, dynamic> user, {required double height, required bool isCenter}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isCenter)
          const Icon(
            Icons.emoji_events,
            color: Colors.amber,
            size: 32,
          ),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _getRankColor(user['rank']),
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.white,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: _getRankColor(user['rank']).withOpacity(0.5),
                blurRadius: 10,
              ),
            ],
          ),
          child: Center(
            child: Text(
              user['avatar'],
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user['name'],
          style: const TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          textAlign: TextAlign.center,
        ),
        Text(
          '${user['score']} XP',
          style: TextStyle(
            fontSize: 11,
            color: Colors.grey[600],
          ),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getRankColor(user['rank']),
                _getRankColor(user['rank']).withOpacity(0.7),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Center(
            child: Text(
              '${user['rank']}',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<void>(
      future: _initFuture,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        return SingleChildScrollView(
          child: Column(
            children: [
              // Filtreler
              Container(
                padding: const EdgeInsets.all(16),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        decoration: BoxDecoration(
                          color: Colors.grey[100],
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: DropdownButton<String>(
                          value: _selectedPeriod,
                          isExpanded: true,
                          underline: const SizedBox(),
                          items: ['Haftalık', 'Aylık', 'Tüm Zamanlar']
                              .map((period) => DropdownMenuItem(
                                    value: period,
                                    child: Text(period),
                                  ))
                              .toList(),
                          onChanged: (value) {
                            setState(() {
                              _selectedPeriod = value!;
                            });
                          },
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Lider tablosu
              _buildLeaderboard(),

              const SizedBox(height: 32),
            ],
          ),
        );
      },
    );
  }

  // Lider tablosunu oluştur
  Widget _buildLeaderboard() {
    final leaderboard = _leaderboardService.getLeaderboard(_selectedPeriod);
    final currentUser = _leaderboardService.getCurrentUser();

    if (leaderboard.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Text(
            'Henüz lider tablosu verisi yok',
            style: TextStyle(color: Colors.grey[600]),
          ),
        ),
      );
    }

    return Column(
      children: [
        // İlk 3 podium
        if (leaderboard.length >= 3) _buildTopThreeReal(leaderboard),
        const SizedBox(height: 16),

        // Geri kalan liste
        ListView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: leaderboard.length > 3 ? leaderboard.length - 3 : 0,
          itemBuilder: (context, index) {
            final user = leaderboard[index + 3];
            final rank = index + 4;
            final isCurrentUser = user.id == currentUser?.id;
            final avatar = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';

            return Card(
              margin: const EdgeInsets.only(bottom: 8),
              color: isCurrentUser ? AppTheme.primaryYellow.withOpacity(0.1) : null,
              child: ListTile(
                leading: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: Colors.grey[300],
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          '$rank',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                    ),
                    const SizedBox(width: 12),
                    Container(
                      width: 40,
                      height: 40,
                      decoration: BoxDecoration(
                        color: AppTheme.primaryYellow.withOpacity(0.3),
                        shape: BoxShape.circle,
                      ),
                      child: Center(
                        child: Text(
                          avatar,
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                title: Row(
                  children: [
                    Text(
                      user.name,
                      style: TextStyle(
                        fontWeight: isCurrentUser ? FontWeight.bold : FontWeight.normal,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: AppTheme.primaryYellow,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Text(
                          'SİZ',
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                    const SizedBox(width: 8),
                    ...user.badges.map<Widget>((badge) => Text(badge)).toList(),
                  ],
                ),
                trailing: Text(
                  '${user.getPoints(_selectedPeriod)} ⭐',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            );
          },
        ),
      ],
    );
  }

  // İlk 3 podium (gerçek veriler)
  Widget _buildTopThreeReal(List<LeaderboardUser> leaderboard) {
    return Container(
      height: 200,
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // 2. sıra
          Expanded(
            child: _buildPodiumItemReal(
              leaderboard[1],
              rank: 2,
              height: 140,
              isCenter: false,
            ),
          ),
          const SizedBox(width: 8),
          // 1. sıra
          Expanded(
            child: _buildPodiumItemReal(
              leaderboard[0],
              rank: 1,
              height: 160,
              isCenter: true,
            ),
          ),
          const SizedBox(width: 8),
          // 3. sıra
          Expanded(
            child: _buildPodiumItemReal(
              leaderboard[2],
              rank: 3,
              height: 120,
              isCenter: false,
            ),
          ),
        ],
      ),
    );
  }

  // Podium kartı (gerçek veriler)
  Widget _buildPodiumItemReal(
    LeaderboardUser user, {
    required int rank,
    required double height,
    required bool isCenter,
  }) {
    final avatar = user.name.isNotEmpty ? user.name[0].toUpperCase() : '?';
    final points = user.getPoints(_selectedPeriod);

    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        if (isCenter)
          const Icon(
            Icons.emoji_events,
            color: Colors.amber,
            size: 32,
          ),
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: _getRankColor(rank),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 3),
            boxShadow: [
              BoxShadow(
                color: _getRankColor(rank).withOpacity(0.5),
                blurRadius: 10,
              ),
            ],
          ),
          child: Center(
            child: Text(
              avatar,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          user.name,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
          textAlign: TextAlign.center,
        ),
        Text(
          '$points ⭐',
          style: TextStyle(fontSize: 11, color: Colors.grey[600]),
        ),
        const SizedBox(height: 8),
        Container(
          width: double.infinity,
          height: height,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getRankColor(rank),
                _getRankColor(rank).withOpacity(0.7),
              ],
            ),
            borderRadius: const BorderRadius.only(
              topLeft: Radius.circular(8),
              topRight: Radius.circular(8),
            ),
          ),
          child: Center(
            child: Text(
              '$rank',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }

  IconData _getCategoryIcon(String category) {
    switch (category) {
      case 'Namaz':
        return Icons.mosque;
      case 'Kur\'an':
        return Icons.menu_book;
      case 'Zikir':
        return Icons.timeline;
      case 'Sure Ezberi':
        return Icons.book;
      default:
        return Icons.star;
    }
  }
}
