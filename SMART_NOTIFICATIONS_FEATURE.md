# Akıllı Ezan Bildirimleri ve Yol Tarifi Özellikleri

## 📱 Akıllı Ezan Bildirimleri (AI Asistan Tarzı)

### Özellikler

Ezan vakitleri yaklaştığında kullanıcıya akıllı, etkileşimli bildirimler gönderilir:

#### Bildirim Formatı
```
🕌 Yatsı Ezanı Yaklaşıyor
Yatsı ezanı 10 dakika sonra… Abdestin var mı?
```

#### Hızlı İşlem Butonları
- **✔️ Var** - Abdestin olduğunu işaretle
- **❗ Yok** - Abdestin olmadığını işaretle  
- **🧼 Rehbere Git** - Abdest rehberine yönlendir

### Teknik Detaylar

#### Dosyalar
- `lib/services/notification_service.dart` - Ana bildirim servisi (güncellendi)
- `lib/services/smart_notification_service.dart` - Yeni akıllı bildirim servisi
- `lib/screens/ezan_vakitleri.dart` - Bildirim planlama (güncellendi)

#### Bildirim Kanalları
- **smart_prayer_channel** - Akıllı ezan bildirimleri
- **prayer_times_channel** - Genel ezan bildirimleri (backward compatibility)

#### Bildirim Özellikleri
- Yüksek öncelik (High Priority)
- Titreşim etkinleştirilmiş
- Ses etkinleştirilmiş
- Özel Android action buttons
- Bildirim gruplaması (prayer_notifications)
- Payload desteği (prayer_$prayerName)

### Kullanım

#### Akıllı Bildirim Planlama
```dart
await notificationService.scheduleSmartPrayerNotification(
  id: 1,
  prayerName: 'Yatsı',
  scheduledTime: DateTime.now().add(Duration(minutes: 10)),
  minutesBefore: 10,
);
```

#### Bildirim Yanıtını İşleme
```dart
// Bildirim servisi otomatik olarak yanıtları işler
// Callback ayarlanabilir:
smartNotificationService.onNotificationAction = (actionId, prayerName) {
  print('Action: $actionId, Prayer: $prayerName');
};
```

### Bildirim Tutma Süresi

Bildirimler, kullanıcı tarafından kapatılana kadar ekranda kalır:
- Yüksek öncelik ayarı
- Persistent notification flag
- Grup özeti desteği

### Gamification Entegrasyonu

Bildirim eylemleri otomatik olarak gamification puanlarına bağlanabilir:
- "Var" seçimi: Abdest hazırlığı puanı
- "Yok" seçimi: Abdest rehberi puanı
- "Rehbere Git" seçimi: Eğitim puanı

---

## 🗺️ Camiler için Yol Tarifi (Multi-Map Support)

### Özellikler

Yakındaki camiler listesinde her cami için üç farklı harita uygulaması seçeneği:

#### Desteklenen Harita Uygulamaları
1. **Google Maps** - En yaygın harita uygulaması
2. **Yandex Haritalar** - Yandex Maps desteği
3. **Maps.me** - Çevrimdışı harita uygulaması

### Teknik Detaylar

#### Dosyalar
- `lib/screens/nearby_mosques.dart` - Cami bulma ekranı (güncellendi)

#### URL Formatları

**Google Maps:**
```
https://www.google.com/maps/search/?api=1&query=latitude,longitude
```

**Yandex Haritalar:**
```
https://yandex.com/maps/?pt=longitude,latitude&z=16&l=map
```

**Maps.me:**
```
https://maps.me/?url=geo:latitude,longitude?z=16
```

### Kullanım Akışı

1. Kullanıcı "Haritada Aç" butonuna tıklar
2. Bottom sheet açılır ve harita seçenekleri gösterilir
3. Kullanıcı tercih ettiği harita uygulamasını seçer
4. İlgili harita uygulaması açılır ve cami konumu gösterilir

### UI Bileşenleri

#### Bottom Sheet
```
┌─────────────────────────────┐
│    Yol Tarifi Seçin        │
├─────────────────────────────┤
│ 🗺️  Google Maps             │
│     Google haritasında aç   │
├─────────────────────────────┤
│ 📍 Yandex Haritalar         │
│     Yandex haritasında aç   │
├─────────────────────────────┤
│ 🗺️  Maps.me                 │
│     Maps.me uygulamasında aç│
└─────────────────────────────┘
```

### Hata Yönetimi

- Harita uygulaması yüklü değilse: "Google Maps açılamadı" mesajı
- URL açılamıyorsa: Snackbar ile kullanıcıya bildirilir
- Tüm hatalar AppLogger'a kaydedilir

---

## 🔧 Kurulum ve Yapılandırma

