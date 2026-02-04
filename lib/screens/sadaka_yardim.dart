import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ezan_asistani/theme/app_theme.dart';
import 'package:ezan_asistani/services/gamification_service.dart';
import 'package:ezan_asistani/services/payment_service.dart';
import 'package:ezan_asistani/services/rewarded_ad_service.dart';
import 'package:ezan_asistani/services/ads_removal_service.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:in_app_purchase/in_app_purchase.dart';
import 'dart:math';
import 'dart:async';

class SadakaYardim extends StatefulWidget {
  const SadakaYardim({Key? key}) : super(key: key);

  @override
  State<SadakaYardim> createState() => _SadakaYardimState();
}

class _SadakaYardimState extends State<SadakaYardim> with TickerProviderStateMixin {
  double _totalDonated = 0;
  int _donationCount = 0;
  List<Map<String, dynamic>> _recentDonations = [];
  
  late AnimationController _heartController;
  late AnimationController _confettiController;
  bool _showAnimation = false;
  bool _paymentAvailable = false;
  late StreamSubscription<List<PurchaseDetails>> _purchaseStreamSubscription;

  final List<int> _quickAmounts = [2, 5, 10, 20, 50, 100];
  
  // Gerçek bağış kuruluşları
  final List<Map<String, String>> _charities = [
    {
      'name': 'Kızılay',
      'description': 'Türk Kızılayı - Acil Yardım ve Sosyal Hizmetler',
      'url': 'https://www.kizilay.org.tr',
      'icon': '🏥',
    },
    {
      'name': 'Diyanet Vakfı',
      'description': 'Türkiye Diyanet Vakfı - Din Hizmetleri',
      'url': 'https://www.diyanet.gov.tr',
      'icon': '🕌',
    },
    {
      'name': 'Gıda Bankası',
      'description': 'Türkiye Gıda Bankası - Gıda Yardımı',
      'url': 'https://www.gidabankasi.org.tr',
      'icon': '🍽️',
    },
    {
      'name': 'Çocuk Esirgeme Kurumu',
      'description': 'ÇEK - Çocuk Yardımı ve Korunması',
      'url': 'https://www.cecek.org.tr',
      'icon': '👶',
    },
    {
      'name': 'Eğitim Gönüllüleri Vakfı',
      'description': 'TEGV - Eğitim Desteği',
      'url': 'https://www.tegv.org',
      'icon': '📚',
    },
    {
      'name': 'Hayvan Hakları Federasyonu',
      'description': 'Hayvan Koruma ve Bakımı',
      'url': 'https://www.hayvanhaklari.net',
      'icon': '🐾',
    },
  ];

