import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ezan_asistani/theme/app_theme.dart';

class GunlukDua extends StatefulWidget {
  const GunlukDua({Key? key}) : super(key: key);

  @override
  State<GunlukDua> createState() => _GunlukDuaState();
}

class _GunlukDuaState extends State<GunlukDua> {
  bool _sabahBildirimi = false;
  bool _aksamBildirimi = false;
  bool _yatsiOncesiBildirimi = false;
  TimeOfDay _sabahSaat = const TimeOfDay(hour: 7, minute: 0);
  TimeOfDay _aksamSaat = const TimeOfDay(hour: 18, minute: 0);
  TimeOfDay _yatsiSaat = const TimeOfDay(hour: 22, minute: 0);

  final List<Map<String, String>> _sabahDualari = [
    {
      'baslik': 'Sabah Duası',
      'arapca': 'اللَّهُمَّ بِكَ أَصْبَحْنَا وَبِكَ أَمْسَيْنَا',
      'turkce': 'Allah\'ım! Seninle sabahladık ve seninle akşamladık.',
    },
    {
      'baslik': 'Güne Başlama Duası',
      'arapca': 'بِسْمِ اللهِ الَّذِي لاَ يَضُرُّ مَعَ اسْمِهِ شَيْءٌ',
      'turkce': 'Allah\'ın adıyla ki, O\'nun adıyla hiçbir şey zarar veremez.',
    },
    {
      'baslik': 'Bereket Duası',
      'arapca': 'اللَّهُمَّ إِنِّي أَسْأَلُكَ عِلْمًا نَافِعًا وَرِزْقًا طَيِّبًا',
      'turkce': 'Allah\'ım! Senden faydalı ilim ve helal rızık istiyorum.',
    },
  ];

  final List<Map<String, String>> _aksamDualari = [
    {
      'baslik': 'Akşam Duası',
      'arapca': 'اللَّهُمَّ بِكَ أَمْسَيْنَا وَبِكَ أَصْبَحْنَا',
      'turkce': 'Allah\'ım! Seninle akşamladık ve seninle sabahladık.',
    },
    {
      'baslik': 'Koruma Duası',
      'arapca': 'أَعُوذُ بِكَلِمَاتِ اللَّهِ التَّامَّاتِ مِنْ شَرِّ مَا خَلَقَ',
      'turkce': 'Allah\'ın mükemmel kelimelerine sığınırım, yarattığı şeylerin şerrinden.',
    },
  ];

