# Akıllı Ezan Bildirimleri - Hızlı Başlangıç

## 🎯 Özet

Uygulamada iki yeni özellik eklendi:

### 1️⃣ Akıllı Ezan Bildirimleri (AI Asistan Tarzı)

**Bildirim Örneği:**
```
🕌 Yatsı Ezanı Yaklaşıyor
Yatsı ezanı 10 dakika sonra… Abdestin var mı?

[✔️ Var]  [❗ Yok]  [🧼 Rehbere Git]
```

**Özellikler:**
- Ezan vakti 10 dakika öncesinde bildirim
- 3 hızlı işlem butonu
- Bildirim ekranda kalır (persistent)
- Titreşim ve ses
- Gamification puanları

### 2️⃣ Camiler için Yol Tarifi (Multi-Map)

**Harita Seçenekleri:**
- 🗺️ Google Maps
- 📍 Yandex Haritalar  
- 🗺️ Maps.me

**Kullanım:**
1. "Eve Yakın Camiler" ekranında cami seç
2. "Haritada Aç" butonuna tıkla
3. Tercih ettiğin harita uygulamasını seç
4. Yol tarifi al

---

## 📁 Değiştirilen Dosyalar

### Yeni Dosyalar
- ✨ `lib/services/smart_notification_service.dart` - Akıllı bildirim servisi

### Güncellenen Dosyalar
- 📝 `lib/services/notification_service.dart` - Smart notification metodu eklendi
- 📝 `lib/screens/ezan_vakitleri.dart` - Akıllı bildirim planlama
- 📝 `lib/screens/nearby_mosques.dart` - Multi-map yol tarifi

---

## 🚀 Kullanım Örnekleri

### Akıllı Bildirim Gönder
```dart
final notificationService = NotificationService();

await notificationService.scheduleSmartPrayerNotification(
  id: 6,
  prayerName: 'Yatsı',
  scheduledTime: DateTime.now().add(Duration(minutes: 10)),
  minutesBefore: 10,
);
```

### Bildirim Yanıtını Dinle
```dart
notificationService.onNotificationAction = (actionId, prayerName) {
  if (actionId == 'abdest_var') {
    print('$prayerName için abdest var');
  } else if (actionId == 'abdest_yok') {
    print('$prayerName için abdest yok');
  } else if (actionId == 'abdest_rehberi') {
    print('Abdest rehberine git');
  }
};
```

### Harita Seçeneklerini Göster
```dart
_showMapOptions(mosque); // nearby_mosques.dart içinde
```

---

## ⚙️ Yapılandırma

### Android Bildirim Kanalları

Otomatik olarak oluşturulur:
- **smart_prayer_channel** - Akıllı ezan bildirimleri
- **prayer_times_channel** - Genel bildirimler

### İzinler

Otomatik olarak istenir:
- `android.permission.POST_NOTIFICATIONS` (Android 13+)
- `android.permission.ACCESS_FINE_LOCATION` (cami bulma)

---

## 🧪 Test Etme

### Bildirim Testi
```dart
// Anlık bildirim gönder
await notificationService.showNotification(
  id: 99,
  title: 'Test Bildirimi',
  body: 'Bu bir test bildirimidir',
);
```

### Harita Testi
1. "Eve Yakın Camiler" ekranına git
2. Herhangi bir cami seç
3. "Haritada Aç" butonuna tıkla
4. Harita seçeneğini seç
5. İlgili uygulama açılmalı

---

## 🔍 Loglar

Tüm işlemler loglanır:
```
[INFO] Akıllı bildirim planlandı: Yatsı - 2024-01-15 21:20:00
[INFO] Bildirim eylemi: abdest_var, Payload: prayer_Yatsı
[ERROR] Bildirim planlama hatası: ...
```

Logları görmek için:
```bash
flutter logs
```

---

## ❓ Sık Sorulan Sorular

**S: Bildirimler neden gelmiyor?**
- A: Bildirim izni kontrol et (Ayarlar → Bildirimler)
- A: Cihaz saatini kontrol et
- A: Pil tasarrufu modunu devre dışı bırak

**S: Harita uygulaması açılmıyor?**
- A: Harita uygulamasını Google Play Store'dan indir
- A: İnternet bağlantısını kontrol et
- A: Uygulamaya URL açma izni ver

**S: Bildirim butonları çalışmıyor?**
- A: Android 8.0+ gereklidir
- A: Bildirim izni verilmiş olmalı
- A: Uygulamayı yeniden başlat

**S: Gamification puanları neden eklenmiyyor?**
- A: Bildirim eylemi işlendikten sonra eklenecek
- A: Profil ekranında puanları kontrol et

---

## 📞 Destek

Sorun yaşıyorsan:
1. Logları kontrol et (`flutter logs`)
2. Cihazı yeniden başlat
3. Uygulamayı yeniden yükle
4. Cihaz saatini kontrol et

---

## 📊 Versiyon Bilgisi

- **Özellik Sürümü:** 1.0
- **Ekleme Tarihi:** 2024
- **Uyumluluk:** Android 8.0+, iOS 11.0+
- **Durum:** ✅ Aktif ve Test Edilmiş

---

## 🎓 Öğrenme Kaynakları

- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)
- [URL Launcher](https://pub.dev/packages/url_launcher)
- [Timezone](https://pub.dev/packages/timezone)
- [Google Maps API](https://developers.google.com/maps)
- [Yandex Maps API](https://tech.yandex.com/maps/)
- [Maps.me](https://maps.me/)

---

**Son Güncelleme:** 2024
**Durum:** ✅ Hazır Kullanım
