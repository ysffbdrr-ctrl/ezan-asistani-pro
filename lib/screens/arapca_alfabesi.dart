import 'package:flutter/material.dart';
import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ArapcaAlfabesi extends StatefulWidget {
  const ArapcaAlfabesi({Key? key}) : super(key: key);

  @override
  State<ArapcaAlfabesi> createState() => _ArapcaAlfabesiState();
}

class _ArapcaAlfabesiState extends State<ArapcaAlfabesi> {
  int _selectedIndex = 0;
  late FlutterTts _flutterTts;
  bool _isTtsInitialized = false;

  final List<Map<String, String>> harfler = [
    {'harf': 'ا', 'isim': 'Elif', 'telaffuz': 'A', 'aciklama': 'Uzun A sesi'},
    {'harf': 'ب', 'isim': 'Be', 'telaffuz': 'B', 'aciklama': 'B harfi gibi'},
    {'harf': 'ت', 'isim': 'Te', 'telaffuz': 'T', 'aciklama': 'T harfi gibi'},
    {'harf': 'ث', 'isim': 'Se', 'telaffuz': 'S (th)', 'aciklama': 'İngilizce "th" sesi'},
    {'harf': 'ج', 'isim': 'Cim', 'telaffuz': 'C', 'aciklama': 'C harfi gibi'},
    {'harf': 'ح', 'isim': 'Ha', 'telaffuz': 'H', 'aciklama': 'Boğazdan çıkan H sesi'},
    {'harf': 'خ', 'isim': 'Hı', 'telaffuz': 'H (kh)', 'aciklama': 'Almanca "ch" sesi gibi'},
    {'harf': 'د', 'isim': 'Dal', 'telaffuz': 'D', 'aciklama': 'D harfi gibi'},
    {'harf': 'ذ', 'isim': 'Zel', 'telaffuz': 'Z (dh)', 'aciklama': 'İngilizce "the" deki "th" sesi'},
    {'harf': 'ر', 'isim': 'Ra', 'telaffuz': 'R', 'aciklama': 'R harfi, kalın'},
    {'harf': 'ز', 'isim': 'Ze', 'telaffuz': 'Z', 'aciklama': 'Z harfi gibi'},
    {'harf': 'س', 'isim': 'Sin', 'telaffuz': 'S', 'aciklama': 'S harfi gibi'},
    {'harf': 'ش', 'isim': 'Şin', 'telaffuz': 'Ş', 'aciklama': 'Ş harfi gibi'},
    {'harf': 'ص', 'isim': 'Sad', 'telaffuz': 'S (kalın)', 'aciklama': 'Kalın S sesi'},
    {'harf': 'ض', 'isim': 'Dad', 'telaffuz': 'D (kalın)', 'aciklama': 'Kalın D sesi'},
    {'harf': 'ط', 'isim': 'Tı', 'telaffuz': 'T (kalın)', 'aciklama': 'Kalın T sesi'},
    {'harf': 'ظ', 'isim': 'Zı', 'telaffuz': 'Z (kalın)', 'aciklama': 'Kalın Z sesi'},
    {'harf': 'ع', 'isim': 'Ayn', 'telaffuz': 'A (boğaz)', 'aciklama': 'Boğazdan çıkan A sesi'},
    {'harf': 'غ', 'isim': 'Ğayn', 'telaffuz': 'Ğ', 'aciklama': 'Yumuşak G gibi'},
    {'harf': 'ف', 'isim': 'Fe', 'telaffuz': 'F', 'aciklama': 'F harfi gibi'},
    {'harf': 'ق', 'isim': 'Kaf', 'telaffuz': 'K (kalın)', 'aciklama': 'Kalın K sesi'},
    {'harf': 'ك', 'isim': 'Kef', 'telaffuz': 'K', 'aciklama': 'K harfi gibi'},
    {'harf': 'ل', 'isim': 'Lam', 'telaffuz': 'L', 'aciklama': 'L harfi gibi'},
    {'harf': 'م', 'isim': 'Mim', 'telaffuz': 'M', 'aciklama': 'M harfi gibi'},
    {'harf': 'ن', 'isim': 'Nun', 'telaffuz': 'N', 'aciklama': 'N harfi gibi'},
    {'harf': 'ه', 'isim': 'He', 'telaffuz': 'H', 'aciklama': 'Hafif H sesi'},
    {'harf': 'و', 'isim': 'Vav', 'telaffuz': 'V/U', 'aciklama': 'V veya U sesi'},
    {'harf': 'ي', 'isim': 'Ye', 'telaffuz': 'Y/İ', 'aciklama': 'Y veya İ sesi'},
    {'harf': 'ء', 'isim': 'Hemze', 'telaffuz': 'E', 'aciklama': 'Boğaz kapanması'},
  ];

  @override
  void initState() {
    super.initState();
    _initializeTts();
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

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Arapça Alfabesi'),
        elevation: 2,
      ),
      body: Column(
        children: [
          // Üst bilgi kartı
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryYellow,
                  AppTheme.primaryYellow.withOpacity(0.7),
                ],
              ),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.abc,
                  size: 48,
                  color: Colors.white,
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '29 Arapça Harf',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      SizedBox(height: 4),
                      Text(
                        'Her harfin telaffuzunu öğrenin',
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.white70,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Harf Detayı
          Container(
            height: 200,
            margin: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              elevation: 4,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      harfler[_selectedIndex]['harf']!,
                      style: const TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          harfler[_selectedIndex]['isim']!,
                          style: const TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(width: 8),
                        IconButton(
                          icon: const Icon(Icons.volume_up),
                          color: AppTheme.primaryYellow,
                          iconSize: 30,
                          onPressed: () => _speak(harfler[_selectedIndex]['harf']!),
                          tooltip: 'Telaffuzu Dinle',
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 4,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryYellow.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        'Telaffuz: ${harfler[_selectedIndex]['telaffuz']}',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 32),
                      child: Text(
                        harfler[_selectedIndex]['aciklama']!,
                        style: TextStyle(
                          fontSize: 14,
                          color: Colors.grey[600],
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Navigasyon butonları
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedIndex > 0
                        ? () {
                            setState(() {
                              _selectedIndex--;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Önceki'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryYellow,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Text(
                  '${_selectedIndex + 1} / ${harfler.length}',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _selectedIndex < harfler.length - 1
                        ? () {
                            setState(() {
                              _selectedIndex++;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Sonraki'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryYellow,
                      foregroundColor: Colors.black,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),
          const Divider(),
          
          // Harf listesi
          Expanded(
            child: GridView.builder(
              padding: const EdgeInsets.all(16),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 6,
                childAspectRatio: 1,
                crossAxisSpacing: 8,
                mainAxisSpacing: 8,
              ),
              itemCount: harfler.length,
              itemBuilder: (context, index) {
                final isSelected = index == _selectedIndex;
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      _selectedIndex = index;
                    });
                  },
                  child: Container(
                    decoration: BoxDecoration(
                      color: isSelected
                          ? AppTheme.primaryYellow
                          : Colors.grey[200],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: isSelected
                            ? AppTheme.primaryYellow
                            : Colors.grey[300]!,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          harfler[index]['harf']!,
                          style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: isSelected ? Colors.white : Colors.black,
                          ),
                        ),
                        Text(
                          harfler[index]['isim']!,
                          style: TextStyle(
                            fontSize: 10,
                            color: isSelected ? Colors.white70 : Colors.grey[600],
                          ),
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
}
