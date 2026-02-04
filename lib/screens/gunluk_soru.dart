import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:intl/intl.dart';
import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:ezan_asistani/services/gamification_service.dart';

class GunlukSoru extends StatefulWidget {
  const GunlukSoru({Key? key}) : super(key: key);

  @override
  State<GunlukSoru> createState() => _GunlukSoruState();
}

class _GunlukSoruState extends State<GunlukSoru> {
  Map<String, dynamic>? _todayQuestion;
  bool _hasAnsweredToday = false;
  bool _answered = false;
  int? _selectedAnswer;
  int _streak = 0;

  @override
  void initState() {
    super.initState();
    _loadTodayQuestion();
  }

  Future<void> _loadTodayQuestion() async {
    final prefs = await SharedPreferences.getInstance();
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    // Bugün cevap verilmiş mi kontrol et
    String? answeredDate = prefs.getString('last_daily_question_date');
    _hasAnsweredToday = answeredDate == today;
    
    // Streak yükle
    _streak = prefs.getInt('daily_question_streak') ?? 0;

    // Bugünün sorusunu seç
    final allQuestions = _getAllDailyQuestions();
    int dayOfYear = DateTime.now().difference(DateTime(DateTime.now().year, 1, 1)).inDays;
    int questionIndex = dayOfYear % allQuestions.length;

    setState(() {
      _todayQuestion = allQuestions[questionIndex];
    });
  }

