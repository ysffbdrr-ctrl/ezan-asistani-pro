# Android Raw Resources

Bu dosya `android/app/src/main/res/raw/` klasörü hakkında bilgi içerir.

## 📁 Klasör Yapısı

```
android/app/src/main/res/raw/
├── notification.mp3 (Bildirim sesi)
└── (Diğer binary kaynaklar buraya eklenebilir)
```

## 🔊 Bildirim Sesi

### notification.mp3
- **Amaç:** Ezan vakti bildirimleri için ses
- **Format:** MP3
- **Uzunluk:** 1-3 saniye önerilir
- **Boyut:** < 100 KB
- **Bitrate:** 128 kbps önerilir

## ⚠️ Önemli Kurallar

Android raw klasörü için:
- ✅ Dosya adları **küçük harfler** (a-z), **rakamlar** (0-9), **alt çizgi** (_) içerebilir
- ❌ Dosya adları **büyük harfler** (A-Z) içeremez
- ❌ Dosya adları **özel karakterler** içeremez
- ❌ Markdown, text vb. **metin dosyaları** olamaz
- ✅ Sadece **binary dosyalar** (mp3, wav, ogg, vb.)

## 📝 Dosya Adlandırma Örnekleri

**Doğru:**
- `notification.mp3`
- `ezan_sound.mp3`
- `notification_1.mp3`
- `alert_sound.wav`

**Yanlış:**
- `Notification.mp3` (büyük harf)
- `notification-sound.mp3` (tire)
- `notification sound.mp3` (boşluk)
- `README.md` (metin dosyası)

## 🎵 Ses Dosyası Ekleme

1. Ses dosyasını hazırla (MP3, WAV, OGG)
2. Dosya adını küçük harflerle adlandır
3. `android/app/src/main/res/raw/` klasörüne kopyala
4. Uygulamayı rebuild et

## 🔧 Kurulum Rehberi

Detaylı kurulum talimatları için: `NOTIFICATION_SOUND_SETUP.md`

Hızlı kurulum için: `QUICK_SETUP_NOTIFICATION_SOUND.md`

---

**Not:** Bu klasör sadece binary kaynaklar için ayrılmıştır. Metin dosyaları (README, TXT, vb.) buraya konulamaz.
