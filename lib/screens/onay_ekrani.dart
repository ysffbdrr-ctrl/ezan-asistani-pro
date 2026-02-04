import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:ezan_asistani/screens/gizlilik_politikasi.dart';
import 'package:ezan_asistani/screens/kullanim_kosullari.dart';

class OnayEkrani extends StatefulWidget {
  final VoidCallback onAccepted;

  const OnayEkrani({
    Key? key,
    required this.onAccepted,
  }) : super(key: key);

  @override
  State<OnayEkrani> createState() => _OnayEkraniState();
}

class _OnayEkraniState extends State<OnayEkrani> {
  bool _gizlilikKabul = false;
  bool _kullanimKabul = false;
  int _adim = 0;

  Future<void> _onayVer() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('kosullar_kabul_edildi', true);
    await prefs.setString('kabul_tarihi', DateTime.now().toIso8601String());
    
    // Kullanıcı seçimlerini kaydet
    await prefs.setBool('gizlilik_kabul', _gizlilikKabul);
    await prefs.setBool('kullanim_kabul', _kullanimKabul);

    widget.onAccepted();
  }

  void _devamEt() {
    if (_adim == 0 && _kullanimKabul) {
      setState(() {
        _adim = 1;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bool devamEnabled = _adim == 0 ? _kullanimKabul : (_kullanimKabul && _gizlilikKabul);

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 40),
              
              // Logo/Icon
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppTheme.primaryYellow.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.mosque,
                  size: 80,
                  color: AppTheme.primaryYellow,
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Başlık
              const Text(
                'Ezan Asistanı Pro',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                ),
              ),
              
              const SizedBox(height: 8),
              
              Text(
                'İslami Uygulamalar',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey[600],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Hoşgeldiniz mesajı
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.grey[100],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    const Icon(
                      Icons.waving_hand,
                      size: 32,
                      color: Colors.orange,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Hoş Geldiniz!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Devam etmek için lütfen gizlilik politikası ve kullanım koşullarını okuyup kabul edin.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 14,
                        color: Colors.grey[700],
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 32),

              if (_adim == 0) ...[
                Card(
                  child: CheckboxListTile(
                    value: _kullanimKabul,
                    onChanged: (value) {
                      setState(() => _kullanimKabul = value ?? false);
                    },
                    activeColor: AppTheme.primaryYellow,
                    title: const Text('Kullanım Koşulları'),
                    subtitle: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const KullanimKosullari(),
                          ),
                        );
                      },
                      child: Text(
                        'Okumak için tıklayın',
                        style: TextStyle(
                          color: AppTheme.primaryYellow,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    secondary: Icon(
                      Icons.description,
                      color: _kullanimKabul ? AppTheme.primaryYellow : Colors.grey,
                    ),
                  ),
                ),
              ] else ...[
                Card(
                  child: CheckboxListTile(
                    value: _gizlilikKabul,
                    onChanged: (value) {
                      setState(() => _gizlilikKabul = value ?? false);
                    },
                    activeColor: AppTheme.primaryYellow,
                    title: const Text('Gizlilik Politikası'),
                    subtitle: GestureDetector(
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const GizlilikPolitikasi(),
                          ),
                        );
                      },
                      child: Text(
                        'Okumak için tıklayın',
                        style: TextStyle(
                          color: AppTheme.primaryYellow,
                          decoration: TextDecoration.underline,
                        ),
                      ),
                    ),
                    secondary: Icon(
                      Icons.shield,
                      color: _gizlilikKabul ? AppTheme.primaryYellow : Colors.grey,
                    ),
                  ),
                ),
              ],
              
              const SizedBox(height: 32),
              
              // Kabul Et Butonu
              SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  onPressed: devamEnabled
                      ? (_adim == 0 ? _devamEt : _onayVer)
                      : null,
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.check_circle,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        _adim == 0 ? 'Devam Et' : 'Kabul Et ve Devam Et',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              const SizedBox(height: 24),
              
              // Bilgi metni
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.blue[50],
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: Colors.blue[200]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline, color: Colors.blue[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Verileriniz güvende! Tüm bilgiler sadece cihazınızda saklanır.',
                        style: TextStyle(
                          fontSize: 12,
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
    );
  }
}
