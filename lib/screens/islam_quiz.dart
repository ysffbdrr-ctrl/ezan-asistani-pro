import 'package:flutter/material.dart';
import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:ezan_asistani/services/gamification_service.dart';
import 'package:ezan_asistani/widgets/admob_banner.dart';
import 'dart:math';

class IslamQuiz extends StatefulWidget {
  const IslamQuiz({Key? key}) : super(key: key);

  @override
  State<IslamQuiz> createState() => _IslamQuizState();
}

class _IslamQuizState extends State<IslamQuiz> {
  int _currentQuestion = 0;
  int _score = 0;
  int _totalQuestions = 10;
  List<Map<String, dynamic>> _questions = [];
  bool _answered = false;
  int? _selectedAnswer;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _showQuestionCountDialog();
    });
  }

  void _showQuestionCountDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Row(
            children: [
              Icon(Icons.quiz, color: AppTheme.primaryYellow),
              SizedBox(width: 8),
              Text('Quiz Zorluk Seviyesi'),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Kaç soru cevaplamak istiyorsunuz?',
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 20),
              _buildQuestionOption(10, '10 Soru'),
              _buildQuestionOption(20, '20 Soru'),
              _buildQuestionOption(30, '30 Soru'),
              _buildQuestionOption(40, '40 Soru'),
              _buildQuestionOption(50, '50 Soru'),
            ],
          ),
        );
      },
    );
  }

  Widget _buildQuestionOption(int count, String label) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: ElevatedButton(
        onPressed: () {
          Navigator.pop(context);
          setState(() {
            _totalQuestions = count;
          });
          _generateQuestions();
        },
        style: ElevatedButton.styleFrom(
          backgroundColor: AppTheme.primaryYellow,
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 48),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Text(
          label,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  void _generateQuestions() {
    final allQuestions = _getAllQuestions();
    allQuestions.shuffle(Random());
    setState(() {
      _questions = allQuestions.take(_totalQuestions).toList();
    });
  }

  List<Map<String, dynamic>> _getAllQuestions() {
    return [
      {
        'soru': 'Peygamberimizin adı nedir?',
        'secenekler': [
          'Muhammed ibn Abdullah',
          'Muhammed Mustafa',
          'Muhammed ibn Kasım',
          'Muhammed ibn Musa'
        ],
        'dogruCevap': 0,
        'kategori': 'Siyer'
      },
      {
        'soru': 'İslam\'ın kutsal kitabı hangisidir?',
        'secenekler': ['Tevrat', 'İncil', 'Kur\'an', 'Zebur'],
        'dogruCevap': 2,
        'kategori': 'Kur\'an'
      },
      {
        'soru': 'Müslümanlar namaz kılmak için hangi yöne yönelirler?',
        'secenekler': ['Kuzey', 'Güney', 'Doğu', 'Kıble (Mekke) yönü'],
        'dogruCevap': 3,
        'kategori': 'İbadetler'
      },
      {
        'soru': 'Günde kaç vakit namaz kılınır?',
        'secenekler': ['2 vakit', '3 vakit', '4 vakit', '5 vakit'],
        'dogruCevap': 3,
        'kategori': 'İbadetler'
      },
      {
        'soru': 'Peygamberimiz hangi şehirde doğdu?',
        'secenekler': ['Medine', 'Taif', 'Mekke', 'Kudüs'],
        'dogruCevap': 2,
        'kategori': 'Siyer'
      },
      {
        'soru': 'Ramazan ayında Müslümanlar ne yaparlar?',
        'secenekler': [
          'Bayram kutlarlar',
          'Oruç tutarlar',
          'Hac yaparlar',
          'Kurban kesarlar'
        ],
        'dogruCevap': 1,
        'kategori': 'İbadetler'
      },
      {
        'soru': 'Müslümanların en kutsal yeri hangisidir?',
        'secenekler': ['Mescid-i Aksa', 'Kabe', 'Medine Mescidi', 'Kudüs'],
        'dogruCevap': 1,
        'kategori': 'Temel'
      },
      {
        'soru': 'Camide ezan kim tarafından okunur?',
        'secenekler': ['Hakim', 'Müezzin', 'İmam', 'Molla'],
        'dogruCevap': 1,
        'kategori': 'İbadetler'
      },
      {
        'soru': 'Peygamberimizin ilk eşi Hz. Hatice kaç yıl onunla yaşadı?',
        'secenekler': ['15 yıl', '20 yıl', '25 yıl', '30 yıl'],
        'dogruCevap': 2,
        'kategori': 'Siyer'
      },
      {
        'soru': 'Ramazan ayından sonra hangi bayram kutlanır?',
        'secenekler': [
          'Kurban Bayramı',
          'Fitır Bayramı',
          'Mevlid Kandili',
          'Kadir Gecesi'
        ],
        'dogruCevap': 1,
        'kategori': 'Bayramlar'
      },
      {
        'soru': 'Kurban Bayramı hangi ayda yapılır?',
        'secenekler': ['Ramazan', 'Şaban', 'Zilhicce', 'Şevval'],
        'dogruCevap': 2,
        'kategori': 'Bayramlar'
      },
      {
        'soru': 'Sabah namazı kaç rekat kılınır?',
        'secenekler': ['2 rekat', '3 rekat', '4 rekat', '5 rekat'],
        'dogruCevap': 0,
        'kategori': 'İbadetler'
      },
      {
        'soru': 'Öğle namazının farzı kaç rekat kılınır?',
        'secenekler': ['2 rekat', '3 rekat', '4 rekat', '5 rekat'],
        'dogruCevap': 2,
        'kategori': 'İbadetler'
      },
      {
        'soru': 'İkindi namazının farzı kaç rekat kılınır?',
        'secenekler': ['2 rekat', '3 rekat', '4 rekat', '5 rekat'],
        'dogruCevap': 2,
        'kategori': 'İbadetler'
      },
      {
        'soru': 'Akşam namazının farzı kaç rekat kılınır?',
        'secenekler': ['2 rekat', '3 rekat', '4 rekat', '5 rekat'],
        'dogruCevap': 1,
        'kategori': 'İbadetler'
      },
      {
        'soru': 'Yatsı namazının farzı kaç rekat kılınır?',
        'secenekler': ['2 rekat', '3 rekat', '4 rekat', '5 rekat'],
        'dogruCevap': 2,
        'kategori': 'İbadetler'
      },
      {
        'soru': 'Cuma namazı hangi gün kılınır?',
        'secenekler': ['Pazartesi', 'Cuma', 'Cumartesi', 'Pazar'],
        'dogruCevap': 1,
        'kategori': 'İbadetler'
      },
      {
        'soru': 'Peygamberimizin babası Abdullah kaç yaşında vefat etti?',
        'secenekler': ['20 yaş', '25 yaş', '30 yaş', '35 yaş'],
        'dogruCevap': 1,
        'kategori': 'Siyer'
      },
      {
        'soru':
            'Peygamberimizin annesi Amina hanımdan sonra kimin bakımında büyüdü?',
        'secenekler': ['Halası', 'Teyzesi', 'Anneanesi', 'Amcası Ebu Talib'],
        'dogruCevap': 3,
        'kategori': 'Siyer'
      },
      {
        'soru': 'Hz. Bilal\'in görevi nedir?',
        'secenekler': [
          'Namaz kılmak',
          'Ezan okumak',
          'Kur\'an öğretmek',
          'Hadis anlatmak'
        ],
        'dogruCevap': 1,
        'kategori': 'Sahabe'
      },
      {
        'soru': 'Oruç tutmak hangi ayda farz kılındı?',
        'secenekler': ['Recep', 'Şaban', 'Ramazan', 'Şevval'],
        'dogruCevap': 2,
        'kategori': 'İbadetler'
      },
      {
        'soru': 'İslam\'ın ilk müezzini kimdir?',
        'secenekler': ['Hz. Bilal', 'Hz. Ali', 'Hz. Ömer', 'Hz. Osman'],
        'dogruCevap': 0,
        'kategori': 'Sahabe'
      },
      {
        'soru': 'Kabe nerede bulunur?',
        'secenekler': ['Medine\'de', 'Mekke\'de', 'Kudüs\'te', 'Taif\'te'],
        'dogruCevap': 1,
        'kategori': 'Temel Bilgiler'
      },
      {
        'soru': 'Zekat oranı malın yüzde kaçıdır?',
        'secenekler': ['%1', '%2.5', '%5', '%10'],
        'dogruCevap': 1,
        'kategori': 'İbadetler'
      },
      {
        'soru': 'Kur\'an\'ın en kısa suresi kaç ayetten oluşur?',
        'secenekler': ['2 ayet', '3 ayet', '4 ayet', '5 ayet'],
        'dogruCevap': 1,
        'kategori': 'Kur\'an'
      },
      {
        'soru': 'Peygamberimiz kaç yaşında peygamberlik görevini aldı?',
        'secenekler': ['30 yaş', '35 yaş', '40 yaş', '45 yaş'],
        'dogruCevap': 2,
        'kategori': 'Siyer'
      },
      {
        'soru': 'Hac ibadeti hangi ayda yapılır?',
        'secenekler': ['Muharrem', 'Zilhicce', 'Ramazan', 'Şaban'],
        'dogruCevap': 1,
        'kategori': 'İbadetler'
      },
      {
        'soru': 'Miraç olayı hangi şehirden başladı?',
        'secenekler': ['Mekke', 'Medine', 'Kudüs', 'Taif'],
        'dogruCevap': 0,
        'kategori': 'Siyer'
      },
      {
        'soru': 'Kadir Gecesi Ramazan ayının hangi gecesidir?',
        'secenekler': ['7. gece', '15. gece', '27. gece', '29. gece'],
        'dogruCevap': 2,
        'kategori': 'Bayramlar'
      },
      {
        'soru': 'Neden oruç tutulur?',
        'secenekler': [
          'Allah\'a yakınlaşmak',
          'Sabır ve disiplin kazanmak',
          'Sağlık için',
          'Hepsi'
        ],
        'dogruCevap': 1,
        'kategori': 'İbadetler'
      },
      {
        'soru': 'Hac ibadeti nedir?',
        'secenekler': [
          'Namaz',
          'Oruç',
          'Mekke\'ye gidip belirli ritüelleri yerine getirmek',
          'Dua'
        ],
        'dogruCevap': 2,
        'kategori': 'İbadetler'
      },
      {
        'soru': 'Abdest alırken hangi uzuvlar yıkanır?',
        'secenekler': [
          'eller, yüz, ayaklar',
          'Sadece yüz',
          'Tüm vücut',
          'Başı ve ayakları'
        ],
        'dogruCevap': 0,
        'kategori': 'İbadetler'
      },
      {
        'soru': 'Kur\'an kaç cüzden oluşur?',
        'secenekler': ['20 cüz', '30 cüz', '40 cüz', '50 cüz'],
        'dogruCevap': 1,
        'kategori': 'Kur\'an'
      },
      {
        'soru': 'Kur\'an kaç sure içerir?',
        'secenekler': ['100 sure', '114 sure', '120 sure', '130 sure'],
        'dogruCevap': 1,
        'kategori': 'Kur\'an'
      },
      {
        'soru': 'Fatiha suresi Kur\'an\'ın kaçıncı suresidir?',
        'secenekler': ['1. sure', '2. sure', '3. sure', '4. sure'],
        'dogruCevap': 0,
        'kategori': 'Kur\'an'
      },
      {
        'soru': 'İhlas suresi Kur\'an\'ın kaçıncı suresidir?',
        'secenekler': ['110. sure', '111. sure', '112. sure', '113. sure'],
        'dogruCevap': 2,
        'kategori': 'Kur\'an'
      },
      {
        'soru': 'Nas suresi Kur\'an\'ın kaçıncı suresidir?',
        'secenekler': ['112. sure', '113. sure', '114. sure', '115. sure'],
        'dogruCevap': 2,
        'kategori': 'Kur\'an'
      },
      {
        'soru': 'Mescit ile cami arasındaki fark nedir?',
        'secenekler': [
          'Mescit daha küçük ve cemaatsiz namaz kılınan yer',
          'Cami daha küçük',
          'Hiç fark yok',
          'Mescit sadece Cuma namazı için'
        ],
        'dogruCevap': 0,
        'kategori': 'Temel'
      },
      {
        'soru': 'Müezzin ne yapar?',
        'secenekler': [
          'Namaz kılar',
          'Ezan okur',
          'Kur\'an öğretir',
          'Hadis anlatır'
        ],
        'dogruCevap': 1,
        'kategori': 'Temel'
      },
      {
        'soru': 'Ezan ne zaman okunur?',
        'secenekler': ['Namaz vakti', 'Bayram', 'Cuma', 'Ramazan'],
        'dogruCevap': 0,
        'kategori': 'İbadetler'
      },
      {
        'soru': 'Dua ile namaz arasındaki fark nedir?',
        'secenekler': [
          'Dua herhangi bir zamanda yapılır, namaz belirli saatlerde',
          'Hiç fark yok',
          'Dua sadece Ramazan\'da yapılır',
          'Namaz daha önemlidir'
        ],
        'dogruCevap': 0,
        'kategori': 'Temel'
      },
      {
        'soru': 'Hicret ne demektir?',
        'secenekler': ['Göç etme', 'Savaş', 'Namaz', 'Oruç'],
        'dogruCevap': 0,
        'kategori': 'Siyer'
      },
      {
        'soru': 'Miraç ne demektir?',
        'secenekler': ['Göç', 'Gökyüzüne yükselme', 'Savaş', 'Yolculuk'],
        'dogruCevap': 1,
        'kategori': 'Siyer'
      },
      {
        'soru': 'Sahabe ne demektir?',
        'secenekler': ['Öğrenci', 'Peygamberin arkadaşı', 'Hakim', 'Asker'],
        'dogruCevap': 1,
        'kategori': 'Temel'
      },
      {
        'soru': 'Müslüman ne demektir?',
        'secenekler': [
          'İslam\'a inanıp itaat eden',
          'Namaz kılan',
          'Oruç tutan',
          'Hac yapan'
        ],
        'dogruCevap': 0,
        'kategori': 'Temel'
      },
      {
        'soru': 'İslam\'ın beş şartı nedir?',
        'secenekler': [
          'Namaz, Oruç, Hac, Zekat, Şehadet',
          'Namaz, Oruç, Hac, Zekat, Dua',
          'Namaz, Oruç, Hac, Sadaka, Dua',
          'Namaz, Oruç, Dua, Zekat, Sadaka'
        ],
        'dogruCevap': 0,
        'kategori': 'Temel'
      },
      {
        'soru': 'Fitır Bayramı ne zaman?',
        'secenekler': [
          'Ramazan başında',
          'Ramazan sonunda',
          'Zilhicce\'de',
          'Şaban\'da'
        ],
        'dogruCevap': 1,
        'kategori': 'Bayramlar'
      },
    ];
  }

  void _answerQuestion(int selectedIndex) {
    if (_answered) return;

    setState(() {
      _selectedAnswer = selectedIndex;
      _answered = true;

      if (selectedIndex == _questions[_currentQuestion]['dogruCevap']) {
        _score++;
      }
    });

    Future.delayed(const Duration(seconds: 2), () {
      if (_currentQuestion < _questions.length - 1) {
        setState(() {
          _currentQuestion++;
          _answered = false;
          _selectedAnswer = null;
        });
      } else {
        _showResultDialog();
      }
    });
  }

  void _showResultDialog() async {
    int earnedPoints = _score * GamificationService.pointsPerQuiz;
    await GamificationService.addPoints('quiz', earnedPoints);

    // Rozet kontrolü
    int totalQuizzes = await GamificationService.getAchievement('quiz_correct');
    await GamificationService.recordAchievement(
        'quiz_correct', totalQuizzes + _score);

    if (totalQuizzes + _score >= 50) {
      await GamificationService.addBadge('knowledge_seeker');
    }

    if (!mounted) return;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            Text(
              _getResultEmoji(),
              style: const TextStyle(fontSize: 40),
            ),
            const SizedBox(width: 12),
            const Expanded(
              child: Text('Quiz Tamamlandı!'),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Skorunuz: $_score / ${_questions.length}',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.lightYellow,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.stars, color: AppTheme.darkYellow),
                  const SizedBox(width: 8),
                  Text(
                    '+$earnedPoints Puan Kazandınız!',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Text(
              _getResultMessage(),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Kapat'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                _currentQuestion = 0;
                _score = 0;
                _answered = false;
                _selectedAnswer = null;
              });
              _generateQuestions();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryYellow,
              foregroundColor: Colors.black,
            ),
            child: const Text('Tekrar Oyna'),
          ),
        ],
      ),
    );
  }

  String _getResultEmoji() {
    double percentage = (_score / _questions.length) * 100;
    if (percentage == 100) return '🏆';
    if (percentage >= 80) return '🌟';
    if (percentage >= 60) return '👍';
    if (percentage >= 40) return '💪';
    return '📚';
  }

  String _getResultMessage() {
    double percentage = (_score / _questions.length) * 100;
    if (percentage == 100) return 'Mükemmel! Tüm soruları doğru cevapl adınız!';
    if (percentage >= 80) return 'Harika! Çok başarılısınız!';
    if (percentage >= 60) return 'İyi! Güzel bir performans!';
    if (percentage >= 40) return 'Fena değil! Biraz daha çalışmalısınız.';
    return 'Daha fazla çalışmalısınız. Pes etmeyin!';
  }

  @override
  Widget build(BuildContext context) {
    if (_questions.isEmpty) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final question = _questions[_currentQuestion];

    return Scaffold(
      appBar: AppBar(
        title: const Text('İslam Kültürü Quiz'),
        elevation: 2,
      ),
      body: Column(
        children: [
          // İlerleme Göstergesi
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.lightYellow,
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Soru ${_currentQuestion + 1}/${_questions.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Row(
                      children: [
                        const Icon(Icons.stars,
                            color: AppTheme.darkYellow, size: 20),
                        const SizedBox(width: 4),
                        Text(
                          'Skor: $_score',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                LinearProgressIndicator(
                  value: (_currentQuestion + 1) / _questions.length,
                  backgroundColor: Colors.grey[300],
                  color: AppTheme.primaryYellow,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(4),
                ),
              ],
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Kategori
                  Chip(
                    label: Text(question['kategori']),
                    backgroundColor: AppTheme.lightYellow,
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                  ),
                  const SizedBox(height: 24),

                  // Soru
                  Card(
                    elevation: 4,
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Text(
                        question['soru'],
                        style: const TextStyle(
                          fontSize: 20,
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
                    question['secenekler'].length,
                    (index) {
                      bool isSelected = _selectedAnswer == index;
                      bool isCorrect = index == question['dogruCevap'];
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
                                    question['secenekler'][index],
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
                                    color:
                                        isCorrect ? Colors.green : Colors.red,
                                  ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
          ),
          const AdMobBanner(),
        ],
      ),
    );
  }
}
