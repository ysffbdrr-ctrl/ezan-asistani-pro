# Akıllı Ezan Bildirimleri - Kod Örnekleri

## 📚 Kod Örnekleri ve Kullanım Rehberi

---

## 1. Akıllı Bildirim Planlama

### Temel Kullanım

```dart
import 'package:ezan_asistani/services/notification_service.dart';

// NotificationService örneğini al
final notificationService = NotificationService();

// Akıllı bildirim planla
await notificationService.scheduleSmartPrayerNotification(
  id: 6,                                    // Bildirim ID
  prayerName: 'Yatsı',                     // Namaz adı
  scheduledTime: DateTime.now().add(       // Bildirim zamanı
    Duration(minutes: 10)
  ),
  minutesBefore: 10,                       // Kaç dakika öncesinden
);
```

### Tüm Namaz Vakitleri İçin Bildirim

```dart
Future<void> schedulePrayerNotifications() async {
  final prayers = [
    {'id': 1, 'name': 'İmsak'},
    {'id': 2, 'name': 'Güneş'},
    {'id': 3, 'name': 'Öğle'},
    {'id': 4, 'name': 'İkindi'},
    {'id': 5, 'name': 'Akşam'},
    {'id': 6, 'name': 'Yatsı'},
  ];

  for (var prayer in prayers) {
    await notificationService.scheduleSmartPrayerNotification(
      id: prayer['id'] as int,
      prayerName: prayer['name'] as String,
      scheduledTime: calculatePrayerTime(prayer['name'] as String)
          .subtract(Duration(minutes: 10)),
      minutesBefore: 10,
    );
  }
}
```

---

## 2. Bildirim Yanıtını İşleme

### Callback Ayarlama

```dart
import 'package:ezan_asistani/services/smart_notification_service.dart';

final smartNotificationService = SmartNotificationService();

// Bildirim yanıtını dinle
smartNotificationService.onNotificationAction = (actionId, prayerName) {
  print('Eylem: $actionId, Namaz: $prayerName');
  
  switch (actionId) {
    case 'abdest_var':
      handleAbdestVar(prayerName);
      break;
    case 'abdest_yok':
      handleAbdestYok(prayerName);
      break;
    case 'abdest_rehberi':
      navigateToAbdestGuide();
      break;
  }
};

void handleAbdestVar(String prayerName) {
  print('$prayerName için abdest var');
  // Gamification puanı ekle
  addGamificationPoints(prayerName, 'abdest_var', 5);
}

void handleAbdestYok(String prayerName) {
  print('$prayerName için abdest yok');
  // Abdest rehberine yönlendir
  navigateToAbdestGuide();
}

void navigateToAbdestGuide() {
  // Abdest rehberi ekranına git
  Navigator.of(context).pushNamed('/abdest-rehberi');
}
```

---

## 3. Bildirim Yönetimi

### Tüm Bildirimleri İptal Et

```dart
// Tüm bildirimleri iptal et
await notificationService.cancelAllNotifications();
print('Tüm bildirimler iptal edildi');
```

### Belirli Bildirimi İptal Et

```dart
// Yatsı bildirimi (ID: 6) iptal et
await notificationService.cancelNotification(6);
print('Yatsı bildirimi iptal edildi');
```

### Bekleyen Bildirimleri Listele

```dart
// Bekleyen bildirimleri al
final pending = await notificationService.getPendingNotifications();

print('Bekleyen bildirimler: ${pending.length}');
for (var notification in pending) {
  print('ID: ${notification.id}, Title: ${notification.title}');
}
```

### Anlık Bildirim Gönder

```dart
// Anlık bildirim gönder (zamanlamadan)
await notificationService.showNotification(
  id: 99,
  title: 'Test Bildirimi',
  body: 'Bu bir test bildirimidir',
);
```

---

## 4. Harita Seçeneklerini Göster

### Bottom Sheet ile Harita Seçimi