  @override
  void initState() {
    super.initState();
    _loadStats();
    _initializePaymentService();
    RewardedAdService.instance.preload();
    
    _heartController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    
    _confettiController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    );
  }

  Future<void> _watchSupportAd() async {
    final earned = await RewardedAdService.instance.show();
    if (!mounted) return;

    if (earned) {
      await GamificationService.addPoints('support_ad', 50);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Teşekkürler! +50 puan kazandın.'),
          backgroundColor: Colors.green,
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Reklam şu an hazır değil. Lütfen biraz sonra tekrar dene.'),
          backgroundColor: Colors.orange,
        ),
      );
    }
  }

  Future<void> _initializePaymentService() async {
    try {
      final available = await PaymentService.initialize();
      setState(() {
        _paymentAvailable = available;
      });
      
      // Satın alma akışını dinle
      _purchaseStreamSubscription = PaymentService.getPurchaseStream().listen(
        (List<PurchaseDetails> purchaseDetailsList) {
          _handlePurchaseUpdates(purchaseDetailsList);
        },
        onError: (error) {
          print('Purchase stream error: $error');
        },
      );
      
      // Bekleyen satın almaları tamamla
      await PaymentService.completePendingPurchases();
    } catch (e) {
      print('Error initializing payment service: $e');
    }
  }

  Future<void> _handlePurchaseUpdates(List<PurchaseDetails> purchaseDetailsList) async {
    for (var purchase in purchaseDetailsList) {
      if (purchase.status == PurchaseStatus.purchased) {
        // Satın alma başarılı
        final amount = _extractAmountFromProductId(purchase.productID);
        if (amount != null) {
          await PaymentService.savePurchaseHistory(amount);
          await _makeDonation(amount.toDouble());
          
          if (purchase.pendingCompletePurchase) {
            await InAppPurchase.instance.completePurchase(purchase);
          }
        }
      } else if (purchase.status == PurchaseStatus.error) {
        print('Satın alma hatası: ${purchase.error}');
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
        }
      } else if (purchase.status == PurchaseStatus.canceled) {
        print('Satın alma iptal edildi');
        if (purchase.pendingCompletePurchase) {
          await InAppPurchase.instance.completePurchase(purchase);
        }
      }
    }
  }

  int? _extractAmountFromProductId(String productId) {
    // Ürün ID'sinden tutarı çıkar (örn: 'sadaka_10tl' -> 10)
    try {
      final match = RegExp(r'sadaka_(\d+)tl').firstMatch(productId);
      if (match != null) {
        return int.parse(match.group(1)!);
      }
    } catch (e) {
      print('Error extracting amount: $e');
    }
    return null;
  }

  @override
  void dispose() {
    _heartController.dispose();
    _confettiController.dispose();
    _purchaseStreamSubscription.cancel();
    super.dispose();
  }

  Future<void> _loadStats() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _totalDonated = prefs.getDouble('total_sadaka') ?? 0;
      _donationCount = prefs.getInt('sadaka_count') ?? 0;
      
      // Son bağışları yükle (son 10 kayıt)
      List<String> donations = prefs.getStringList('recent_sadaka') ?? [];
      _recentDonations = donations.map((d) {
        List<String> parts = d.split('|');
        return {
          'amount': double.parse(parts[0]),
          'date': parts[1],
        };
      }).toList();
    });
  }

  Future<void> _makeDonation(double amount) async {
    final prefs = await SharedPreferences.getInstance();
    
    // İstatistikleri güncelle
    _totalDonated += amount;
    _donationCount++;
    
    await prefs.setDouble('total_sadaka', _totalDonated);
    await prefs.setInt('sadaka_count', _donationCount);
    
    // Son bağışlara ekle
    String now = DateTime.now().toString().substring(0, 16);
    _recentDonations.insert(0, {
      'amount': amount,
      'date': now,
    });
    
    // Sadece son 10'unu tut
    if (_recentDonations.length > 10) {
      _recentDonations = _recentDonations.sublist(0, 10);
    }
    
    // Kaydet
    List<String> donations = _recentDonations.map((d) {
      return '${d['amount']}|${d['date']}';
    }).toList();
    await prefs.setStringList('recent_sadaka', donations);
    
    // Puan ekle (sadaka başına 5 puan)
    await GamificationService.addPoints('sadaka', 5);
    
    setState(() {});
    
    // Animasyonu göster
    _playThankYouAnimation();
  }

  void _playThankYouAnimation() {
    setState(() {
      _showAnimation = true;
    });
    
    _heartController.forward(from: 0);
    _confettiController.forward(from: 0);
    
    Future.delayed(const Duration(milliseconds: 2000), () {
      if (mounted) {
        setState(() {
          _showAnimation = false;
        });
      }
    });
  }

  void _showDonationDialog(int amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Row(
          children: [
            const Icon(Icons.volunteer_activism, color: AppTheme.primaryYellow),
            const SizedBox(width: 12),
            const Text('Sadaka Ver'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              '$amount TL',
              style: const TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryYellow,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Sadaka vermek için onaylıyor musunuz?',
              textAlign: TextAlign.center,
            ),
            if (_paymentAvailable)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  '💳 Gerçek ödeme ile',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.grey[600],
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          if (_paymentAvailable)
            ElevatedButton(
              onPressed: () async {
                Navigator.pop(context);
                await _purchaseDonation(amount);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('Ödeme Yap'),
            ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _makeDonation(amount.toDouble());
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryYellow,
              foregroundColor: Colors.black,
            ),
            child: const Text('Kayıt Et'),
          ),
        ],
      ),
    );
  }

  Future<void> _purchaseDonation(int amount) async {
    try {
      final success = await PaymentService.purchaseDonation(amount);
      if (!success) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Ürün bulunamadı. Lütfen daha sonra tekrar deneyiniz.'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    } catch (e) {
      print('Error purchasing donation: $e');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Hata: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  void _showCustomAmountDialog() {
    final controller = TextEditingController();
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Özel Tutar'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: controller,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: 'Tutar (TL)',
                prefixIcon: Icon(Icons.attach_money),
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
          ElevatedButton(
            onPressed: () {
              double? amount = double.tryParse(controller.text);
              if (amount != null && amount > 0) {
                Navigator.pop(context);
                _makeDonation(amount);
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryYellow,
              foregroundColor: Colors.black,
            ),
            child: const Text('Onayla'),
          ),
        ],
      ),
    );
  }

  void _showSupportDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Row(
          children: [
            Icon(Icons.favorite, color: Colors.red),
            SizedBox(width: 12),
            Text('Destek Ol'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              'Ezan Asistanı Pro\'yu desteklemek için destek tutarı seçin:',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 14),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [5, 10, 25, 50, 100].map((amount) {
                return SizedBox(
                  width: (MediaQuery.of(context).size.width - 80) / 3,
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                      _showDonationDialog(amount);
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryYellow,
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: Text('$amount TL'),
                  ),
                );
              }).toList(),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  Navigator.pop(context);
                  _showCustomAmountDialog();
                },
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: AppTheme.primaryYellow),
                  padding: const EdgeInsets.symmetric(vertical: 12),
                ),
                child: const Text(
                  'Özel Tutar',
                  style: TextStyle(color: AppTheme.primaryYellow),
                ),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('İptal'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sadaka & Yardım'),
        elevation: 2,
      ),
      body: Stack(
        children: [
          ListView(
            padding: const EdgeInsets.all(16),
            children: [
              // Gerçek Bağış Kuruluşları
              const Text(
                'Bağış Yapabileceğiniz Kuruluşlar',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _charities.length,
                itemBuilder: (context, index) {
                  final charity = _charities[index];
                  return GestureDetector(
                    onTap: () async {
                      final url = charity['url']!;
                      if (await canLaunchUrl(Uri.parse(url))) {
                        await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            Text(
                              charity['icon']!,
                              style: const TextStyle(fontSize: 32),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    charity['name']!,
                                    style: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    charity['description']!,
                                    style: TextStyle(
                                      fontSize: 12,
                                      color: Colors.grey[600],
                                    ),
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const Icon(Icons.open_in_new, size: 20, color: AppTheme.primaryYellow),
                          ],
                        ),
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 24),

              // İstatistik Kartı
              Card(
                elevation: 4,
                color: AppTheme.primaryYellow,
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    children: [
                      const Icon(
                        Icons.favorite,
                        size: 48,
                        color: Colors.red,
                      ),
                      const SizedBox(height: 12),
                      const Text(
                        'Toplam Sadaka',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${_totalDonated.toStringAsFixed(2)} TL',
                        style: const TextStyle(
                          fontSize: 36,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '$_donationCount bağış yapıldı',
                        style: const TextStyle(
                          fontSize: 14,
                          color: Colors.black87,
                        ),
                      ),
                      const SizedBox(height: 12),
                      ValueListenableBuilder<bool>(
                        valueListenable: AdsRemovalService.adsRemoved,
                        builder: (context, removed, _) {
                          if (removed) return const SizedBox.shrink();
                          return SizedBox(
                            width: double.infinity,
                            child: OutlinedButton.icon(
                              onPressed: _watchSupportAd,
                              icon: const Icon(Icons.ondemand_video),
                              label: const Text('Gönüllü Reklam İzle (+50 puan)'),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: AppTheme.primaryYellow),
                                foregroundColor: AppTheme.primaryYellow,
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Hızlı Bağış Butonları
              const Text(
                'Hızlı Bağış',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.2,
                ),
                itemCount: _quickAmounts.length,
                itemBuilder: (context, index) {
                  int amount = _quickAmounts[index];
                  return InkWell(
                    onTap: () => _showDonationDialog(amount),
                    child: Card(
                      elevation: 4,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.volunteer_activism,
                            color: AppTheme.primaryYellow,
                            size: 32,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            '$amount TL',
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              const SizedBox(height: 16),

              // Özel Tutar Butonu
              ElevatedButton.icon(
                onPressed: _showCustomAmountDialog,
                icon: const Icon(Icons.edit),
                label: const Text('Özel Tutar Gir'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryYellow,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.all(16),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(height: 24),

              // Son Bağışlar
              if (_recentDonations.isNotEmpty) ...[
                const Text(
                  'Son Bağışlarım',
                  style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                ..._recentDonations.map((donation) {
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppTheme.lightYellow,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.check_circle,
                          color: Colors.green,
                        ),
                      ),
                      title: Text(
                        '${donation['amount']} TL',
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      subtitle: Text(
                        donation['date'],
                        style: const TextStyle(fontSize: 12),
                      ),
                      trailing: const Icon(Icons.favorite, color: Colors.red),
                    ),
                  );
                }).toList(),
              ],

              const SizedBox(height: 24),

              // Destek Ol Bölümü
              const Text(
                'Ezan Asistanı Pro\'yu Destekle',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
              ),
              const SizedBox(height: 12),
              Card(
                elevation: 2,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.favorite, color: Colors.red, size: 28),
                          SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Uygulama Geliştirme Desteği',
                                  style: TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  'Uygulamayı geliştirmemize yardım edin',
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const Text(
                        'Ezan Asistanı Pro\'yu destekleyerek, daha iyi özellikler ve hizmetler geliştirmemize yardımcı olabilirsiniz.',
                        style: TextStyle(
                          fontSize: 13,
                          height: 1.5,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton.icon(
                          onPressed: () => _showSupportDialog(),
                          icon: const Icon(Icons.favorite),
                          label: const Text('Destek Ol'),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(vertical: 12),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 24),

              // Sadaka Hakkında
              Card(
                color: AppTheme.lightYellow,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.lightbulb, color: AppTheme.darkYellow),
                          SizedBox(width: 8),
                          Text(
                            'Sadaka Hakkında',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Text(
                        '"Kim Allah yolunda bir şey tasadduk ederse, ona 700 kat sevap yazılır."'
                        '\n- Hadis-i Şerif'
                        '\n\nSadaka, Allah\'a yakınlaşmanın ve kardeşlerimize yardım etmenin güzel bir yoludur.',
                        style: TextStyle(
                          fontSize: 13,
                          color: Colors.grey[800],
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),

          // Teşekkür Animasyonu
          if (_showAnimation)
            ThankYouAnimation(
              heartController: _heartController,
              confettiController: _confettiController,
            ),
        ],
      ),
    );
  }
}

// Teşekkür Animasyonu Widget'ı
class ThankYouAnimation extends StatelessWidget {
  final AnimationController heartController;
  final AnimationController confettiController;

  const ThankYouAnimation({
    Key? key,
    required this.heartController,
    required this.confettiController,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.black54,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Kalp Animasyonu
            ScaleTransition(
              scale: Tween<double>(begin: 0.0, end: 1.2).animate(
                CurvedAnimation(
                  parent: heartController,
                  curve: Curves.elasticOut,
                ),
              ),
              child: const Icon(
                Icons.favorite,
                size: 120,
                color: Colors.red,
              ),
            ),
            const SizedBox(height: 24),
            
            // Teşekkür Metni
            FadeTransition(
              opacity: heartController,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Column(
                  children: [
                    Text(
                      'Teşekkürler! 🤲',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: AppTheme.primaryYellow,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Allah kabul etsin',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.black87,
                      ),
                    ),
                    SizedBox(height: 8),
                    Text(
                      '+5 Puan Kazandın! ⭐',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            
            // Konfeti Efekti
            AnimatedBuilder(
              animation: confettiController,
              builder: (context, child) {
                return Stack(
                  children: List.generate(20, (index) {
                    final random = Random(index);
                    final startX = random.nextDouble() * MediaQuery.of(context).size.width;
                    final endY = MediaQuery.of(context).size.height;
                    final color = [
                      Colors.red,
                      Colors.blue,
                      Colors.green,
                      Colors.yellow,
                      Colors.purple,
                    ][random.nextInt(5)];

                    return Positioned(
                      left: startX,
                      top: -50 + (endY * confettiController.value),
                      child: Transform.rotate(
                        angle: confettiController.value * 4 * pi,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                      ),
                    );
                  }),
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