  final List<Map<String, String>> _yatsiDualari = [
    {
      'baslik': 'Uyku Duası',
      'arapca': 'بِاسْمِكَ اللَّهُمَّ أَمُوتُ وَأَحْيَا',
      'turkce': 'Allah\'ım! Senin adınla ölürüm ve senin adınla diriliyorum.',
    },
    {
      'baslik': 'Gece Koruması',
      'arapca': 'اللَّهُمَّ أَسْلَمْتُ نَفْسِي إِلَيْكَ',
      'turkce': 'Allah\'ım! Nefsimi sana teslim ettim.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _sabahBildirimi = prefs.getBool('sabah_bildirim') ?? false;
      _aksamBildirimi = prefs.getBool('aksam_bildirim') ?? false;
      _yatsiOncesiBildirimi = prefs.getBool('yatsi_bildirim') ?? false;

      int sabahSaat = prefs.getInt('sabah_saat') ?? 7;
      int sabahDakika = prefs.getInt('sabah_dakika') ?? 0;
      _sabahSaat = TimeOfDay(hour: sabahSaat, minute: sabahDakika);

      int aksamSaat = prefs.getInt('aksam_saat') ?? 18;
      int aksamDakika = prefs.getInt('aksam_dakika') ?? 0;
      _aksamSaat = TimeOfDay(hour: aksamSaat, minute: aksamDakika);

      int yatsiSaat = prefs.getInt('yatsi_saat') ?? 22;
      int yatsiDakika = prefs.getInt('yatsi_dakika') ?? 0;
      _yatsiSaat = TimeOfDay(hour: yatsiSaat, minute: yatsiDakika);
    });
  }

  Future<void> _saveSetting(String key, dynamic value) async {
    final prefs = await SharedPreferences.getInstance();
    if (value is bool) {
      await prefs.setBool(key, value);
    } else if (value is int) {
      await prefs.setInt(key, value);
    }
  }

  Future<void> _selectTime(BuildContext context, String type) async {
    TimeOfDay? initialTime;
    if (type == 'sabah') initialTime = _sabahSaat;
    else if (type == 'aksam') initialTime = _aksamSaat;
    else initialTime = _yatsiSaat;

    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: initialTime,
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.light(
              primary: AppTheme.primaryYellow,
              onPrimary: Colors.black,
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        if (type == 'sabah') {
          _sabahSaat = picked;
          _saveSetting('sabah_saat', picked.hour);
          _saveSetting('sabah_dakika', picked.minute);
        } else if (type == 'aksam') {
          _aksamSaat = picked;
          _saveSetting('aksam_saat', picked.hour);
          _saveSetting('aksam_dakika', picked.minute);
        } else {
          _yatsiSaat = picked;
          _saveSetting('yatsi_saat', picked.hour);
          _saveSetting('yatsi_dakika', picked.minute);
        }
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bildirim saati güncellendi'),
            duration: Duration(seconds: 2),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Günlük Dua Bildirimi'),
        elevation: 2,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Açıklama Kartı
          Card(
            color: AppTheme.lightYellow,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  const Icon(
                    Icons.notifications_active,
                    size: 48,
                    color: AppTheme.darkYellow,
                  ),
                  const SizedBox(height: 12),
                  const Text(
                    'Günlük Dua Hatırlatıcısı',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Sabah, akşam ve yatmadan önce dua okumayı unutmayın. Bildirimlerinizi aktif ederek düzenli hatırlatmalar alabilirsiniz.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[800],
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Bildirim Ayarları
          const Text(
            'Bildirim Ayarları',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Sabah Bildirimi
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(
                    'Sabah Duası Bildirimi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    _sabahBildirimi 
                        ? 'Her gün ${_sabahSaat.format(context)} saatinde'
                        : 'Kapalı',
                  ),
                  value: _sabahBildirimi,
                  activeColor: AppTheme.primaryYellow,
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.lightYellow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.wb_sunny,
                      color: AppTheme.darkYellow,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _sabahBildirimi = value);
                    _saveSetting('sabah_bildirim', value);
                  },
                ),
                if (_sabahBildirimi)
                  ListTile(
                    leading: const SizedBox(width: 40),
                    title: const Text('Bildirim Saati'),
                    trailing: TextButton.icon(
                      onPressed: () => _selectTime(context, 'sabah'),
                      icon: const Icon(Icons.access_time),
                      label: Text(_sabahSaat.format(context)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.darkYellow,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Akşam Bildirimi
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(
                    'Akşam Duası Bildirimi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    _aksamBildirimi 
                        ? 'Her gün ${_aksamSaat.format(context)} saatinde'
                        : 'Kapalı',
                  ),
                  value: _aksamBildirimi,
                  activeColor: AppTheme.primaryYellow,
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.lightYellow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.wb_twilight,
                      color: AppTheme.darkYellow,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _aksamBildirimi = value);
                    _saveSetting('aksam_bildirim', value);
                  },
                ),
                if (_aksamBildirimi)
                  ListTile(
                    leading: const SizedBox(width: 40),
                    title: const Text('Bildirim Saati'),
                    trailing: TextButton.icon(
                      onPressed: () => _selectTime(context, 'aksam'),
                      icon: const Icon(Icons.access_time),
                      label: Text(_aksamSaat.format(context)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.darkYellow,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 12),

          // Yatmadan Önce Bildirimi
          Card(
            child: Column(
              children: [
                SwitchListTile(
                  title: const Text(
                    'Uyku Duası Bildirimi',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  subtitle: Text(
                    _yatsiOncesiBildirimi 
                        ? 'Her gün ${_yatsiSaat.format(context)} saatinde'
                        : 'Kapalı',
                  ),
                  value: _yatsiOncesiBildirimi,
                  activeColor: AppTheme.primaryYellow,
                  secondary: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppTheme.lightYellow,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(
                      Icons.nightlight_round,
                      color: AppTheme.darkYellow,
                    ),
                  ),
                  onChanged: (value) {
                    setState(() => _yatsiOncesiBildirimi = value);
                    _saveSetting('yatsi_bildirim', value);
                  },
                ),
                if (_yatsiOncesiBildirimi)
                  ListTile(
                    leading: const SizedBox(width: 40),
                    title: const Text('Bildirim Saati'),
                    trailing: TextButton.icon(
                      onPressed: () => _selectTime(context, 'yatsi'),
                      icon: const Icon(Icons.access_time),
                      label: Text(_yatsiSaat.format(context)),
                      style: TextButton.styleFrom(
                        foregroundColor: AppTheme.darkYellow,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Dualar Bölümü
          const Text(
            'Günlük Dualar',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Sabah Duaları
          _buildDuaSection('Sabah Duaları', Icons.wb_sunny, _sabahDualari),
          const SizedBox(height: 16),

          // Akşam Duaları
          _buildDuaSection('Akşam Duaları', Icons.wb_twilight, _aksamDualari),
          const SizedBox(height: 16),

          // Yatmadan Önce Dualar
          _buildDuaSection('Uyku Duaları', Icons.nightlight_round, _yatsiDualari),
        ],
      ),
    );
  }

  Widget _buildDuaSection(String baslik, IconData icon, List<Map<String, String>> dualar) {
    return Card(
      child: ExpansionTile(
        leading: Icon(icon, color: AppTheme.primaryYellow),
        title: Text(
          baslik,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        children: dualar.map((dua) {
          return Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(
                  dua['baslik']!,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: AppTheme.darkYellow,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  dua['arapca']!,
                  style: const TextStyle(
                    fontSize: 20,
                    height: 2,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.right,
                  textDirection: TextDirection.rtl,
                ),
                const Divider(height: 24),
                Text(
                  dua['turkce']!,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[700],
                    height: 1.5,
                  ),
                ),
                if (dua != dualar.last) const Divider(height: 32),
              ],
            ),
          );
        }).toList(),
      ),
    );
  }
}