```dart
import 'package:ezan_asistani/screens/nearby_mosques.dart';

void showMapOptions(Mosque mosque) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (context) => Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Yol Tarifi Seçin',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 16),
          // Google Maps
          ListTile(
            leading: const Icon(Icons.map),
            title: const Text('Google Maps'),
            subtitle: const Text('Google haritasında aç'),
            onTap: () {
              Navigator.pop(context);
              launchGoogleMaps(mosque);
            },
          ),
          // Yandex Haritalar
          ListTile(
            leading: const Icon(Icons.location_on),
            title: const Text('Yandex Haritalar'),
            subtitle: const Text('Yandex haritasında aç'),
            onTap: () {
              Navigator.pop(context);
              launchYandexMaps(mosque);
            },
          ),
          // Maps.me
          ListTile(
            leading: const Icon(Icons.map_outlined),
            title: const Text('Maps.me'),
            subtitle: const Text('Maps.me uygulamasında aç'),
            onTap: () {
              Navigator.pop(context);
              launchMapsMeApp(mosque);
            },
          ),
        ],
      ),
    ),
  );
}
```

---

## 5. Harita Uygulamalarını Açma

### Google Maps

```dart
import 'package:url_launcher/url_launcher.dart';

Future<void> launchGoogleMaps(double latitude, double longitude) async {
  final String mapsUrl =
      'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
  
  try {
    if (await canLaunchUrl(Uri.parse(mapsUrl))) {
      await launchUrl(
        Uri.parse(mapsUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      print('Google Maps açılamadı');
    }
  } catch (e) {
    print('Hata: $e');
  }
}
```

### Yandex Haritalar

```dart
Future<void> launchYandexMaps(double latitude, double longitude) async {
  // Yandex Maps URL format: pt=longitude,latitude
  final String yandexUrl =
      'https://yandex.com/maps/?pt=$longitude,$latitude&z=16&l=map';
  
  try {
    if (await canLaunchUrl(Uri.parse(yandexUrl))) {
      await launchUrl(
        Uri.parse(yandexUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      print('Yandex Haritalar açılamadı');
    }
  } catch (e) {
    print('Hata: $e');
  }
}
```

### Maps.me

```dart
Future<void> launchMapsMeApp(double latitude, double longitude) async {
  // Maps.me URL format: geo:latitude,longitude
  final String mapsmeUrl =
      'https://maps.me/?url=geo:$latitude,$longitude?z=16';
  
  try {
    if (await canLaunchUrl(Uri.parse(mapsmeUrl))) {
      await launchUrl(
        Uri.parse(mapsmeUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      print('Maps.me açılamadı');
    }
  } catch (e) {
    print('Hata: $e');
  }
}
```

---

## 6. Hata Yönetimi

### Try-Catch ile Hata Yönetimi

```dart
Future<void> safeScheduleNotification(
  int id,
  String prayerName,
  DateTime scheduledTime,
) async {
  try {
    await notificationService.scheduleSmartPrayerNotification(
      id: id,
      prayerName: prayerName,
      scheduledTime: scheduledTime,
      minutesBefore: 10,
    );
    print('Bildirim başarıyla planlandı');
  } catch (e) {
    print('Bildirim planlama hatası: $e');
    // Kullanıcıya hata mesajı göster
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Bildirim planlanamadı: $e')),
    );
  }
}
```

### Harita Açma Hatası Yönetimi

```dart
Future<void> safeLaunchMaps(Mosque mosque) async {
  try {
    final String mapsUrl =
        'https://www.google.com/maps/search/?api=1&query=${mosque.latitude},${mosque.longitude}';
    
    if (await canLaunchUrl(Uri.parse(mapsUrl))) {
      await launchUrl(
        Uri.parse(mapsUrl),
        mode: LaunchMode.externalApplication,
      );
    } else {
      // Harita uygulaması yüklü değil
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Google Maps yüklü değil. Lütfen yükleyin.'),
        ),
      );
    }
  } catch (e) {
    // Hata oluştu
    AppLogger.error('Harita açma hatası', error: e);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Hata: $e')),
    );
  }
}
```

