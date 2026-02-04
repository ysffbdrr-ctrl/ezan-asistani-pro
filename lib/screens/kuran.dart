import 'dart:convert';

import 'package:ezan_asistani/services/tts_service.dart';
import 'package:ezan_asistani/services/gamification_service.dart' as gamification_service;
import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:ezan_asistani/utils/logger.dart';
import 'package:flutter/material.dart';
import 'package:audio_session/audio_session.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:just_audio/just_audio.dart';

class Kuran extends StatefulWidget {
  const Kuran({Key? key}) : super(key: key);

  @override
  State<Kuran> createState() => _KuranState();
}

class _KuranState extends State<Kuran> {
  final TTSService _ttsService = TTSService();
  final AudioPlayer _audioPlayer = AudioPlayer();

  Box<Map>? _cacheBox;
  
  List<Map<String, dynamic>> _sureler = [];
  List<Map<String, dynamic>> _filteredSureler = [];
  bool _isLoading = true;
  Map<int, bool> _speakingStates = {};
  Map<int, bool> _playingStates = {};
  int? _currentlyPlayingIndex;
  final TextEditingController _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _initCacheAndLoad();
    _configureAudioSession();

    _audioPlayer.playerStateStream.listen((state) {
      if (!mounted) return;
      if (state.processingState == ProcessingState.completed ||
          state.processingState == ProcessingState.idle) {
        final idx = _currentlyPlayingIndex;
        if (idx != null) {
          setState(() {
            _playingStates[idx] = false;
            _currentlyPlayingIndex = null;
          });
        }
      }
    });
  }

  Future<void> _configureAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (e) {
      AppLogger.warning('AudioSession yapılandırılamadı: $e');
    }
  }

  Future<void> _initCacheAndLoad() async {
    await _ensureCacheBox();
    await _loadSureler();
  }

  Future<void> _ensureCacheBox() async {
    if (_cacheBox != null) return;
    try {
      await Hive.initFlutter();
    } catch (_) {
      // Already initialized.
    }
    _cacheBox = await Hive.openBox<Map>('quran_cache');
  }

  Future<void> _loadSureler() async {
    try {
      await _ensureCacheBox();
      final response = await http.get(
        Uri.parse('https://api.quran.com/api/v4/chapters?language=tr'),
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        try {
          await _cacheBox?.put('chapters_tr', Map<String, dynamic>.from(data));
        } catch (_) {
          // ignore
        }
        setState(() {
          _sureler = List<Map<String, dynamic>>.from(data['chapters']);
          _filteredSureler = List.from(_sureler);
          _isLoading = false;
        });
      } else {
        await _loadSurelerFromCache();
      }
    } catch (e) {
      AppLogger.error('Sure listesi yüklenemedi', error: e);
      await _loadSurelerFromCache();
    }
  }

  Future<void> _loadSurelerFromCache() async {
    try {
      await _ensureCacheBox();
      final cached = _cacheBox?.get('chapters_tr');
      if (cached != null && cached['chapters'] is List) {
        if (!mounted) return;
        setState(() {
          _sureler = List<Map<String, dynamic>>.from(cached['chapters'] as List);
          _filteredSureler = List.from(_sureler);
          _isLoading = false;
        });
        return;
      }
    } catch (_) {
      // ignore
    }
    if (!mounted) return;
    setState(() {
      _isLoading = false;
    });
  }

  Future<void> _onOpenSurahForGamification() async {
    try {
      await gamification_service.GamificationService.addPoints(
        'quran',
        gamification_service.GamificationService.pointsPerQuran,
      );

      final current =
          await gamification_service.GamificationService.getAchievement('quran_read');
      final next = current + 1;
      await gamification_service.GamificationService.recordAchievement(
        'quran_read',
        next,
      );

      if (next >= 10) {
        await gamification_service.GamificationService.addBadge('quran_reader');
      }
    } catch (_) {
      // ignore
    }
  }

  void _filterSureler(String query) {
    setState(() {
      if (query.isEmpty) {
        _filteredSureler = List.from(_sureler);
      } else {
        _filteredSureler = _sureler.where((surah) {
          final name = surah['name_simple'].toString().toLowerCase();
          final turkishName = surah['translated_name']['name'].toString().toLowerCase();
          final number = surah['id'].toString();
          return name.contains(query.toLowerCase()) ||
                 turkishName.contains(query.toLowerCase()) ||
                 number.contains(query);
        }).toList();
      }
    });
  }

  Future<void> _playSurahAudio(int index, int surahId, String surahName) async {
    try {
      if (_playingStates[index] == true) {
        await _audioPlayer.stop();
        setState(() {
          _playingStates[index] = false;
          _currentlyPlayingIndex = null;
        });
        AppLogger.info('Sure sesi durduruldu: $surahName');
      } else {
        // Başka bir sure çalıyorsa önce onu durdur
        if (_currentlyPlayingIndex != null && _currentlyPlayingIndex != index) {
          try {
            await _audioPlayer.stop();
          } catch (_) {}
          final prev = _currentlyPlayingIndex!;
          setState(() {
            _playingStates[prev] = false;
          });
        }

        setState(() {
          _playingStates[index] = true;
          _currentlyPlayingIndex = index;
        });
        
        // Her sure için ses dosyası URL'i oluştur (fallback kaynaklar)
        final padded = surahId.toString().padLeft(3, '0');
        final candidates = <String>[
          'https://cdn.islamic.network/quran/audio-surah/128/ar.alafasy/$surahId.mp3',
          'https://download.quranicaudio.com/quran/mishaari_rafai/128/$padded.mp3',
          'https://download.quranicaudio.com/quran/mishaari_raashid_al_3afaasy/128kbps/$padded.mp3',
          'https://server8.mp3quran.net/afs/$padded.mp3',
        ];

        Object? lastError;
        for (final url in candidates) {
          try {
            AppLogger.info('Sure sesi deneniyor: $surahName - $url');
            await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url)));
            await _audioPlayer.play();
            AppLogger.success('Sure sesi çalındı: $surahName');
            lastError = null;
            break;
          } catch (e) {
            lastError = e;
          }
        }

        if (lastError != null) {
          throw lastError;
        }
      }
    } catch (e) {
      AppLogger.error('Sure sesi çalma hatası: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Ses dosyası açılamadı: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
      setState(() {
        _playingStates[index] = false;
        if (_currentlyPlayingIndex == index) {
          _currentlyPlayingIndex = null;
        }
      });
    }
  }

  Future<void> _speakSurah(int index, String surahName) async {
    if (_speakingStates[index] == true) {
      await _ttsService.stop();
      setState(() {
        _speakingStates[index] = false;
      });
    } else {
      setState(() {
        _speakingStates[index] = true;
      });
      await _ttsService.speak('Sure: $surahName');
      setState(() {
        _speakingStates[index] = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Kur\'an-ı Kerim'),
        elevation: 2,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(
                color: AppTheme.primaryYellow,
              ),
            )
          : _sureler.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.error_outline,
                        size: 64,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Sureler yüklenemedi',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey,
                        ),
                      ),
                      const SizedBox(height: 8),
                      TextButton.icon(
                        onPressed: () {
                          setState(() {
                            _isLoading = true;
                          });
                          _loadSureler();
                        },
                        icon: const Icon(Icons.refresh),
                        label: const Text('Tekrar Dene'),
                      ),
                    ],
                  ),
                )
              : Column(
                  children: [
                    // Search bar
                    Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: TextField(
                        controller: _searchController,
                        decoration: InputDecoration(
                          hintText: 'Surelerde ara (İsim, Türkçe ad, Sure numarası)',
                          prefixIcon: const Icon(Icons.search),
                          suffixIcon: _searchController.text.isNotEmpty
                              ? IconButton(
                                  icon: const Icon(Icons.clear),
                                  onPressed: () {
                                    _searchController.clear();
                                    _filterSureler('');
                                  },
                                )
                              : null,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        onChanged: _filterSureler,
                      ),
                    ),
                    // Results count
                    if (_searchController.text.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            '${_filteredSureler.length} sure bulundu',
                            style: TextStyle(
                              color: Colors.grey[600],
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ),
                    // Surah list
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.all(16),
                        itemCount: _filteredSureler.length,
                        itemBuilder: (context, index) {
                          final sure = _filteredSureler[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            child: ListTile(
                              onTap: () {
                                _onOpenSurahForGamification();
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => SureDetay(
                                      sureId: (sure['id'] as num).toInt(),
                                      sureAdi: sure['name_simple'] ?? '',
                                      sureTercume:
                                          sure['translated_name']?['name'] ?? '',
                                    ),
                                  ),
                                );
                              },
                              leading: Container(
                                width: 40,
                                height: 40,
                                decoration: BoxDecoration(
                                  color: AppTheme.primaryYellow,
                                  borderRadius: BorderRadius.circular(8),
                                ),
                                child: Center(
                                  child: Text(
                                    '${sure['id']}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                ),
                              ),
                              title: Text(
                                sure['name_simple'] ?? '',
                                style: const TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              subtitle: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    sure['translated_name']?['name'] ?? '',
                                    style: TextStyle(
                                      fontSize: 13,
                                      color: Colors.grey[600],
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      Icon(
                                        Icons.article,
                                        size: 14,
                                        color: Colors.grey[500],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${sure['verses_count']} Ayet',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Icon(
                                        sure['revelation_place'] == 'makkah'
                                            ? Icons.location_city
                                            : Icons.location_on,
                                        size: 14,
                                        color: Colors.grey[500],
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        sure['revelation_place'] == 'makkah'
                                            ? 'Mekke'
                                            : 'Medine',
                                        style: TextStyle(
                                          fontSize: 12,
                                          color: Colors.grey[500],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(
                                      _speakingStates[index] == true
                                          ? Icons.stop
                                          : Icons.volume_up,
                                      color: AppTheme.primaryYellow,
                                    ),
                                    onPressed: () => _speakSurah(
                                      index,
                                      sure['translated_name']?['name'] ?? '',
                                    ),
                                    tooltip: 'Sesli Oku',
                                  ),
                                  IconButton(
                                    icon: Icon(
                                      _playingStates[index] == true
                                          ? Icons.stop_circle
                                          : Icons.play_circle,
                                      color: AppTheme.primaryYellow,
                                    ),
                                    onPressed: () => _playSurahAudio(
                                      index,
                                      (sure['id'] as num).toInt(),
                                      sure['name_simple'] ?? '',
                                    ),
                                    tooltip: 'Sure Dinle',
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ],
                ),
    );
  }

  @override
  void dispose() {
    _searchController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
}

class SureDetay extends StatefulWidget {
  final int sureId;
  final String sureAdi;
  final String sureTercume;

  const SureDetay({
    Key? key,
    required this.sureId,
    required this.sureAdi,
    required this.sureTercume,
  }) : super(key: key);

  @override
  State<SureDetay> createState() => _SureDetayState();
}

class _SureDetayState extends State<SureDetay> {
  final AudioPlayer _audioPlayer = AudioPlayer();
  final TTSService _ttsService = TTSService();
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _verseSearchController = TextEditingController();
  List<Map<String, dynamic>> _ayetler = [];

  static const List<int> _surahVerseCounts = <int>[
    7, 286, 200, 176, 120, 165, 206, 75, 129, 109, 123, 111, 43, 52, 99, 128,
    111, 110, 98, 135, 112, 78, 118, 64, 77, 227, 93, 88, 69, 60, 34, 30, 73,
    54, 45, 83, 182, 88, 75, 85, 54, 53, 89, 59, 37, 35, 38, 29, 18, 45, 60,
    49, 62, 55, 78, 96, 29, 22, 24, 13, 14, 11, 11, 18, 12, 12, 30, 52, 52,
    44, 28, 28, 20, 56, 40, 31, 50, 40, 46, 42, 29, 19, 36, 25, 22, 17, 19,
    26, 30, 20, 15, 21, 11, 8, 8, 19, 5, 8, 8, 11, 11, 8, 3, 9, 5, 4, 7, 3,
    6, 3, 5, 4, 5, 6,
  ];
  bool _isLoading = true;
  bool _showTranslation = true;
  double _fontSize = 20.0;
  String? _playingVerseKey;
  bool _isVerseLoading = false;
  bool _isRepeatMode = false;
  String? _highlightedVerseKey;
  final Map<String, GlobalKey> _verseItemKeys = {};
  String? _speakingTranslationVerseKey;
  bool _isTranslationSpeaking = false;
  bool _isTranslationAutoPlay = false;

  Box<Map>? _cacheBox;

  String _decodeBasicHtmlEntities(String input) {
    return input
        .replaceAll('&quot;', '"')
        .replaceAll('&#34;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&apos;', "'")
        .replaceAll('&amp;', '&')
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>');
  }

  String _stripHtmlTags(String input) {
    return input.replaceAll(RegExp(r'<[^>]*>'), '');
  }

  String _cleanText(dynamic value) {
    final raw = value?.toString() ?? '';
    if (raw.isEmpty) return '';
    final noTags = _stripHtmlTags(raw);
    final decoded = _decodeBasicHtmlEntities(noTags);
    return decoded.trim();
  }

  @override
  void initState() {
    super.initState();
    _configureAudioSession();
    _initCacheAndLoad();
    _audioPlayer.playerStateStream.listen((state) {
      if (state.processingState == ProcessingState.completed) {
        if (mounted) {
          if (_isRepeatMode && _playingVerseKey != null) {
            _audioPlayer.seek(Duration.zero);
            _audioPlayer.play();
          } else {
            _playNext(fromCompletion: true);
          }
        }
      }
    });
  }

  Future<void> _configureAudioSession() async {
    try {
      final session = await AudioSession.instance;
      await session.configure(const AudioSessionConfiguration.music());
    } catch (e) {
      AppLogger.warning('Ayet AudioSession yapılandırılamadı: $e');
    }
  }

  int? _globalAyahNumberFromKey(String verseKey) {
    final parts = verseKey.split(':');
    if (parts.length != 2) return null;
    final surah = int.tryParse(parts[0]);
    final ayah = int.tryParse(parts[1]);
    if (surah == null || ayah == null) return null;
    if (surah < 1 || surah > _surahVerseCounts.length) return null;
    if (ayah < 1) return null;

    var totalBefore = 0;
    for (var i = 0; i < surah - 1; i++) {
      totalBefore += _surahVerseCounts[i];
    }
    return totalBefore + ayah;
  }

  Future<void> _initCacheAndLoad() async {
    await _ensureCacheBox();
    await _loadAyetler();
  }

  Future<void> _ensureCacheBox() async {
    if (_cacheBox != null) return;
    try {
      await Hive.initFlutter();
    } catch (_) {
      // Already initialized.
    }
    _cacheBox = await Hive.openBox<Map>('quran_cache');
  }

  String _surahCacheKey() => 'surah_${widget.sureId}_verses_v2';

  Future<bool> _loadAyetlerFromCache() async {
    try {
      await _ensureCacheBox();
      final cached = _cacheBox?.get(_surahCacheKey());
      if (cached == null) return false;
      final verses = cached['verses'];
      if (verses is! List) return false;

      final list = List<Map<String, dynamic>>.from(verses);
      if (!mounted) return true;
      setState(() {
        _ayetler = list;
        _isLoading = false;
      });
      return true;
    } catch (_) {
      return false;
    }
  }

  Future<void> _saveAyetlerToCache(List<Map<String, dynamic>> verses) async {
    try {
      await _ensureCacheBox();
      await _cacheBox?.put(
        _surahCacheKey(),
        {
          'chapter': widget.sureId,
          'savedAt': DateTime.now().toIso8601String(),
          'verses': verses,
        },
      );
    } catch (_) {
      // ignore
    }
  }

  Future<void> _downloadForOffline() async {
    setState(() {
      _isLoading = true;
    });
    await _loadAyetler(forceOnline: true);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sure offline kaydedildi'),
        duration: Duration(seconds: 2),
      ),
    );
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _scrollController.dispose();
    _verseSearchController.dispose();
    _ttsService.stop();
    super.dispose();
  }

  Future<void> _toggleTranslationTts(String verseKey, String translationText) async {
    if (_isTranslationAutoPlay) {
      await _stopTranslationAutoPlay();
      return;
    }

    await _startTranslationAutoPlay(fromVerseKey: verseKey);
  }

  Future<void> _stopTranslationAutoPlay() async {
    await _ttsService.stop();
    if (!mounted) return;
    setState(() {
      _isTranslationAutoPlay = false;
      _isTranslationSpeaking = false;
      _speakingTranslationVerseKey = null;
    });
  }

  Future<void> _startTranslationAutoPlay({required String fromVerseKey}) async {
    if (_ayetler.isEmpty) return;

    final startIndex = _ayetler.indexWhere((a) => a['verse_key']?.toString() == fromVerseKey);
    if (startIndex == -1) return;

    await _ttsService.initialize();
    await _ttsService.setLanguage('tr_TR');

    if (!mounted) return;
    setState(() {
      _isTranslationAutoPlay = true;
    });

    for (var i = startIndex; i < _ayetler.length; i++) {
      if (!mounted) return;
      if (!_isTranslationAutoPlay) return;

      final verseKey = _ayetler[i]['verse_key']?.toString() ?? '';
      final translation = _ayetler[i]['translation']?.toString() ?? '';
      final cleaned = translation.trim();
      if (verseKey.isEmpty || cleaned.isEmpty) {
        continue;
      }

      setState(() {
        _speakingTranslationVerseKey = verseKey;
        _isTranslationSpeaking = true;
        _highlightedVerseKey = verseKey;
      });

      await _scrollToVerse(verseKey);
      if (!mounted) return;
      if (!_isTranslationAutoPlay) return;

      final estimated = (cleaned.length / 18.0).ceil();
      final seconds = estimated < 2 ? 2 : (estimated > 60 ? 60 : estimated);
      await _ttsService.speakAndWait(cleaned, timeout: Duration(seconds: seconds));
    }

    if (!mounted) return;
    setState(() {
      _isTranslationAutoPlay = false;
      _isTranslationSpeaking = false;
      _speakingTranslationVerseKey = null;
    });
  }

  Future<void> _openVerseSearch() async {
    if (_ayetler.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Ayetler yüklenmeden arama yapılamaz.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _verseSearchController.clear();
    final result = await showDialog<String>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Ayet Numarası Ara'),
          content: TextField(
            controller: _verseSearchController,
            keyboardType: TextInputType.number,
            autofocus: true,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            decoration: const InputDecoration(
              hintText: 'Örn: 255',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('İptal'),
            ),
            TextButton(
              onPressed: () => Navigator.of(context).pop(_verseSearchController.text),
              child: const Text('Git'),
            ),
          ],
        );
      },
    );

    if (!mounted) return;
    final raw = (result ?? '').trim();
    if (raw.isEmpty) return;

    final verseNo = int.tryParse(raw);
    if (verseNo == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Geçersiz ayet numarası.'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final maxVerse = (widget.sureId >= 1 && widget.sureId <= _surahVerseCounts.length)
        ? _surahVerseCounts[widget.sureId - 1]
        : null;
    if (verseNo < 1 || (maxVerse != null && verseNo > maxVerse)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            maxVerse == null
                ? 'Geçersiz ayet numarası.'
                : 'Ayet numarası 1-$maxVerse aralığında olmalı.',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    _jumpToVerseNumber(verseNo);
  }

  void _jumpToVerseNumber(int verseNumber) {
    if (_ayetler.isEmpty) return;
    final index = _ayetler.indexWhere(
      (a) => (a['verse_number'] as int?) == verseNumber,
    );

    if (index == -1) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Ayet bulunamadı: $verseNumber'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    final verseKey = _ayetler[index]['verse_key']?.toString();
    if (verseKey == null || verseKey.isEmpty) return;
    setState(() {
      _highlightedVerseKey = verseKey;
    });
    _scrollToVerse(verseKey);
  }

  Future<void> _toggleVerseAudio(String verseKey) async {
    if (_playingVerseKey == verseKey) {
      if (_audioPlayer.playing) {
        await _audioPlayer.pause();
      } else {
        await _audioPlayer.play();
      }
      setState(() {});
    } else {
      try {
        setState(() {
          _playingVerseKey = verseKey;
          _isVerseLoading = true;
        });
        final globalAyah = _globalAyahNumberFromKey(verseKey);
        final candidates = <String>[
          if (globalAyah != null)
            'https://cdn.islamic.network/quran/audio/128/ar.alafasy/$globalAyah.mp3',
          if (globalAyah != null)
            'https://cdn.islamic.network/quran/audio/128/ar.abdulbasitmurattal/$globalAyah.mp3',
        ];

        Object? lastError;
        for (final url in candidates) {
          try {
            await _audioPlayer.setAudioSource(AudioSource.uri(Uri.parse(url)));
            lastError = null;
            break;
          } catch (e) {
            lastError = e;
          }
        }

        if (lastError != null) {
          throw lastError;
        }
        setState(() {
          _isVerseLoading = false;
        });
        await _audioPlayer.play();
        _scrollToVerse(verseKey);
      } catch (e) {
        AppLogger.error('Ayet sesi yüklenemedi', error: e);
        setState(() {
          _playingVerseKey = null;
          _isVerseLoading = false;
        });
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ses dosyası yüklenemedi.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  void _playNext({bool fromCompletion = false}) {
    if (_playingVerseKey == null) return;
    final currentIndex = _ayetler.indexWhere((ayet) => ayet['verse_key'] == _playingVerseKey);
    if (currentIndex < _ayetler.length - 1) {
      final nextVerseKey = _ayetler[currentIndex + 1]['verse_key'];
      _toggleVerseAudio(nextVerseKey);
    } else {
      // Last verse finished, stop playback
      if (fromCompletion) {
         setState(() {
          _playingVerseKey = null;
          _isVerseLoading = false;
        });
      }
    }
  }

  void _playPrevious() {
    if (_playingVerseKey == null) return;
    final currentIndex = _ayetler.indexWhere((ayet) => ayet['verse_key'] == _playingVerseKey);
    if (currentIndex > 0) {
      final prevVerseKey = _ayetler[currentIndex - 1]['verse_key'];
      _toggleVerseAudio(prevVerseKey);
    }
  }

  Future<void> _scrollToVerse(String verseKey, {int attempts = 6}) async {
    final indexInVerses = _ayetler.indexWhere((ayet) => ayet['verse_key'] == verseKey);
    if (indexInVerses == -1) return;

    // This ListView has a header item at index 0 (title/basmala card), so verses start from 1.
    final indexInListView = indexInVerses + 1;

    final key = _verseItemKeys[verseKey];
    final ctx = key?.currentContext;
    if (ctx != null) {
      await Scrollable.ensureVisible(
        ctx,
        alignment: 0.1,
        duration: const Duration(milliseconds: 450),
        curve: Curves.easeInOut,
      );
      return;
    }

    // If the verse widget isn't built yet, first scroll approximately to make it build,
    // then retry ensureVisible a few times.
    final totalItems = _ayetler.length + 1;
    final fraction = (indexInListView / totalItems).clamp(0.0, 1.0);

    final position = _scrollController.position;
    final approx = position.maxScrollExtent * fraction;
    await _scrollController.animateTo(
      approx,
      duration: const Duration(milliseconds: 350),
      curve: Curves.easeInOut,
    );

    if (!mounted) return;
    if (attempts <= 0) return;

    await Future<void>.delayed(const Duration(milliseconds: 60));
    if (!mounted) return;
    await _scrollToVerse(verseKey, attempts: attempts - 1);
  }

  Future<void> _loadAyetler({bool forceOnline = false}) async {
    try {
      final arabicResponse = await http.get(
        Uri.parse('https://api.quran.com/api/v4/quran/verses/uthmani?chapter_number=${widget.sureId}'),
      );
      final translationResponse = await http.get(
        Uri.parse('https://api.quran.com/api/v4/quran/translations/52?chapter_number=${widget.sureId}'),
      );

      // Okunuş (transliteration) - endpoint bazı ortamlarda değişebildiği için fallback'li ilerliyoruz.
      http.Response? transliterationResponse;
      try {
        transliterationResponse = await http.get(
          Uri.parse('https://api.quran.com/api/v4/quran/transliterations/1?chapter_number=${widget.sureId}'),
        );
      } catch (_) {
        transliterationResponse = null;
      }

      final transliterationOk = transliterationResponse != null &&
          transliterationResponse.statusCode == 200;

      // Fallback: verses/by_chapter words transliteration (çoğu cihazda daha stabil)
      http.Response? byChapterResponse;
      try {
        byChapterResponse = await http.get(
          Uri.parse(
            'https://api.quran.com/api/v4/verses/by_chapter/${widget.sureId}?words=true&per_page=300',
          ),
        );
      } catch (_) {
        byChapterResponse = null;
      }

      if (arabicResponse.statusCode == 200 && translationResponse.statusCode == 200) {
        final arabicData = json.decode(arabicResponse.body);
        final translationData = json.decode(translationResponse.body);

        dynamic transliterationData;
        if (transliterationOk) {
          try {
            transliterationData = json.decode(transliterationResponse!.body);
          } catch (_) {
            transliterationData = null;
          }
        }

        final List<dynamic> arabicVerses =
            (arabicData['verses'] as List?) ?? const [];
        final List<dynamic> translationVerses =
            (translationData['translations'] as List?) ?? const [];
        final List<dynamic> transliterationVerses = transliterationData is Map
            ? ((transliterationData['transliterations'] as List?) ?? const [])
            : const [];

        final Map<String, String> transliterationsByKeyFromWords = {};
        if (byChapterResponse != null && byChapterResponse.statusCode == 200) {
          try {
            final byChapterData = json.decode(byChapterResponse.body);
            final verses = (byChapterData['verses'] as List?) ?? const [];
            for (final v in verses) {
              if (v is! Map) continue;
              final verseKey = v['verse_key']?.toString();
              if (verseKey == null || verseKey.isEmpty) continue;

              final words = (v['words'] as List?) ?? const [];
              final parts = <String>[];
              for (final w in words) {
                if (w is! Map) continue;
                final tr = w['transliteration'];
                final text = tr is Map ? tr['text'] : tr;
                final cleaned = _cleanText(text);
                if (cleaned.isNotEmpty) {
                  parts.add(cleaned);
                }
              }

              // Eğer API transliteration vermiyorsa boş kalabilir.
              if (parts.isNotEmpty) {
                transliterationsByKeyFromWords[verseKey] = parts.join(' ');
              }
            }
          } catch (_) {
            // ignore
          }
        }

        final Map<String, String> translationsByKey = {};
        for (final t in translationVerses) {
          final key = t is Map ? t['verse_key']?.toString() : null;
          if (key == null || key.isEmpty) continue;
          translationsByKey[key] = _cleanText(t['text']);
        }

        final Map<String, String> transliterationsByKey = {};
        for (final tr in transliterationVerses) {
          final key = tr is Map ? tr['verse_key']?.toString() : null;
          if (key == null || key.isEmpty) continue;
          transliterationsByKey[key] = _cleanText(tr['text']);
        }

        List<Map<String, dynamic>> ayetler = [];
        for (int i = 0; i < arabicVerses.length; i++) {
          final v = arabicVerses[i] as Map<String, dynamic>;
          final verseKey = v['verse_key']?.toString();
          if (verseKey == null || verseKey.isEmpty) continue;

          ayetler.add({
            'verse_number': (v['verse_number'] as num?)?.toInt() ?? (i + 1),
            'verse_key': verseKey,
            'text_uthmani': _cleanText(v['text_uthmani']),
            'translation': translationsByKey[verseKey] ??
                (i < translationVerses.length
                    ? _cleanText((translationVerses[i] as Map)['text'])
                    : ''),
            'transliteration': (
                    transliterationsByKey[verseKey] ??
                    transliterationsByKeyFromWords[verseKey] ??
                    (i < transliterationVerses.length
                        ? _cleanText((transliterationVerses[i] as Map)['text'])
                        : '')),
          });
        }
        if (mounted) {
          setState(() {
            _ayetler = ayetler;
            _isLoading = false;
          });
        }

        await _saveAyetlerToCache(ayetler);
      } else {
        if (!forceOnline) {
          final loaded = await _loadAyetlerFromCache();
          if (loaded) return;
        }
        if (mounted) setState(() => _isLoading = false);
      }
    } catch (e) {
      AppLogger.error('Ayetler yüklenemedi', error: e);
      if (!forceOnline) {
        final loaded = await _loadAyetlerFromCache();
        if (loaded) return;
      }
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Widget _buildVerseAudioIcon(String verseKey) {
    if (_playingVerseKey == verseKey) {
      if (_isVerseLoading) {
        return const SizedBox(
          width: 24,
          height: 24,
          child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryYellow),
        );
      }
      if (_audioPlayer.playing) {
        return const Icon(Icons.pause_circle_filled, color: AppTheme.primaryYellow);
      }
    }
    return const Icon(Icons.play_circle_outline, color: Colors.grey);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(widget.sureAdi),
            Text(
              widget.sureTercume,
              style: const TextStyle(fontSize: 12),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: _openVerseSearch,
            tooltip: 'Ayet Numarası Ara',
          ),
          IconButton(
            icon: const Icon(Icons.download_for_offline),
            onPressed: _downloadForOffline,
            tooltip: 'Offline\'a Kaydet',
          ),
          IconButton(
            icon: Icon(_showTranslation ? Icons.translate : Icons.translate_outlined),
            onPressed: () => setState(() => _showTranslation = !_showTranslation),
            tooltip: 'Meal Göster/Gizle',
          ),
          PopupMenuButton<double>(
            icon: const Icon(Icons.text_fields),
            tooltip: 'Font Boyutu',
            onSelected: (value) => setState(() => _fontSize = value),
            itemBuilder: (context) => [
              const PopupMenuItem(value: 16.0, child: Text('Küçük')),
              const PopupMenuItem(value: 20.0, child: Text('Orta')),
              const PopupMenuItem(value: 24.0, child: Text('Büyük')),
              const PopupMenuItem(value: 28.0, child: Text('Çok Büyük')),
            ],
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryYellow))
                : _ayetler.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.error_outline, size: 64, color: Colors.grey[400]),
                            const SizedBox(height: 16),
                            const Text('Ayetler yüklenemedi', style: TextStyle(fontSize: 18, color: Colors.grey)),
                            const SizedBox(height: 8),
                            TextButton.icon(
                              onPressed: () {
                                setState(() => _isLoading = true);
                                _loadAyetler();
                              },
                              icon: const Icon(Icons.refresh),
                              label: const Text('Tekrar Dene'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        controller: _scrollController,
                        padding: const EdgeInsets.all(16),
                        itemCount: _ayetler.length + 1,
                        itemBuilder: (context, index) {
                          if (index == 0) {
                            if (widget.sureId != 9 && widget.sureId != 1) {
                              return Card(
                                color: AppTheme.lightYellow,
                                margin: const EdgeInsets.only(bottom: 16),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Text(
                                    'بِسْمِ اللَّهِ الرَّحْمَٰنِ الرَّحِيمِ',
                                    style: TextStyle(fontSize: _fontSize + 4, fontWeight: FontWeight.bold, height: 2),
                                    textAlign: TextAlign.center,
                                    textDirection: TextDirection.rtl,
                                  ),
                                ),
                              );
                            }
                            return const SizedBox.shrink();
                          }

                          final ayet = _ayetler[index - 1];
                          final isPlaying = ayet['verse_key'] == _playingVerseKey;
                          final verseKey = ayet['verse_key']?.toString() ?? '';
                          final translationText = ayet['translation']?.toString() ?? '';
                          final canSpeakTranslation =
                              _showTranslation && translationText.trim().isNotEmpty && verseKey.isNotEmpty;
                          final isSpeakingTranslation =
                              _isTranslationSpeaking && _speakingTranslationVerseKey == verseKey;
                          if (verseKey.isNotEmpty && !_verseItemKeys.containsKey(verseKey)) {
                            _verseItemKeys[verseKey] = GlobalKey();
                          }
                          final isHighlighted = verseKey.isNotEmpty && verseKey == _highlightedVerseKey;
                          return Card(
                            key: verseKey.isNotEmpty ? _verseItemKeys[verseKey] : null,
                            color: isHighlighted
                                ? AppTheme.lightYellow
                                : (isPlaying ? AppTheme.lightYellow.withOpacity(0.5) : null),
                            margin: const EdgeInsets.only(bottom: 12),
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                                        decoration: BoxDecoration(
                                          color: AppTheme.primaryYellow,
                                          borderRadius: BorderRadius.circular(20),
                                        ),
                                        child: Text(
                                          'Ayet ${(ayet['verse_number'] as int?) ?? (index)}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.black),
                                        ),
                                      ),
                                      const Spacer(),
                                      IconButton(
                                        icon: _buildVerseAudioIcon(ayet['verse_key']),
                                        onPressed: () => _toggleVerseAudio(ayet['verse_key']),
                                        tooltip: 'Ayet Seslendirme',
                                      ),
                                      if (canSpeakTranslation)
                                        IconButton(
                                          icon: Icon(
                                            isSpeakingTranslation ? Icons.stop_circle_outlined : Icons.record_voice_over,
                                          ),
                                          onPressed: () => _toggleTranslationTts(verseKey, translationText),
                                          tooltip: 'Türkçe Dinle',
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Text(
                                    ayet['text_uthmani'],
                                    style: TextStyle(fontSize: _fontSize, fontWeight: FontWeight.w600, height: 2),
                                    textAlign: TextAlign.right,
                                    textDirection: TextDirection.rtl,
                                  ),
                                  if ((ayet['transliteration']?.toString() ?? '').trim().isNotEmpty) ...[
                                    const SizedBox(height: 12),
                                    Text(
                                      ayet['transliteration'].toString(),
                                      style: TextStyle(
                                        fontSize: _fontSize - 4,
                                        color: Colors.grey[800],
                                        height: 1.5,
                                        fontStyle: FontStyle.italic,
                                      ),
                                    ),
                                  ],
                                  if (_showTranslation) ...[
                                    const Divider(height: 32),
                                    Text(
                                      ayet['translation'].toString(),
                                      style: TextStyle(fontSize: _fontSize - 4, color: Colors.grey[700], height: 1.5),
                                    ),
                                  ],
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
          if (_playingVerseKey != null) _buildPlayerControls(),
        ],
      ),
    );
  }

  Widget _buildPlayerControls() {
    final currentIndex = _ayetler.indexWhere((ayet) => ayet['verse_key'] == _playingVerseKey);
    if (currentIndex == -1) return const SizedBox.shrink();
    final currentVerse = _ayetler[currentIndex];

    return Container(
      padding: const EdgeInsets.all(8.0),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            '${widget.sureAdi} - Ayet ${currentVerse['verse_number']}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                icon: const Icon(Icons.repeat),
                color: _isRepeatMode ? AppTheme.primaryYellow : Colors.grey,
                onPressed: () => setState(() => _isRepeatMode = !_isRepeatMode),
                tooltip: 'Hafızlık Modu (Tekrar)',
              ),
              IconButton(
                icon: const Icon(Icons.skip_previous),
                iconSize: 32,
                onPressed: _playPrevious,
              ),
              IconButton(
                icon: _isVerseLoading
                    ? const CircularProgressIndicator()
                    : Icon(_audioPlayer.playing ? Icons.pause_circle_filled : Icons.play_circle_filled),
                iconSize: 48,
                color: AppTheme.primaryYellow,
                onPressed: () => _toggleVerseAudio(_playingVerseKey!),
              ),
              IconButton(
                icon: const Icon(Icons.skip_next),
                iconSize: 32,
                onPressed: () => _playNext(),
              ),
              IconButton(
                icon: const Icon(Icons.stop_circle_outlined),
                color: Colors.grey,
                onPressed: () {
                  _audioPlayer.stop();
                  setState(() {
                    _playingVerseKey = null;
                    _isRepeatMode = false;
                  });
                },
                tooltip: 'Durdur',
              ),
            ],
          ),
        ],
      ),
    );
  }
}
