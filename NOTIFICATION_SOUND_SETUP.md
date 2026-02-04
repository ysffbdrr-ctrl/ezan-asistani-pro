# Bildirim Sesi Kurulumu

## 🔊 Ezan Bildirimi Sesi Ekleme

Uygulamanın bildirim sesini çalışması için `notification.mp3` dosyasını eklemeniz gerekir.

---

## 📁 Dosya Konumu

```
android/app/src/main/res/raw/notification.mp3
```

Klasör yapısı:
```
android/
└── app/
    └── src/
        └── main/
            └── res/
                └── raw/
                    ├── notification.mp3 (⚠️ Eklenecek)
                    └── README.md
```

---

## 🎵 Ses Dosyası Hazırlama

### Gereksinimler
- **Format:** MP3
- **Uzunluk:** 1-3 saniye
- **Bitrate:** 128 kbps (önerilir)
- **Boyut:** < 100 KB
- **Dosya Adı:** `notification.mp3` (tam olarak bu isim)

### Seçenek 1: Ücretsiz Ses İndir

Aşağıdaki sitelerden bildirim sesi indir:
- [Freesound.org](https://freesound.org/) - Ücretsiz ses efektleri
- [Zapsplat](https://www.zapsplat.com/) - Ücretsiz müzik ve ses
- [Pixabay](https://pixabay.com/sound-effects/) - Ücretsiz ses efektleri

**Arama terimleri:**
- "notification sound"
- "bell sound"
- "alert sound"
- "chime sound"

### Seçenek 2: FFmpeg ile Ses Oluştur

**Windows:**
```bash
# FFmpeg'i indir ve kur
# https://ffmpeg.org/download.html

# Basit beep sesi oluştur (1000 Hz, 1 saniye)
ffmpeg -f lavfi -i sine=f=1000:d=1 -q:a 9 -acodec libmp3lame notification.mp3

# Daha hoş bir ses (440 Hz, 2 saniye)
ffmpeg -f lavfi -i sine=f=440:d=2 -q:a 9 -acodec libmp3lame notification.mp3
```

**Mac/Linux:**
```bash
# Homebrew ile FFmpeg kur
brew install ffmpeg

# Basit beep sesi oluştur
ffmpeg -f lavfi -i sine=f=1000:d=1 -q:a 9 -acodec libmp3lame notification.mp3
```

### Seçenek 3: Audacity ile Ses Oluştur

1. **Audacity'yi indir:** https://www.audacityteam.org/
2. **Aç ve yeni proje oluştur**
3. **Generate → Tone seç**
   - Frequency: 1000 Hz
   - Duration: 1.0 saniye
   - Amplitude: 0.8
4. **OK'e tıkla**
5. **File → Export → Export as MP3**
6. **Dosya adı:** `notification.mp3`
7. **Kaydet**

### Seçenek 4: Online Araç Kullan

- [Online Tone Generator](https://www.szynalski.com/tone-generator/)
- [Zapsplat Downloader](https://www.zapsplat.com/)

---

## 📥 Dosya Ekleme

### Adım 1: Dosyayı Hazırla
1. `notification.mp3` dosyasını hazırla
2. Dosya adının tam olarak `notification.mp3` olduğunu kontrol et

### Adım 2: Klasöre Kopyala
```
android/app/src/main/res/raw/notification.mp3
```

Dosya yolunun tam olarak bu şekilde olması gerekir.

### Adım 3: Uygulamayı Rebuild Et
```bash
# Terminal'de proje klasörüne git
cd c:\flutter_projects\ezan_asistani_pro

# Uygulamayı temizle
flutter clean

# Bağımlılıkları yükle
flutter pub get

# Uygulamayı çalıştır
flutter run
```

---

## 🧪 Test Etme

### Bildirim Sesi Testi

1. **Uygulamayı çalıştır**
   ```bash
   flutter run
   ```

2. **Ezan Vakitleri ekranına git**
   - Ana menüden "Ezan Vakitleri" seç

3. **Bildirim Sesi Test Et**
   - Ayarlar menüsünde test butonu varsa tıkla
   - Veya bildirim zamanını 1 dakika sonraya ayarla

4. **Ses Kontrol**
   - Cihazın ses seviyesini kontrol et
   - Titreşim çalışıyor mu kontrol et

### Debug Modunda Test

```dart
// notification_service.dart içinde test kodu
if (kDebugMode) {
  await notificationService.showNotification(
    id: 999,
    title: 'Test Bildirimi',
    body: 'Bildirim sesi test ediliyor...',
  );
}
```

---

## ⚠️ Sorun Giderme

### Ses Oynatılmıyorsa

**Çözüm 1: Dosya Kontrolü**
```bash
# Dosya var mı kontrol et
ls -la android/app/src/main/res/raw/notification.mp3

# Dosya boyutunu kontrol et (< 100 KB olmalı)
du -h android/app/src/main/res/raw/notification.mp3
```

**Çözüm 2: Rebuild**
```bash
flutter clean
flutter pub get
flutter run
```

**Çözüm 3: Cihaz Kontrolleri**
- Ses seviyesini kontrol et
- Sessiz modu kapat
- Bildirim izni verilmiş mi kontrol et
- Cihazı yeniden başlat

**Çözüm 4: Dosya Adı**
- Dosya adının tam olarak `notification.mp3` olduğunu kontrol et
- Büyük/küçük harf duyarlı
- Uzantı `.mp3` olmalı

### Dosya Bulunamıyorsa

```
Error: Resource not found: notification
```

**Çözüm:**
1. Dosya yolunu kontrol et: `android/app/src/main/res/raw/notification.mp3`
2. Dosya adını kontrol et: `notification.mp3` (tam olarak bu isim)
3. Uygulamayı rebuild et: `flutter clean && flutter pub get && flutter run`

### Ses Dosyası Bozuksa

```
Error: Failed to play sound
```

**Çözüm:**
1. Ses dosyasını yeniden oluştur
2. MP3 formatında olduğunu kontrol et
3. Dosya boyutunu kontrol et (< 100 KB)
4. FFmpeg ile test et: `ffmpeg -i notification.mp3`

---

## 📊 Ses Dosyası Örnekleri

### Basit Beep (1000 Hz)
```bash
ffmpeg -f lavfi -i sine=f=1000:d=1 -q:a 9 -acodec libmp3lame notification.mp3
```

### Müzik Notu (440 Hz - La)
```bash
ffmpeg -f lavfi -i sine=f=440:d=2 -q:a 9 -acodec libmp3lame notification.mp3
```

### Çift Beep
```bash
ffmpeg -f lavfi -i "sine=f=1000:d=0.5,sine=f=1200:d=0.5" -q:a 9 -acodec libmp3lame notification.mp3
```

### Kademeli Ses
```bash
ffmpeg -f lavfi -i "sine=f=440:d=0.3|sine=f=880:d=0.3|sine=f=1320:d=0.3" -q:a 9 -acodec libmp3lame notification.mp3
```

---

## 📋 Kontrol Listesi

- [ ] `notification.mp3` dosyası hazırlandı
- [ ] Dosya MP3 formatında
- [ ] Dosya boyutu < 100 KB
- [ ] Dosya uzunluğu 1-3 saniye
- [ ] Dosya yolu: `android/app/src/main/res/raw/notification.mp3`
- [ ] Dosya adı: `notification.mp3` (tam olarak)
- [ ] `flutter clean` çalıştırıldı
- [ ] `flutter pub get` çalıştırıldı
- [ ] Uygulamayı rebuild ettim
- [ ] Bildirim sesi test edildi
- [ ] Ses çalışıyor

---

## 🎓 Kaynaklar

- [FFmpeg Dokümantasyonu](https://ffmpeg.org/documentation.html)
- [Audacity Rehberi](https://manual.audacityteam.org/)
- [Android Notification Sounds](https://developer.android.com/guide/topics/media-apps/volume-and-vibration)
- [Flutter Local Notifications](https://pub.dev/packages/flutter_local_notifications)

---

## 📞 Destek

Sorun yaşıyorsan:
1. Yukarıdaki sorun giderme bölümünü kontrol et
2. Dosya yolunu ve adını kontrol et
3. Uygulamayı rebuild et
4. Cihazı yeniden başlat

---

**Not:** Bildirim sesi kurulumu zorunlu değildir. Ses dosyası yoksa, sistem varsayılan sesini kullanır.

**Son Güncelleme:** 2024
**Durum:** ✅ Hazır Kurulum