---

## 7. Gamification Entegrasyonu

### Bildirim Eylemi ile Puan Ekleme

```dart
import 'package:ezan_asistani/services/gamification_service.dart';

final gamificationService = GamificationService();

void handleNotificationAction(String actionId, String prayerName) {
  switch (actionId) {
    case 'abdest_var':
      // Abdest hazırlığı puanı
      gamificationService.addPoints(
        userId: getCurrentUserId(),
        points: 5,
        category: 'abdest_preparation',
        description: '$prayerName için abdest hazırlığı',
      );
      break;
      
    case 'abdest_yok':
      // Abdest rehberi puanı
      gamificationService.addPoints(
        userId: getCurrentUserId(),
        points: 10,
        category: 'abdest_learning',
        description: '$prayerName için abdest rehberi öğrenme',
      );
      break;
      
    case 'abdest_rehberi':
      // Eğitim puanı
      gamificationService.addPoints(
        userId: getCurrentUserId(),
        points: 15,
        category: 'education',
        description: '$prayerName için abdest rehberi tamamlama',
      );
      break;
  }
}
```

---

## 8. Logging ve Debug

### Bildirim Logları

```dart
import 'package:ezan_asistani/utils/logger.dart';

// Bildirim planlama logu
AppLogger.info(
  'Akıllı bildirim planlandı: $prayerName - $scheduledTime',
  tag: 'Notification',
);

// Bildirim eylemi logu
AppLogger.info(
  'Bildirim eylemi: $actionId, Payload: $payload',
  tag: 'Notification',
);

// Hata logu
AppLogger.error(
  'Bildirim planlama hatası',
  error: e,
  tag: 'Notification',
);
```

### Debug Modunda Bildirim Testi

```dart
// Debug modunda anlık bildirim gönder
if (kDebugMode) {
  await notificationService.showNotification(
    id: 999,
    title: 'Debug: Yatsı Ezanı Yaklaşıyor',
    body: 'Yatsı ezanı 10 dakika sonra… Abdestin var mı?',
  );
}
```

---

## 9. Tam Örnek: Ezan Vakitleri Ekranı

