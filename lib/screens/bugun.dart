import 'dart:math';

import 'package:ezan_asistani/services/hadith_service.dart';
import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Bugun extends StatefulWidget {
  const Bugun({super.key});

  @override
  State<Bugun> createState() => _BugunState();
}

class _BugunState extends State<Bugun> {
  bool _loading = true;
  bool _includeHadith = true;
  bool _dismissed = false;

  Map<String, String>? _selectedVerse;
  Map<String, String>? _selectedDua;
  Hadith? _selectedHadith;

  final _random = Random();

  static const _sampleVerses = <Map<String, String>>[
    {
      'ref': 'Bakara 2:286',
      'text': 'Allah hiçbir kimseye gücünün yeteceğinden fazlasını yüklemez.'
    },
    {
      'ref': 'Ra’d 13:28',
      'text': 'Kalpler ancak Allah’ı anmakla huzur bulur.'
    },
    {
      'ref': 'İnşirah 94:5-6',
      'text': 'Şüphesiz zorlukla beraber bir kolaylık vardır.'
    },
    {
      'ref': 'Bakara 2:152',
      'text': 'Beni anın ki Ben de sizi anayım.'
    },
    {
      'ref': 'Zümer 39:53',
      'text': 'Allah’ın rahmetinden ümidinizi kesmeyin.'
    },
  ];

  @override
  void initState() {
    super.initState();
    _init();
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }

  Future<void> _init() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();

    final dismissed = prefs.getBool('bugun_card_dismissed_$today') ?? false;
    final includeHadith = prefs.getBool('bugun_include_hadith') ?? true;

    await _ensureHive();

    setState(() {
      _dismissed = dismissed;
      _includeHadith = includeHadith;
      _loading = false;
    });

    await _generateIfNeeded();
  }

  Future<void> _ensureHive() async {
    try {
      await Hive.initFlutter();
    } catch (_) {
      // Already initialized.
    }

    try {
      await Hive.openBox<Map>('duas');
    } catch (_) {
      // Already open.
    }
  }

  Future<void> _generateIfNeeded() async {
    if (_dismissed) return;
    await _generate();
  }

  Future<void> _generate() async {
    final duaBox = Hive.box<Map>('duas');

    Map<String, String>? selectedDua;
    if (duaBox.isNotEmpty) {
      final keys = duaBox.keys.toList();
      final key = keys[_random.nextInt(keys.length)];
      final raw = duaBox.get(key);
      if (raw != null) {
        selectedDua = {
          'title': (raw['title'] ?? '').toString(),
          'arabic': (raw['arabic'] ?? '').toString(),
          'pronunciation': (raw['pronunciation'] ?? '').toString(),
          'turkish': (raw['turkish'] ?? '').toString(),
        };
      }
    }

    Hadith? selectedHadith;
    if (_includeHadith) {
      selectedHadith = await HadithService().getRandomHadith();
    }

    setState(() {
      _selectedVerse = _sampleVerses[_random.nextInt(_sampleVerses.length)];
      _selectedDua = selectedDua;
      _selectedHadith = selectedHadith;
    });
  }

  Future<void> _dismissForToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    await prefs.setBool('bugun_card_dismissed_$today', true);
    if (!mounted) return;
    setState(() {
      _dismissed = true;
    });
  }

  Future<void> _resetForToday() async {
    final prefs = await SharedPreferences.getInstance();
    final today = _todayKey();
    await prefs.setBool('bugun_card_dismissed_$today', false);
    if (!mounted) return;
    setState(() {
      _dismissed = false;
    });
    await _generate();
  }

  Future<void> _toggleIncludeHadith(bool value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('bugun_include_hadith', value);
    if (!mounted) return;
    setState(() {
      _includeHadith = value;
      _selectedHadith = null;
    });
    await _generate();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Bugün'),
        elevation: 2,
        actions: [
          IconButton(
            tooltip: 'Yenile',
            onPressed: _dismissed ? _resetForToday : _generate,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      body: _loading
          ? const Center(
              child: CircularProgressIndicator(color: AppTheme.primaryYellow),
            )
          : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _dismissed
                            ? 'Bugünün önerisini kapattın. İstersen tekrar açabilirsin.'
                            : 'Sade ama anlamlı bir öneri',
                        style: TextStyle(color: Colors.grey[700]),
                      ),
                    ),
                    if (!_dismissed)
                      TextButton.icon(
                        onPressed: _dismissForToday,
                        icon: const Icon(Icons.close),
                        label: const Text('Kapat'),
                      ),
                    if (_dismissed)
                      TextButton.icon(
                        onPressed: _resetForToday,
                        icon: const Icon(Icons.visibility),
                        label: const Text('Aç'),
                      ),
                  ],
                ),
                const SizedBox(height: 12),
                Card(
                  elevation: 2,
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text('Hadis göster'),
                          value: _includeHadith,
                          activeThumbColor: AppTheme.primaryYellow,
                          onChanged: _toggleIncludeHadith,
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                if (!_dismissed) ...[
                  _buildVerseCard(),
                  const SizedBox(height: 12),
                  _buildDuaCard(),
                  const SizedBox(height: 12),
                  if (_includeHadith) _buildHadithCard(),
                ],
              ],
            ),
    );
  }

  Widget _buildVerseCard() {
    final verse = _selectedVerse;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '1 Ayet',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              verse?['text'] ?? '—',
              style: const TextStyle(fontSize: 15, height: 1.4),
            ),
            const SizedBox(height: 8),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                verse?['ref'] ?? '',
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDuaCard() {
    final dua = _selectedDua;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '1 Dua',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              dua?['title']?.isNotEmpty == true ? dua!['title']! : '—',
              style: const TextStyle(fontWeight: FontWeight.w600),
            ),
            const SizedBox(height: 8),
            if ((dua?['arabic'] ?? '').isNotEmpty)
              Text(
                dua!['arabic']!,
                textDirection: TextDirection.rtl,
                textAlign: TextAlign.right,
                style: const TextStyle(height: 1.8, fontSize: 18),
              ),
            if ((dua?['pronunciation'] ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                dua!['pronunciation']!,
                style: TextStyle(color: Colors.grey[800], fontStyle: FontStyle.italic),
              ),
            ],
            if ((dua?['turkish'] ?? '').isNotEmpty) ...[
              const SizedBox(height: 8),
              Text(
                dua!['turkish']!,
                style: TextStyle(color: Colors.grey[700]),
              ),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildHadithCard() {
    final hadith = _selectedHadith;
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '1 Hadis (opsiyonel)',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Text(
              hadith?.text ?? 'Hadis yüklenemedi',
              style: const TextStyle(fontSize: 14, height: 1.4),
            ),
            const SizedBox(height: 8),
            Text(
              hadith == null ? '' : '${hadith.source} • ${hadith.narrator}',
              style: TextStyle(color: Colors.grey[700], fontSize: 12),
            ),
          ],
        ),
      ),
    );
  }
}