  Future<void> _answerQuestion(int selectedIndex) async {
    if (_answered || _hasAnsweredToday) return;

    setState(() {
      _selectedAnswer = selectedIndex;
      _answered = true;
    });

    final prefs = await SharedPreferences.getInstance();
    String today = DateFormat('yyyy-MM-dd').format(DateTime.now());
    
    bool isCorrect = selectedIndex == _todayQuestion!['dogruCevap'];
    
    if (isCorrect) {
      // Puan ekle
      await GamificationService.addPoints(
        'daily_question',
        GamificationService.pointsPerDailyQuestion,
      );
      
      // Streak güncelle
      setState(() {
        _streak++;
      });
      await prefs.setInt('daily_question_streak', _streak);
    } else {
      // Streak sıfırla
      setState(() {
        _streak = 0;
      });
      await prefs.setInt('daily_question_streak', 0);
    }

    await prefs.setString('last_daily_question_date', today);
    
    setState(() {
      _hasAnsweredToday = true;
    });

    // Sonuç göster
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        _showResultDialog(isCorrect);
      }
    });
  }

  void _showResultDialog(bool isCorrect) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(
              isCorrect ? '✅' : '❌',
              style: const TextStyle(fontSize: 32),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(isCorrect ? 'Doğru!' : 'Yanlış!'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (isCorrect) ...[
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppTheme.lightYellow,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.stars, color: AppTheme.darkYellow),
                    const SizedBox(width: 8),
                    Text(
                      '+${GamificationService.pointsPerDailyQuestion} Puan!',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),
              if (_streak > 1) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.orange[50],
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      const Text('🔥', style: TextStyle(fontSize: 24)),
                      const SizedBox(width: 8),
                      Text(
                        '$_streak gün üst üste doğru!',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ),
              ],
            ],
            const SizedBox(height: 16),
            const Text(
              'Açıklama:',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(_todayQuestion!['aciklama']),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getAllDailyQuestions() {
    return [
      {
        'soru': 'Hangi peygambere "Halilullah" (Allah\'ın dostu) denir?',
        'secenekler': ['Hz. Musa', 'Hz. İbrahim', 'Hz. Muhammed', 'Hz. İsa'],
        'dogruCevap': 1,
        'aciklama': 'Hz. İbrahim\'e "Halilullah" yani Allah\'ın dostu denir. O, Allah\'a olan teslimiyet ve imanıyla örnek bir peygamberdir.',
        'kategori': 'Peygamberler',
      },
      {
        'soru': 'Kur\'an-ı Kerim\'in ilk inen ayeti hangisidir?',
        'secenekler': ['Fatiha', 'Alak', 'Nas', 'İhlas'],
        'dogruCevap': 1,
        'aciklama': 'İlk inen ayet Alak suresinin ilk beş ayetidir. "Oku, Rabbinin adıyla..." şeklinde başlar.',
        'kategori': 'Kur\'an',
      },
      {
        'soru': 'İslam\'da namazların ilki hangisidir?',
        'secenekler': ['Sabah', 'Öğle', 'İkindi', 'Yatsı'],
        'dogruCevap': 1,
        'aciklama': 'Günlük beş vakit namazın ilki öğle namazıdır. Miraç gecesinde farz kılınmıştır.',
        'kategori': 'İbadet',
      },
      {
        'soru': 'Hz. Muhammed kaç yaşında peygamber olmuştur?',
        'secenekler': ['30', '35', '40', '45'],
        'dogruCevap': 2,
        'aciklama': 'Hz. Muhammed 40 yaşında Hira mağarasında ilk vahyi alarak peygamberlik görevine başlamıştır.',
        'kategori': 'Siyer',
      },
      {
        'soru': 'Hangi sahabi "Esedullah" (Allah\'ın Arslanı) lakabıyla anılır?',
        'secenekler': ['Hz. Ebubekir', 'Hz. Ömer', 'Hz. Ali', 'Hz. Osman'],
        'dogruCevap': 2,
        'aciklama': 'Hz. Ali, cesareti ve kahramanlığı nedeniyle "Esedullah" lakabıyla anılır.',
        'kategori': 'Sahabe',
      },
      {
        'soru': 'Kabe ilk kez kim tarafından inşa edilmiştir?',
        'secenekler': ['Hz. Muhammed', 'Hz. İbrahim', 'Hz. İsmail', 'Hz. Adem'],
        'dogruCevap': 3,
        'aciklama': 'Kabe\'nin ilk yapımını Hz. Adem yapmıştır. Hz. İbrahim ve Hz. İsmail ise Kabe\'yi yeniden inşa etmiştir.',
        'kategori': 'Tarih',
      },
      {
        'soru': 'İslam\'da zekat malın yüzde kaçıdır?',
        'secenekler': ['%1', '%2.5', '%5', '%10'],
        'dogruCevap': 1,
        'aciklama': 'Zekat, nisaba ulaşmış ve üzerinden bir yıl geçmiş malın %2.5\'idir.',
        'kategori': 'İbadet',
      },
      {
        'soru': 'Hangi ayda oruç tutulur?',
        'secenekler': ['Recep', 'Şaban', 'Ramazan', 'Şevval'],
        'dogruCevap': 2,
        'aciklama': 'Ramazan ayında oruç tutmak İslam\'ın beş şartından biridir.',
        'kategori': 'İbadet',
      },
      {
        'soru': 'İslam\'ın yayılmaya başladığı ilk şehir hangisidir?',
        'secenekler': ['Medine', 'Mekke', 'Taif', 'Kudüs'],
        'dogruCevap': 1,
        'aciklama': 'İslam, Mekke\'de doğmuş ancak Medine\'de gelişerek yayılmaya başlamıştır.',
        'kategori': 'Tarih',
      },
      {
        'soru': 'Kur\'an-ı Kerim kaç cüzden oluşur?',
        'secenekler': ['20', '25', '30', '35'],
        'dogruCevap': 2,
        'aciklama': 'Kur\'an-ı Kerim 30 cüzden (parti) oluşur.',
        'kategori': 'Kur\'an',
      },
    ];
  }

  @override
  Widget build(BuildContext context) {
    if (_todayQuestion == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Günün Sorusu'),
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Tarih ve Streak Kartı
          Card(
            elevation: 4,
            color: AppTheme.primaryYellow,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Bugünün Sorusu',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        DateFormat('d MMMM yyyy', 'tr_TR').format(DateTime.now()),
                        style: const TextStyle(
                          color: Colors.black87,
                        ),
                      ),
                    ],
                  ),
                  if (_streak > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                      decoration: BoxDecoration(
                        color: Colors.orange,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: [
                          const Text('🔥', style: TextStyle(fontSize: 20)),
                          const SizedBox(width: 4),
                          Text(
                            '$_streak',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          if (_hasAnsweredToday && !_answered) ...[
            // Bugün zaten cevaplandı mesajı
            Card(
              color: Colors.green[50],
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  children: [
                    Icon(
                      Icons.check_circle,
                      size: 64,
                      color: Colors.green[700],
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Bugünkü Soruyu Cevapladınız!',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Yarın yeni bir soru için geri gelin!',
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
          ] else ...[
            // Kategori
            Chip(
              label: Text(_todayQuestion!['kategori']),
              backgroundColor: AppTheme.lightYellow,
            ),
            const SizedBox(height: 16),

            // Soru
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text(
                  _todayQuestion!['soru'],
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Seçenekler
            ...List.generate(
              _todayQuestion!['secenekler'].length,
              (index) {
                bool isSelected = _selectedAnswer == index;
                bool isCorrect = index == _todayQuestion!['dogruCevap'];
                bool showResult = _answered;

                Color? backgroundColor;
                Color? textColor;
                IconData? icon;

                if (showResult) {
                  if (isCorrect) {
                    backgroundColor = Colors.green[100];
                    textColor = Colors.green[900];
                    icon = Icons.check_circle;
                  } else if (isSelected) {
                    backgroundColor = Colors.red[100];
                    textColor = Colors.red[900];
                    icon = Icons.cancel;
                  }
                } else if (isSelected) {
                  backgroundColor = AppTheme.lightYellow;
                  textColor = Colors.black;
                }

                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: InkWell(
                    onTap: () => _answerQuestion(index),
                    borderRadius: BorderRadius.circular(12),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: backgroundColor ?? Colors.grey[200],
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: showResult && isCorrect
                              ? Colors.green
                              : (showResult && isSelected
                                  ? Colors.red
                                  : Colors.transparent),
                          width: 2,
                        ),
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: Text(
                              _todayQuestion!['secenekler'][index],
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: textColor,
                              ),
                            ),
                          ),
                          if (showResult && (isCorrect || isSelected))
                            Icon(
                              icon,
                              color: isCorrect ? Colors.green : Colors.red,
                            ),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
          ],

          const SizedBox(height: 24),

          // Bilgilendirme
          Card(
            color: AppTheme.lightYellow,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(
                    Icons.lightbulb_outline,
                    color: AppTheme.darkYellow,
                    size: 40,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Her Gün Yeni Bir Soru',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Günlük soruyu doğru cevaplayarak puan kazanın ve bilginizi test edin!',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
