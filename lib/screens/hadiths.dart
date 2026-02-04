import 'package:flutter/material.dart';
import 'package:ezan_asistani/services/hadith_service.dart';
import 'package:ezan_asistani/services/tts_service.dart';
import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:ezan_asistani/utils/logger.dart';
import 'package:share_plus/share_plus.dart';

class Hadiths extends StatefulWidget {
  const Hadiths({Key? key}) : super(key: key);

  @override
  State<Hadiths> createState() => _HadithsState();
}

class _HadithsState extends State<Hadiths> {
  final HadithService _hadithService = HadithService();
  final TTSService _ttsService = TTSService();
  
  Hadith? _currentHadith;
  List<Hadith> _allHadiths = [];
  bool _isLoading = true;
  int _currentIndex = 0;
  bool _showExplanation = false;
  bool _isSpeaking = false;

  @override
  void initState() {
    super.initState();
    _loadHadiths();
  }

  Future<void> _loadHadiths() async {
    setState(() {
      _isLoading = true;
    });

    try {
      _allHadiths = _hadithService.getAllHadiths();
      if (_allHadiths.isNotEmpty) {
        _currentIndex = 0;
        _currentHadith = _allHadiths[0];
      }
    } catch (e) {
      AppLogger.error('Hadis yükleme hatası', error: e);
    }

    setState(() {
      _isLoading = false;
    });
  }

  void _nextHadith() {
    if (_allHadiths.isEmpty) return;
    
    setState(() {
      _currentIndex = (_currentIndex + 1) % _allHadiths.length;
      _currentHadith = _allHadiths[_currentIndex];
      _showExplanation = false;
    });
  }

  void _previousHadith() {
    if (_allHadiths.isEmpty) return;
    
    setState(() {
      _currentIndex = (_currentIndex - 1 + _allHadiths.length) % _allHadiths.length;
      _currentHadith = _allHadiths[_currentIndex];
      _showExplanation = false;
    });
  }

  void _shareHadith() {
    if (_currentHadith == null) return;
    
    final text = '''
${_currentHadith!.text}

Kaynak: ${_currentHadith!.source}
Ravi: ${_currentHadith!.narrator}

Ezan Asistanı Pro ile paylaşıldı
    ''';
    
    Share.share(text, subject: 'Hz. Muhammed\'in Hadisi');
  }

  Future<void> _speakHadith() async {
    if (_currentHadith == null) return;

    if (_isSpeaking) {
      await _ttsService.stop();
      setState(() {
        _isSpeaking = false;
      });
    } else {
      // Initialize TTS before speaking
      await _ttsService.initialize();
      setState(() {
        _isSpeaking = true;
      });
      await _ttsService.speak(_currentHadith!.text);
      setState(() {
        _isSpeaking = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hz. Muhammed\'in Hadisleri'),
        backgroundColor: AppTheme.primaryYellow,
        elevation: 0,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(),
            )
          : _currentHadith == null
              ? const Center(
                  child: Text('Hadis bulunamadı'),
                )
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      // Hadis kartı
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Card(
                          elevation: 4,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: Container(
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(16),
                              gradient: LinearGradient(
                                colors: [
                                  AppTheme.primaryYellow.withOpacity(0.1),
                                  AppTheme.primaryYellow.withOpacity(0.05),
                                ],
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(24.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Başlık
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.auto_stories,
                                        color: AppTheme.primaryYellow,
                                        size: 28,
                                      ),
                                      const SizedBox(width: 12),
                                      Expanded(
                                        child: Text(
                                          'Hz. Muhammed\'in Hadisi',
                                          style: const TextStyle(
                                            fontSize: 18,
                                            fontWeight: FontWeight.bold,
                                            color: Colors.black87,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // Hadis metni
                                  Container(
                                    padding: const EdgeInsets.all(16),
                                    decoration: BoxDecoration(
                                      color: Colors.white,
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: AppTheme.primaryYellow.withOpacity(0.3),
                                      ),
                                    ),
                                    child: Column(
                                      children: [
                                        Text(
                                          _currentHadith!.text,
                                          style: const TextStyle(
                                            fontSize: 16,
                                            height: 1.8,
                                            color: Colors.black87,
                                            fontStyle: FontStyle.italic,
                                          ),
                                          textAlign: TextAlign.justify,
                                        ),
                                        const SizedBox(height: 12),
                                        ElevatedButton.icon(
                                          onPressed: _speakHadith,
                                          icon: Icon(_isSpeaking ? Icons.stop : Icons.volume_up),
                                          label: Text(_isSpeaking ? 'Durdur' : 'Sesli Oku'),
                                          style: ElevatedButton.styleFrom(
                                            backgroundColor: AppTheme.primaryYellow,
                                            foregroundColor: Colors.black,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  
                                  // Kaynak ve Ravi
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Kaynak',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _currentHadith!.source,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      Expanded(
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Ravi',
                                              style: TextStyle(
                                                fontSize: 12,
                                                color: Colors.grey[600],
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                            const SizedBox(height: 4),
                                            Text(
                                              _currentHadith!.narrator,
                                              style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: Colors.black87,
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  // Açıklama
                                  if (_currentHadith!.explanation != null) ...[
                                    const SizedBox(height: 20),
                                    GestureDetector(
                                      onTap: () {
                                        setState(() {
                                          _showExplanation = !_showExplanation;
                                        });
                                      },
                                      child: Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryYellow.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(8),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          children: [
                                            Text(
                                              'Açıklama',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                                color: AppTheme.primaryYellow,
                                              ),
                                            ),
                                            Icon(
                                              _showExplanation
                                                  ? Icons.expand_less
                                                  : Icons.expand_more,
                                              color: AppTheme.primaryYellow,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                    if (_showExplanation) ...[
                                      const SizedBox(height: 12),
                                      Container(
                                        padding: const EdgeInsets.all(12),
                                        decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: AppTheme.primaryYellow.withOpacity(0.2),
                                          ),
                                        ),
                                        child: Text(
                                          _currentHadith!.explanation!,
                                          style: const TextStyle(
                                            fontSize: 14,
                                            height: 1.6,
                                            color: Colors.black87,
                                          ),
                                          textAlign: TextAlign.justify,
                                        ),
                                      ),
                                    ],
                                  ],
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      
                      // Sayfa göstergesi
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                          '${_currentIndex + 1} / ${_allHadiths.length}',
                          style: TextStyle(
                            fontSize: 14,
                            color: Colors.grey[600],
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      
                      // İlerleme çubuğu
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: (_currentIndex + 1) / _allHadiths.length,
                            minHeight: 6,
                            backgroundColor: Colors.grey[300],
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppTheme.primaryYellow,
                            ),
                          ),
                        ),
                      ),
                      
                      // Kontrol butonları
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          children: [
                            ElevatedButton.icon(
                              onPressed: _previousHadith,
                              icon: const Icon(Icons.arrow_back),
                              label: const Text('Önceki'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryYellow,
                                foregroundColor: Colors.black,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _shareHadith,
                              icon: const Icon(Icons.share),
                              label: const Text('Paylaş'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryYellow,
                                foregroundColor: Colors.black,
                              ),
                            ),
                            ElevatedButton.icon(
                              onPressed: _nextHadith,
                              icon: const Icon(Icons.arrow_forward),
                              label: const Text('Sonraki'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primaryYellow,
                                foregroundColor: Colors.black,
                              ),
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
    );
  }
}
