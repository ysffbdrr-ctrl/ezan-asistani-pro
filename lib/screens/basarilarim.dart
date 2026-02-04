import 'package:flutter/material.dart';
import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:share_plus/share_plus.dart';

class Basarilarim extends StatefulWidget {
  const Basarilarim({Key? key}) : super(key: key);

  @override
  State<Basarilarim> createState() => _BasarilarimState();
}

class _BasarilarimState extends State<Basarilarim> {
  Set<String> _unlockedAchievements = {};
  String _selectedCategory = 'Tümü';

  final List<Map<String, dynamic>> _achievements = [
    // Namaz Başarıları
    {
      'id': 'namaz_1',
      'category': 'Namaz',
      'title': 'İlk Adım',
      'description': 'İlk namazını kıl',
      'icon': Icons.mosque,
      'color': Colors.green,
      'points': 10,
      'requirement': 1,
      'currentProgress': 0,
    },
    {
      'id': 'namaz_7',
      'category': 'Namaz',
      'title': 'Haftalık İbadet',
      'description': '7 gün üst üste namaz kıl',
      'icon': Icons.calendar_today,
      'color': Colors.green,
      'points': 50,
      'requirement': 7,
      'currentProgress': 0,
    },
    {
      'id': 'namaz_30',
      'category': 'Namaz',
      'title': 'Aylık Devamlılık',
      'description': '30 gün üst üste namaz kıl',
      'icon': Icons.calendar_month,
      'color': Colors.green,
      'points': 100,
      'requirement': 30,
      'currentProgress': 0,
    },
    {
      'id': 'namaz_100',
      'category': 'Namaz',
      'title': 'Namaz Ustası',
      'description': 'Toplam 100 vakit namaz kıl',
      'icon': Icons.stars,
      'color': Colors.green,
      'points': 200,
      'requirement': 100,
      'currentProgress': 0,
    },
    
    // Kur'an Başarıları
    {
      'id': 'kuran_1',
      'category': 'Kur\'an',
      'title': 'İlk Sayfa',
      'description': 'Kur\'an-ı Kerim\'den 1 sayfa oku',
      'icon': Icons.menu_book,
      'color': Colors.blue,
      'points': 10,
      'requirement': 1,
      'currentProgress': 0,
    },
    {
      'id': 'kuran_10',
      'category': 'Kur\'an',
      'title': 'Okuma Alışkanlığı',
      'description': '10 sayfa Kur\'an oku',
      'icon': Icons.auto_stories,
      'color': Colors.blue,
      'points': 30,
      'requirement': 10,
      'currentProgress': 0,
    },
    {
      'id': 'kuran_cuz',
      'category': 'Kur\'an',
      'title': 'Cüz Tamamlama',
      'description': '1 cüz (20 sayfa) tamamla',
      'icon': Icons.book,
      'color': Colors.blue,
      'points': 50,
      'requirement': 20,
      'currentProgress': 0,
    },
    {
      'id': 'kuran_hatim',
      'category': 'Kur\'an',
      'title': 'Hatim',
      'description': 'Kur\'an-ı Kerim hatmi yap',
      'icon': Icons.emoji_events,
      'color': Colors.blue,
      'points': 1000,
      'requirement': 604,
      'currentProgress': 0,
    },
    
    // Sure Ezberi Başarıları
    {
      'id': 'ezber_1',
      'category': 'Ezber',
      'title': 'İlk Sure',
      'description': 'İlk sureni ezberle',
      'icon': Icons.psychology,
      'color': Colors.purple,
      'points': 20,
      'requirement': 1,
      'currentProgress': 0,
    },
    {
      'id': 'ezber_3',
      'category': 'Ezber',
      'title': 'Üç Sure',
      'description': '3 sure ezberle',
      'icon': Icons.psychology_alt,
      'color': Colors.purple,
      'points': 50,
      'requirement': 3,
      'currentProgress': 0,
    },
    {
      'id': 'ezber_10',
      'category': 'Ezber',
      'title': 'Hafızlık Yolu',
      'description': '10 sure ezberle',
      'icon': Icons.school,
      'color': Colors.purple,
      'points': 150,
      'requirement': 10,
      'currentProgress': 0,
    },
    
    // Zikir Başarıları
    {
      'id': 'zikir_100',
      'category': 'Zikir',
      'title': 'Zikir Başlangıcı',
      'description': '100 zikir çek',
      'icon': Icons.timeline,
      'color': Colors.orange,
      'points': 10,
      'requirement': 100,
      'currentProgress': 0,
    },
    {
      'id': 'zikir_1000',
      'category': 'Zikir',
      'title': 'Bin Zikir',
      'description': '1000 zikir çek',
      'icon': Icons.trending_up,
      'color': Colors.orange,
      'points': 50,
      'requirement': 1000,
      'currentProgress': 0,
    },
    {
      'id': 'zikir_10000',
      'category': 'Zikir',
      'title': 'Zikir Ustası',
      'description': '10.000 zikir çek',
      'icon': Icons.military_tech,
      'color': Colors.orange,
      'points': 200,
      'requirement': 10000,
      'currentProgress': 0,
    },
    
    // Dua Başarıları
    {
      'id': 'dua_7',
      'category': 'Dua',
      'title': 'Haftalık Dua',
      'description': '7 gün üst üste dua et',
      'icon': Icons.favorite,
      'color': Colors.red,
      'points': 30,
      'requirement': 7,
      'currentProgress': 0,
    },
    {
      'id': 'dua_30',
      'category': 'Dua',
      'title': 'Dua Alışkanlığı',
      'description': '30 gün üst üste dua et',
      'icon': Icons.favorite_border,
      'color': Colors.red,
      'points': 100,
      'requirement': 30,
      'currentProgress': 0,
    },
    
    // Öğrenme Başarıları
    {
      'id': 'ogrenme_alfabe',
      'category': 'Öğrenme',
      'title': 'Arapça Alfabesi',
      'description': 'Arapça alfabesini öğren',
      'icon': Icons.abc,
      'color': Colors.teal,
      'points': 50,
      'requirement': 1,
      'currentProgress': 0,
    },
    {
      'id': 'ogrenme_tecvid',
      'category': 'Öğrenme',
      'title': 'Tecvid Uzmanı',
      'description': 'Tecvid kurallarını öğren',
      'icon': Icons.rule,
      'color': Colors.teal,
      'points': 75,
      'requirement': 1,
      'currentProgress': 0,
    },
    
    // Sosyal Başarılar
    {
      'id': 'sosyal_paylas',
      'category': 'Sosyal',
      'title': 'İlk Paylaşım',
      'description': 'İlerlemeni paylaş',
      'icon': Icons.share,
      'color': Colors.pink,
      'points': 15,
      'requirement': 1,
      'currentProgress': 0,
    },
    {
      'id': 'sosyal_arkadas',
      'category': 'Sosyal',
      'title': 'Arkadaş Çevresi',
      'description': '5 arkadaş ekle',
      'icon': Icons.people,
      'color': Colors.pink,
      'points': 50,
      'requirement': 5,
      'currentProgress': 0,
    },
    
    // Özel Başarılar
    {
      'id': 'ozel_ramazan',
      'category': 'Özel',
      'title': 'Ramazan Kahramanı',
      'description': 'Ramazan ayını tamamla',
      'icon': Icons.star,
      'color': Colors.amber,
      'points': 500,
      'requirement': 30,
      'currentProgress': 0,
      'isSpecial': true,
    },
    {
      'id': 'ozel_hac',
      'category': 'Özel',
      'title': 'Hac Hazırlığı',
      'description': 'Hac rehberini tamamla',
      'icon': Icons.flight_takeoff,
      'color': Colors.amber,
      'points': 100,
      'requirement': 1,
      'currentProgress': 0,
      'isSpecial': true,
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadAchievements();
  }

  Future<void> _loadAchievements() async {
    final prefs = await SharedPreferences.getInstance();
    
    setState(() {
      _unlockedAchievements = (prefs.getStringList('unlocked_achievements') ?? []).toSet();
      
      // İlerleme verilerini yükle
      for (var achievement in _achievements) {
        switch (achievement['category']) {
          case 'Namaz':
            achievement['currentProgress'] = prefs.getInt('namaz_kilinan_toplam') ?? 0;
            break;
          case 'Kur\'an':
            achievement['currentProgress'] = prefs.getInt('kuran_okunan_sayfa') ?? 0;
            break;
          case 'Zikir':
            achievement['currentProgress'] = prefs.getInt('toplam_zikir') ?? 0;
            break;
          case 'Ezber':
            achievement['currentProgress'] = prefs.getInt('ezberlenenen_sure') ?? 0;
            break;
          case 'Dua':
            achievement['currentProgress'] = prefs.getInt('dua_edilen_gun') ?? 0;
            break;
        }
        
        // Başarı otomatik açılsın mı kontrol et
        if (achievement['currentProgress'] >= achievement['requirement'] &&
            !_unlockedAchievements.contains(achievement['id'])) {
          _unlockAchievement(achievement['id']);
        }
      }
    });
  }

  Future<void> _unlockAchievement(String achievementId) async {
    final prefs = await SharedPreferences.getInstance();
    _unlockedAchievements.add(achievementId);
    await prefs.setStringList('unlocked_achievements', _unlockedAchievements.toList());
    
    // Puan ekle
    final achievement = _achievements.firstWhere((a) => a['id'] == achievementId);
    final currentPoints = prefs.getInt('toplam_puan') ?? 0;
    await prefs.setInt('toplam_puan', currentPoints + (achievement['points'] as int));
  }

  void _shareAchievement(Map<String, dynamic> achievement) {
    final message = '''
🏆 Başarı Kazandım! 🏆

${achievement['title']}
${achievement['description']}

⭐ ${achievement['points']} Puan

#EzanAsistaniPro #BasariKazandim
    ''';
    
    Share.share(message, subject: 'Ezan Asistanı Pro - Başarı');
  }

  List<String> get _categories {
    final categories = ['Tümü'];
    categories.addAll(_achievements.map((a) => a['category'] as String).toSet());
    return categories;
  }

  List<Map<String, dynamic>> get _filteredAchievements {
    if (_selectedCategory == 'Tümü') {
      return _achievements;
    }
    return _achievements.where((a) => a['category'] == _selectedCategory).toList();
  }

  @override
  Widget build(BuildContext context) {
    final unlockedCount = _unlockedAchievements.length;
    final totalCount = _achievements.length;
    final totalPoints = _achievements
        .where((a) => _unlockedAchievements.contains(a['id']))
        .fold(0, (sum, a) => sum + (a['points'] as int));

    return SingleChildScrollView(
      child: Column(
        children: [
          // İstatistik Kartları
          Container(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.emoji_events,
                            color: AppTheme.primaryYellow,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$unlockedCount/$totalCount',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Başarı',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
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
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          const Icon(
                            Icons.stars,
                            color: Colors.amber,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            totalPoints.toString(),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Toplam Puan',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
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
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        children: [
                          Icon(
                            Icons.percent,
                            color: Colors.green,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '${((unlockedCount / totalCount) * 100).toStringAsFixed(0)}%',
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            'Tamamlanan',
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Kategori Filtreleri
          Container(
            height: 40,
            margin: const EdgeInsets.symmetric(vertical: 8),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.symmetric(horizontal: 16),
              itemCount: _categories.length,
              itemBuilder: (context, index) {
                final category = _categories[index];
                final isSelected = category == _selectedCategory;
                
                return Padding(
                  padding: const EdgeInsets.only(right: 8),
                  child: FilterChip(
                    label: Text(category),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedCategory = category;
                      });
                    },
                    backgroundColor: Colors.grey[200],
                    selectedColor: AppTheme.primaryYellow,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : Colors.black,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                  ),
                );
              },
            ),
          ),

          // Başarılar Listesi
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            padding: const EdgeInsets.all(16),
            itemCount: _filteredAchievements.length,
            itemBuilder: (context, index) {
              final achievement = _filteredAchievements[index];
              final isUnlocked = _unlockedAchievements.contains(achievement['id']);
              final progress = achievement['currentProgress'] / achievement['requirement'];
              final isSpecial = achievement['isSpecial'] ?? false;
              
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                elevation: isUnlocked ? 4 : 1,
                child: InkWell(
                  onTap: isUnlocked
                      ? () => _shareAchievement(achievement)
                      : null,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      gradient: isUnlocked
                          ? LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                achievement['color'].withOpacity(0.1),
                                achievement['color'].withOpacity(0.05),
                              ],
                            )
                          : null,
                      border: isSpecial
                          ? Border.all(
                              color: Colors.amber.withOpacity(0.5),
                              width: 2,
                            )
                          : null,
                    ),
                    child: Column(
                      children: [
                        Row(
                          children: [
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                color: isUnlocked
                                    ? achievement['color']
                                    : Colors.grey[300],
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                achievement['icon'],
                                color: isUnlocked ? Colors.white : Colors.grey[600],
                                size: 28,
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        achievement['title'],
                                        style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold,
                                          color: isUnlocked ? null : Colors.grey,
                                        ),
                                      ),
                                      if (isSpecial) ...[
                                        const SizedBox(width: 8),
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amber,
                                          size: 16,
                                        ),
                                      ],
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    achievement['description'],
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  if (!isUnlocked) ...[
                                    Row(
                                      children: [
                                        Expanded(
                                          child: LinearProgressIndicator(
                                            value: progress.clamp(0.0, 1.0),
                                            backgroundColor: Colors.grey[300],
                                            valueColor: AlwaysStoppedAnimation<Color>(
                                              achievement['color'],
                                            ),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Text(
                                          '${achievement['currentProgress']}/${achievement['requirement']}',
                                          style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ],
                              ),
                            ),
                            Column(
                              children: [
                                if (isUnlocked)
                                  Icon(
                                    Icons.check_circle,
                                    color: Colors.green,
                                    size: 28,
                                  )
                                else
                                  Icon(
                                    Icons.lock_outline,
                                    color: Colors.grey[400],
                                    size: 28,
                                  ),
                                const SizedBox(height: 4),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8,
                                    vertical: 4,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isUnlocked
                                        ? achievement['color'].withOpacity(0.2)
                                        : Colors.grey[200],
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: Text(
                                    '+${achievement['points']}',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold,
                                      color: isUnlocked
                                          ? achievement['color']
                                          : Colors.grey[600],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        if (isUnlocked) ...[
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: () => _shareAchievement(achievement),
                              icon: const Icon(Icons.share, size: 16),
                              label: const Text('Başarıyı Paylaş'),
                              style: OutlinedButton.styleFrom(
                                foregroundColor: achievement['color'],
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
