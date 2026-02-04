# Ezan Asistanı Pro 🕌

Müslümanlar için modern ve kullanıcı dostu bir Flutter uygulaması.

## 📱 Özellikler

### 🕐 Ezan Vakitleri
- Konuma göre otomatik ezan vakti tespiti
- Günlük 6 vakit (İmsak, Güneş, Öğle, İkindi, Akşam, Yatsı)
- Sonraki vakit vurgulama
- Her ezan vaktinden 5 dakika önce bildirim
- Aladhan API entegrasyonu

### 🧭 Kıble Yönü
- Gerçek zamanlı pusula
- Konuma göre otomatik Kıble yönü hesaplama
- Görsel yön göstergesi
- Hassas konum bilgisi

### 📅 Takvim
- Miladi ve Hicri takvim birlikte
- Türkçe ay ve gün isimleri
- Önemli İslami günler listesi
- Tarih seçme özelliği

### 📖 Dualar
- 10 temel dua (Sabah, Akşam, Yemek, Uyku vb.)
- Arapça metin ve Türkçe anlamı
- Kendi duanızı ekleme özelliği
- Dua detay görüntüleme

### 📗 Kur'an-ı Kerim (YENİ! ✨)
- 114 Sure listesi
- Arapça metin (Osmanlı hattı)
- Türkçe meal (Diyanet İşleri)
- Meal göster/gizle özelliği
- Font boyutu ayarlama
- Quran.com API entegrasyonu

### 🕌 Namaz Rehberi (YENİ! ✨)
- 10 adımlık namaz kılma rehberi
- Detaylı açıklamalar ve görseller
- Önemli sureler (Fatiha, İhlas, Felak, Nas)
- Arapça ve Türkçe dualar
- Adım adım öğrenme

### 💰 Zekat Hesaplama
- Altın, gümüş, para hesaplama
- Güncel nisap değerleri
- Detaylı hesaplama sonuçları

### 📿 Zikirmatik
- Dijital tesbih sayacı
- Hedef belirleme
- İstatistik takibi

## 🎨 Tasarım
- Modern ve sade arayüz
- Sarı-Beyaz renk teması
- Koyu mod desteği
- Kullanıcı dostu navigasyon

## 🚀 Kurulum

### Gereksinimler
- Flutter SDK (3.0.0 veya üzeri)
- Android Studio / VS Code
- Android SDK (API 21 veya üzeri)

### Adımlar

1. Projeyi klonlayın:
```bash
git clone [repo-url]
cd ezan_asistani
```

2. Bağımlılıkları yükleyin:
```bash
flutter pub get
```

3. Uygulamayı çalıştırın:
```bash
flutter run
```

## 📦 Kullanılan Paketler

- `http` - API istekleri
- `geolocator` - Konum servisleri
- `flutter_compass` - Pusula özelliği
- `flutter_local_notifications` - Bildirimler
- `hijri` - Hicri takvim
- `hive` - Yerel veri saklama
- `provider` - State management
- `intl` - Tarih formatlama
- `shared_preferences` - Ayarlar
- `timezone` - Zaman dilimi yönetimi

## 📂 Proje Yapısı

```
lib/
├── main.dart                 # Ana uygulama
├── screens/                  # Ekranlar
│   ├── ezan_vakitleri.dart
│   ├── kible_yonu.dart
│   ├── takvim.dart
│   └── dualar.dart
├── widgets/                  # Özel widget'lar
│   ├── prayer_card.dart
│   ├── compass_widget.dart
│   └── dua_card.dart
├── services/                 # Servisler
│   ├── api_service.dart
│   ├── location_service.dart
│   └── notification_service.dart
└── theme/                    # Tema
    └── app_theme.dart
```

## 🔐 İzinler

Uygulama aşağıdaki izinleri kullanır:
- **Konum**: Ezan vakitleri ve Kıble yönü için
- **Bildirim**: Ezan vakti hatırlatmaları için
- **İnternet**: API'den veri çekmek için

## 🌟 Özellikler

- ✅ Offline çalışma desteği (Hive ile)
- ✅ Koyu mod
- ✅ Türkçe dil desteği
- ✅ Material Design 3
- ✅ Responsive tasarım
- ✅ Performans optimizasyonu

## 📝 Notlar

- Uygulama sadece Android için optimize edilmiştir
- İlk açılışta konum ve bildirim izinleri istenir
- İnternet bağlantısı ezan vakitleri için gereklidir
- Pusula özelliği için cihazda manyetik sensör olmalıdır

## 🤝 Katkıda Bulunma

1. Fork yapın
2. Feature branch oluşturun (`git checkout -b feature/amazing-feature`)
3. Commit yapın (`git commit -m 'Add some amazing feature'`)
4. Push edin (`git push origin feature/amazing-feature`)
5. Pull Request açın

## 📄 Lisans

Bu proje MIT lisansı altında lisanslanmıştır.

## 👨‍💻 Geliştirici

Ezan Asistanı Pro - Flutter ile geliştirilmiştir

---

**Not**: Bu uygulama eğitim ve kişisel kullanım amaçlıdır.
