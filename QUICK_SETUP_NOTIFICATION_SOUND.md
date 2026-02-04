# ⚡ Bildirim Sesi - Hızlı Kurulum

## 🎯 Özet

Ezan bildirimleri için ses dosyası eklemeniz gerekir.

---

## 📁 Dosya Konumu

```
android/app/src/main/res/raw/notification.mp3
```

---

## 🚀 3 Adımda Kurulum

### Adım 1: Ses Dosyası Hazırla

**Seçenek A: İndir (En Hızlı)**
- [Freesound.org](https://freesound.org/) → "notification" ara → İndir
- Dosyayı `notification.mp3` olarak adlandır

**Seçenek B: FFmpeg ile Oluştur**
```bash
ffmpeg -f lavfi -i sine=f=1000:d=1 -q:a 9 -acodec libmp3lame notification.mp3
```

**Seçenek C: Audacity ile Oluştur**
1. Audacity aç
2. Generate → Tone (1000 Hz, 1 saniye)
3. File → Export as MP3 → `notification.mp3`

### Adım 2: Dosyayı Kopyala

Hazırladığın `notification.mp3` dosyasını buraya kopyala:
```
android/app/src/main/res/raw/notification.mp3
```

### Adım 3: Rebuild Et

```bash
flutter clean
flutter pub get
flutter run
```

---

## ✅ Kontrol

Bildirim sesinin çalışıp çalışmadığını kontrol et:
1. Ezan Vakitleri ekranını aç
2. Bildirim zamanını 1 dakika sonraya ayarla
3. Bildirim geldiğinde ses çalışıyor mu?

---

## 📋 Gereksinimler

| Özellik | Değer |
|---------|-------|
| Format | MP3 |
| Uzunluk | 1-3 saniye |
| Boyut | < 100 KB |
| Bitrate | 128 kbps |
| Dosya Adı | `notification.mp3` |

---

## 🆘 Sorun Giderme

| Sorun | Çözüm |
|-------|-------|
| Ses çalmıyor | Cihaz ses seviyesini kontrol et |
| Dosya bulunamıyor | Dosya yolunu kontrol et: `android/app/src/main/res/raw/notification.mp3` |
| Hata mesajı | `flutter clean && flutter pub get && flutter run` çalıştır |

---

## 📚 Detaylı Rehber

Daha fazla bilgi için: `NOTIFICATION_SOUND_SETUP.md`

---

**Durum:** ✅ Hazır Kurulum
