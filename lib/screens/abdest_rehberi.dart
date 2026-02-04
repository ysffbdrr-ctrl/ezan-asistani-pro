import 'package:flutter/material.dart';
import 'package:ezan_asistani/theme/app_theme.dart';

class AbdestRehberi extends StatefulWidget {
  const AbdestRehberi({Key? key}) : super(key: key);

  @override
  State<AbdestRehberi> createState() => _AbdestRehberiState();
}

class _AbdestRehberiState extends State<AbdestRehberi> {
  int _currentStep = 0;

  final List<Map<String, dynamic>> _abdestAdimlari = [
    {
      'baslik': '1. Niyyet',
      'aciklama': 'Abdest almak niyeti ile başlayın. "Allahu Ekber" diyerek başlayabilirsiniz.',
      'icon': Icons.favorite,
      'emoji': '❤️',
    },
    {
      'baslik': '2. Elleri Yıkama',
      'aciklama': 'Sağ elinizle sol elinizi, sol elinizle sağ elinizi yıkayın. Parmak aralarına su geçirin. En az 3 defa yapın.',
      'icon': Icons.pan_tool,
      'emoji': '🤲',
    },
    {
      'baslik': '3. Ağız Durusu',
      'aciklama': 'Avuç avuç su alarak ağzınızı duruslayın. Eğer oruçlu değilseniz, su ağzınızın içine girsin. En az 3 defa yapın.',
      'icon': Icons.water_drop,
      'emoji': '💧',
    },
    {
      'baslik': '4. Burun Durusu',
      'aciklama': 'Avuç avuç su alarak burnunuzu duruslayın. Sağ elinizle burnunuzu temizleyin. En az 3 defa yapın.',
      'icon': Icons.face,
      'emoji': '👃',
    },
    {
      'baslik': '5. Yüz Yıkama',
      'aciklama': 'Yüzünüzü alnızdan çeneye kadar, kulaktan kulağa kadar yıkayın. Çok sıcak veya çok soğuk su kullanmayın. En az 3 defa yapın.',
      'icon': Icons.face_retouching_natural,
      'emoji': '😊',
    },
    {
      'baslik': '6. Kolları Yıkama',
      'aciklama': 'Sağ kolunuzu dirsekten parmak uçlarına kadar yıkayın. Sonra sol kolunuzu aynı şekilde yıkayın. En az 3 defa yapın.',
      'icon': Icons.accessibility,
      'emoji': '💪',
    },
    {
      'baslik': '7. Başı Mesh Etme',
      'aciklama': 'Islak ellerinizle başınızın ön tarafından arkasına doğru mesh edin. Kulakları da mesh etmeyi unutmayın.',
      'icon': Icons.person_outline,
      'emoji': '👤',
    },
    {
      'baslik': '8. Ayakları Yıkama',
      'aciklama': 'Sağ ayağınızı bilekten parmak uçlarına kadar yıkayın. Parmak aralarına su geçirin. Sonra sol ayağınızı aynı şekilde yıkayın. En az 3 defa yapın.',
      'icon': Icons.directions_walk,
      'emoji': '🦶',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('🧼 Abdest Rehberi'),
        backgroundColor: AppTheme.primaryYellow,
        elevation: 0,
      ),
      body: Column(
        children: [
          // Progress Bar
          Container(
            padding: const EdgeInsets.all(16),
            color: AppTheme.primaryYellow.withOpacity(0.1),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Adım ${_currentStep + 1}/${_abdestAdimlari.length}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Text(
                      '${((_currentStep + 1) / _abdestAdimlari.length * 100).toStringAsFixed(0)}%',
                      style: TextStyle(
                        fontSize: 14,
                        color: AppTheme.primaryYellow,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: (_currentStep + 1) / _abdestAdimlari.length,
                    minHeight: 8,
                    backgroundColor: Colors.grey[300],
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.primaryYellow,
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Content
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Step Icon
                  Container(
                    width: 100,
                    height: 100,
                    decoration: BoxDecoration(
                      color: AppTheme.primaryYellow.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Text(
                        _abdestAdimlari[_currentStep]['emoji'],
                        style: const TextStyle(fontSize: 50),
                      ),
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Step Title
                  Text(
                    _abdestAdimlari[_currentStep]['baslik'],
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  // Step Description
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.grey[100],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.primaryYellow.withOpacity(0.3),
                      ),
                    ),
                    child: Text(
                      _abdestAdimlari[_currentStep]['aciklama'],
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.6,
                      ),
                      textAlign: TextAlign.justify,
                    ),
                  ),
                  const SizedBox(height: 24),
                  // Tips
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue[50],
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                        color: Colors.blue[200]!,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: Colors.blue[700],
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            'Her adımı en az 3 defa yapın.',
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.blue[700],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Navigation Buttons
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                // Previous Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _currentStep > 0
                        ? () {
                            setState(() {
                              _currentStep--;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Geri'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey[400],
                      disabledBackgroundColor: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Next Button
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _currentStep < _abdestAdimlari.length - 1
                        ? () {
                            setState(() {
                              _currentStep++;
                            });
                          }
                        : null,
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('İleri'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryYellow,
                      disabledBackgroundColor: Colors.grey[200],
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Complete Button
          if (_currentStep == _abdestAdimlari.length - 1)
            Padding(
              padding: const EdgeInsets.only(bottom: 16, left: 16, right: 16),
              child: ElevatedButton.icon(
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('✅ Abdest tamamlandı! Namazınız kabul olsun.'),
                      backgroundColor: Colors.green,
                      duration: Duration(seconds: 2),
                    ),
                  );
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.check_circle),
                label: const Text('Abdest Tamamlandı'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.green,
                  minimumSize: const Size(double.infinity, 50),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