```dart
import 'package:flutter/material.dart';
import 'package:ezan_asistani/services/notification_service.dart';
import 'package:ezan_asistani/services/api_service.dart';

class EzanVakitleriScreen extends StatefulWidget {
  @override
  State<EzanVakitleriScreen> createState() => _EzanVakitleriScreenState();
}

class _EzanVakitleriScreenState extends State<EzanVakitleriScreen> {
  final NotificationService _notificationService = NotificationService();
  final ApiService _apiService = ApiService();
  
  Map<String, String>? prayerTimes;

  @override
  void initState() {
    super.initState();
    _loadPrayerTimes();
  }

  Future<void> _loadPrayerTimes() async {
    try {
      // Ezan vakitlerini yükle
      final data = await _apiService.getPrayerTimesByCoordinates(
        41.0082, // İstanbul enlem
        28.9784, // İstanbul boylam
      );

      if (data != null) {
        setState(() {
          prayerTimes = {
            'Fajr': data['timings']['Fajr'] ?? '',
            'Sunrise': data['timings']['Sunrise'] ?? '',
            'Dhuhr': data['timings']['Dhuhr'] ?? '',
            'Asr': data['timings']['Asr'] ?? '',
            'Maghrib': data['timings']['Maghrib'] ?? '',
            'Isha': data['timings']['Isha'] ?? '',
          };
        });

        // Bildirimleri planla
        await _schedulePrayerNotifications();
      }
    } catch (e) {
      print('Ezan vakitleri yükleme hatası: $e');
    }
  }

  Future<void> _schedulePrayerNotifications() async {
    if (prayerTimes == null) return;

    // Tüm eski bildirimleri iptal et
    await _notificationService.cancelAllNotifications();

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    final prayers = [
      {'id': 1, 'name': 'İmsak', 'time': prayerTimes!['Fajr']!},
      {'id': 2, 'name': 'Güneş', 'time': prayerTimes!['Sunrise']!},
      {'id': 3, 'name': 'Öğle', 'time': prayerTimes!['Dhuhr']!},
      {'id': 4, 'name': 'İkindi', 'time': prayerTimes!['Asr']!},
      {'id': 5, 'name': 'Akşam', 'time': prayerTimes!['Maghrib']!},
      {'id': 6, 'name': 'Yatsı', 'time': prayerTimes!['Isha']!},
    ];

    for (var prayer in prayers) {
      try {
        final parts = (prayer['time'] as String).split(':');
        final hour = int.parse(parts[0]);
        final minute = int.parse(parts[1]);

        var prayerTime = DateTime(
          today.year,
          today.month,
          today.day,
          hour,
          minute,
        );

        if (prayerTime.isBefore(now)) {
          prayerTime = prayerTime.add(const Duration(days: 1));
        }

        final notificationTime = prayerTime.subtract(
          const Duration(minutes: 10),
        );

        if (notificationTime.isAfter(now)) {
          // Akıllı bildirim kullan
          await _notificationService.scheduleSmartPrayerNotification(
            id: prayer['id'] as int,
            prayerName: prayer['name'] as String,
            scheduledTime: notificationTime,
            minutesBefore: 10,
          );

          print('Bildirim planlandı: ${prayer['name']}');
        }
      } catch (e) {
        print('Bildirim planlama hatası: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Ezan Vakitleri'),
      ),
      body: prayerTimes == null
          ? const Center(child: CircularProgressIndicator())
          : ListView(
              children: [
                _buildPrayerTile('İmsak', prayerTimes!['Fajr']!),
                _buildPrayerTile('Güneş', prayerTimes!['Sunrise']!),
                _buildPrayerTile('Öğle', prayerTimes!['Dhuhr']!),
                _buildPrayerTile('İkindi', prayerTimes!['Asr']!),
                _buildPrayerTile('Akşam', prayerTimes!['Maghrib']!),
                _buildPrayerTile('Yatsı', prayerTimes!['Isha']!),
              ],
            ),
    );
  }

  Widget _buildPrayerTile(String name, String time) {
    return ListTile(
      title: Text(name),
      trailing: Text(time),
    );
  }
}
```

---

## 10. Tam Örnek: Cami Yol Tarifi

```dart
import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class MosqueDirections {
  final double latitude;
  final double longitude;
  final String name;

  MosqueDirections({
    required this.latitude,
    required this.longitude,
    required this.name,
  });

  Future<void> openGoogleMaps(BuildContext context) async {
    final url =
        'https://www.google.com/maps/search/?api=1&query=$latitude,$longitude';
    await _launchUrl(context, url, 'Google Maps');
  }

  Future<void> openYandexMaps(BuildContext context) async {
    final url =
        'https://yandex.com/maps/?pt=$longitude,$latitude&z=16&l=map';
    await _launchUrl(context, url, 'Yandex Haritalar');
  }

  Future<void> openMapsMeApp(BuildContext context) async {
    final url = 'https://maps.me/?url=geo:$latitude,$longitude?z=16';
    await _launchUrl(context, url, 'Maps.me');
  }

  Future<void> _launchUrl(
    BuildContext context,
    String url,
    String appName,
  ) async {
    try {
      if (await canLaunchUrl(Uri.parse(url))) {
        await launchUrl(
          Uri.parse(url),
          mode: LaunchMode.externalApplication,
        );
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('$appName açılamadı')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Hata: $e')),
      );
    }
  }
}
```

---

## 📝 Notlar

- Tüm örnekler Flutter 3.0+ ile uyumludur
- `context` parametresi StatefulWidget içinde kullanılmalıdır
- Bildirim izinleri otomatik olarak istenir
- Harita uygulamaları cihazda yüklü olmalıdır
- URL'ler doğru format kullanmalıdır

---

**Son Güncelleme:** 2024
**Durum:** ✅ Hazır Kullanım
