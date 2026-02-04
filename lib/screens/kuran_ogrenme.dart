import 'package:flutter/material.dart';
import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ezan_asistani/screens/arapca_alfabesi.dart';
import 'package:ezan_asistani/screens/tecvid_kurallari.dart';
import 'package:ezan_asistani/screens/kisa_sureler.dart';
import 'package:flutter_tts/flutter_tts.dart';

class KuranOgrenme extends StatefulWidget {
  const KuranOgrenme({Key? key}) : super(key: key);

  @override
  State<KuranOgrenme> createState() => _KuranOgrenmeState();
}

class _KuranOgrenmeState extends State<KuranOgrenme> {
  int _tamamlananDersler = 0;
  int _toplamOgrenmeZamani = 0; // dakika cinsinden
  List<String> _tamamlananKonular = [];
  late FlutterTts _flutterTts;
  bool _isTtsInitialized = false;

  @override
  void initState() {
    super.initState();
    _loadProgress();
    _initializeTts();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  Future<void> _initializeTts() async {
    _flutterTts = FlutterTts();
    await _flutterTts.setLanguage('ar-SA');
    await _flutterTts.setSpeechRate(0.4);
    setState(() {
      _isTtsInitialized = true;
    });
  }

  Future<void> _speak(String text) async {
    if (_isTtsInitialized) {
      await _flutterTts.speak(text);
    }
  }

  Future<void> _loadProgress() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _tamamlananDersler = prefs.getInt('kuran_tamamlanan_dersler') ?? 0;
      _toplamOgrenmeZamani = prefs.getInt('kuran_ogrenme_zamani') ?? 0;
      _tamamlananKonular = prefs.getStringList('kuran_tamamlanan_konular') ?? [];
    });
  }

  Future<void> _updateProgress(String konu) async {
    if (!_tamamlananKonular.contains(konu)) {
      final prefs = await SharedPreferences.getInstance();
      _tamamlananKonular.add(konu);
      _tamamlananDersler++;
      
      await prefs.setInt('kuran_tamamlanan_dersler', _tamamlananDersler);
      await prefs.setStringList('kuran_tamamlanan_konular', _tamamlananKonular);
      
      setState(() {});
    }
  }

  Widget _buildLessonCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
    bool isCompleted = false,
  }) {
    return Card(
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                color.withOpacity(0.1),
                color.withOpacity(0.05),
              ],
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: color,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  icon,
                  color: Colors.white,
                  size: 30,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[600],
                      ),
                    ),
                  ],
                ),
              ),
              Column(
                children: [
                  Icon(
                    isCompleted ? Icons.check_circle : Icons.arrow_forward_ios,
                    color: isCompleted ? Colors.green : Colors.grey,
                  ),
                  if (isCompleted)
                    const Text(
                      'Tamamlandı',
                      style: TextStyle(
                        fontSize: 10,
                        color: Colors.green,
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatCard(String title, String value, IconData icon) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppTheme.primaryYellow.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.primaryYellow.withOpacity(0.3),
          ),
        ),
        child: Column(
          children: [
            Icon(icon, color: AppTheme.primaryYellow, size: 28),
            const SizedBox(height: 8),
            Text(
              value,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              title,
              style: TextStyle(
                fontSize: 12,
                color: Colors.grey[600],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kur\'an-ı Kerim Öğrenme'),
        elevation: 2,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // İstatistik Kartları
            Container(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  _buildStatCard(
                    'Tamamlanan',
                    _tamamlananDersler.toString(),
                    Icons.check_circle_outline,
                  ),
                  const SizedBox(width: 12),
                  _buildStatCard(
                    'Öğrenme Zamanı',
                    '${_toplamOgrenmeZamani ~/ 60}s ${_toplamOgrenmeZamani % 60}d',
                    Icons.timer_outlined,
                  ),
                ],
              ),
            ),

            // Ana Başlık
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                color: AppTheme.lightYellow,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      Icon(
                        Icons.auto_stories,
                        size: 48,
                        color: AppTheme.primaryYellow,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Kur\'an-ı Kerim\'i Öğrenin',
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Adım adım Kur\'an okumayı öğrenin',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[700],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            // Temel Dersler Bölümü
            Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        Icons.school,
                        color: AppTheme.primaryYellow,
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Temel Dersler',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                ],
              ),
            ),

            // Ders Kartları
            _buildLessonCard(
              title: 'Arapça Alfabesi',
              subtitle: '29 harf ve telaffuzları',
              icon: Icons.abc,
              color: Colors.blue,
              isCompleted: _tamamlananKonular.contains('arapca_alfabesi'),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const ArapcaAlfabesi(),
                  ),
                );
                _updateProgress('arapca_alfabesi');
              },
            ),

            _buildLessonCard(
              title: 'Tecvid Kuralları',
              subtitle: 'Doğru okuma teknikleri',
              icon: Icons.rule,
              color: Colors.purple,
              isCompleted: _tamamlananKonular.contains('tecvid_kurallari'),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const TecvidKurallari(),
                  ),
                );
                _updateProgress('tecvid_kurallari');
              },
            ),

            _buildLessonCard(
              title: 'Kısa Sureler',
              subtitle: 'Namazda okunan sureler',
              icon: Icons.menu_book,
              color: Colors.green,
              isCompleted: _tamamlananKonular.contains('kisa_sureler'),
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => const KisaSureler(),
                  ),
                );
                _updateProgress('kisa_sureler');
              },
            ),

            _buildLessonCard(
              title: 'Hareke ve İşaretler',
              subtitle: 'Üstün, esre, ötre ve diğerleri',
              icon: Icons.edit_note,
              color: Colors.orange,
              isCompleted: _tamamlananKonular.contains('harekeler'),
              onTap: () {
                _showHarekelerDialog();
              },
            ),

            _buildLessonCard(
              title: 'Okuma Alıştırmaları',
              subtitle: 'Pratik yapma egzersizleri',
              icon: Icons.record_voice_over,
              color: Colors.teal,
              isCompleted: _tamamlananKonular.contains('okuma_alistirmalari'),
              onTap: () {
                _showOkumaAlistirmalari();
              },
            ),

            const SizedBox(height: 32),

            // İpuçları Kartı
            Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: Colors.blue.withOpacity(0.3),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.lightbulb, color: Colors.blue),
                      SizedBox(width: 8),
                      Text(
                        'Öğrenme İpuçları',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  _buildTip('Her gün en az 15 dakika pratik yapın'),
                  _buildTip('Önce harfleri öğrenin, sonra kelimelere geçin'),
                  _buildTip('Sesli okuma yaparak telaffuzunuzu geliştirin'),
                  _buildTip('Sabırlı olun, öğrenme zaman alır'),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  Widget _buildTip(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.check, color: Colors.green, size: 16),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(fontSize: 14),
            ),
          ),
        ],
      ),
    );
  }

  void _showHarekelerDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Hareke ve İşaretler'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildHarekeItem('Üstün (Fetha)', 'َ', 'a sesi'),
              _buildHarekeItem('Esre (Kesra)', 'ِ', 'i sesi'),
              _buildHarekeItem('Ötre (Damme)', 'ُ', 'u sesi'),
              _buildHarekeItem('Cezm (Sükun)', 'ْ', 'Harekesizlik'),
              _buildHarekeItem('Şedde', 'ّ', 'Harfin iki kez okunması'),
              _buildHarekeItem('Tenvin Fetha', 'ً', 'an sesi'),
              _buildHarekeItem('Tenvin Kesra', 'ٍ', 'in sesi'),
              _buildHarekeItem('Tenvin Damme', 'ٌ', 'un sesi'),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateProgress('harekeler');
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Widget _buildHarekeItem(String name, String symbol, String description) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryYellow.withOpacity(0.2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                symbol,
                style: const TextStyle(fontSize: 24),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _showOkumaAlistirmalari() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Okuma Alıştırmaları'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Temel Kelimeler:',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              _buildPracticeWord('بِسْمِ', 'Bismi', 'Adıyla'),
              _buildPracticeWord('اللَّهِ', 'Allah', 'Allah'),
              _buildPracticeWord('الرَّحْمَٰنِ', 'Er-Rahman', 'Rahman'),
              _buildPracticeWord('الرَّحِيمِ', 'Er-Rahim', 'Rahim'),
              const SizedBox(height: 16),
              const Text(
                'Günlük pratik yaparak bu kelimeleri doğru okumayı öğrenin.',
                style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateProgress('okuma_alistirmalari');
            },
            child: const Text('Tamam'),
          ),
        ],
      ),
    );
  }

  Widget _buildPracticeWord(String arabic, String pronunciation, String meaning) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 8),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.grey[300]!),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: Text(
                  arabic,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    height: 1.5,
                  ),
                  textDirection: TextDirection.rtl,
                ),
              ),
              IconButton(
                icon: const Icon(Icons.volume_up),
                color: AppTheme.primaryYellow,
                onPressed: () => _speak(arabic),
                tooltip: 'Telaffuzu Dinle',
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            'Okunuşu: $pronunciation',
            style: const TextStyle(fontSize: 14, color: Colors.blue),
          ),
          Text(
            'Anlamı: $meaning',
            style: TextStyle(fontSize: 12, color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }
}