### Gerekli Bağımlılıklar

Zaten `pubspec.yaml` içinde mevcut:
- `flutter_local_notifications: ^17.0.0`
- `timezone: ^0.9.2`
- `permission_handler: ^12.0.1`
- `url_launcher: ^6.2.0`

### Android Yapılandırması

#### AndroidManifest.xml
Bildirim izinleri zaten yapılandırılmış:
```xml
<uses-permission android:name="android.permission.POST_NOTIFICATIONS" />
```

#### Bildirim Sesi
`android/app/src/main/res/raw/notification.mp3` dosyası gereklidir.

### İzinler

Uygulama çalışma zamanında şu izinleri ister:
- **POST_NOTIFICATIONS** - Bildirim gönderme (Android 13+)
- **ACCESS_FINE_LOCATION** - Konum erişimi (cami bulma için)

---

## 📊 Bildirim Durumu Kontrol

### Bekleyen Bildirimleri Listele
```dart
final pending = await notificationService.getPendingNotifications();
print('Bekleyen bildirimler: ${pending.length}');
```

### Belirli Bildirimi İptal Et
```dart
await notificationService.cancelNotification(1); // İmsak bildirimi
```

### Tüm Bildirimleri İptal Et
```dart
await notificationService.cancelAllNotifications();
```

---

## 🎯 Gelecek Geliştirmeler

1. **Bildirim Özelleştirmesi**
   - Kullanıcı tarafından bildirim zamanı ayarlanabilir (5, 10, 15 dakika)
   - Seçmeli namaz vakitleri için bildirim

2. **Gelişmiş Gamification**
   - Bildirim eylemleri için özel puanlar
   - Abdest rehberi tamamlama puanları
   - Cami ziyareti puanları

3. **Bildirim Geçmişi**
   - Kullanıcının bildirim etkileşim geçmişi
   - İstatistikler ve analiz

4. **Ek Harita Uygulamaları**
   - Apple Maps (iOS)
   - Waze (navigasyon)
   - HERE Maps

5. **Çevrimdışı Destek**
   - Bildirimler cihazda saklanır
   - İnternet bağlantısı olmadan çalışır

---

## 🐛 Sorun Giderme

### Bildirimler Gelmiyorsa

1. **Bildirim izni kontrol et:**
   - Ayarlar → Uygulamalar → Ezan Asistanı Pro → Bildirimler

2. **Pil tasarrufu modu:**
   - Pil tasarrufu modunda bildirimler gecikmeli olabilir
   - Uygulamayı pil tasarrufu istisnasına ekle

3. **Cihaz saati:**
   - Cihaz saatinin doğru olduğundan emin ol
   - Saat yanlışsa bildirimler gelmeyebilir

### Harita Uygulaması Açılamıyorsa

1. **Harita uygulaması yüklü mü?**
   - Google Play Store'dan indir
   - Yandex Haritalar veya Maps.me yükle

2. **URL izni:**
   - Uygulamaya URL açma izni ver

3. **İnternet bağlantısı:**
   - Harita uygulamaları internet gerektirir
   - WiFi veya mobil veri bağlantısını kontrol et

---

## 📝 Loglar

Tüm bildirim işlemleri `AppLogger` ile kaydedilir:

```
[INFO] Akıllı bildirim planlandı: Yatsı - 2024-01-15 21:20:00
[INFO] Bildirim eylemi: abdest_var, Payload: prayer_Yatsı
[ERROR] Bildirim planlama hatası: ...
```

---

## 📄 Dosya Özeti

| Dosya | Değişiklik | Açıklama |
|-------|-----------|----------|
| `lib/services/notification_service.dart` | Güncellendi | `scheduleSmartPrayerNotification()` eklendi |
| `lib/services/smart_notification_service.dart` | Yeni | Akıllı bildirim servisi |
| `lib/screens/ezan_vakitleri.dart` | Güncellendi | Akıllı bildirim planlama kullanıyor |
| `lib/screens/nearby_mosques.dart` | Güncellendi | Multi-map yol tarifi desteği |

---

## ✅ Test Kontrol Listesi

- [ ] Bildirimler 10 dakika önceden gelmesi
- [ ] Bildirim butonlarına tıklanması
- [ ] "Var" butonunun çalışması
- [ ] "Yok" butonunun çalışması
- [ ] "Rehbere Git" butonunun çalışması
- [ ] Google Maps açılması
- [ ] Yandex Haritalar açılması
- [ ] Maps.me açılması
- [ ] Bildirim izni istenmesi (Android 13+)
- [ ] Konum izni istenmesi
- [ ] Bildirim gruplaması çalışması
- [ ] Bildirim sesi oynatılması
- [ ] Bildirim titreşimi çalışması
