# 🎨 Logo Kurulum Rehberi

## 📁 Dosya Yapısı

```
ezan_asistani/
├── assets/
│   └── logo.png          ← Logonuzu buraya koyun
├── pubspec.yaml          ← Yapılandırma (hazır)
└── android/
    └── app/
        └── src/
            └── main/
                └── res/
                    ├── mipmap-hdpi/
                    ├── mipmap-mdpi/
                    ├── mipmap-xhdpi/
                    ├── mipmap-xxhdpi/
                    └── mipmap-xxxhdpi/
```

---

## 🎯 Adım Adım Kurulum

### 1️⃣ Logo Dosyasını Hazırlayın

#### Önerilen Özellikler:
- **Boyut**: 1024x1024 px (minimum 512x512)
- **Format**: PNG
- **Arka Plan**: Şeffaf veya tek renk
- **Oran**: 1:1 (kare)
- **Kalite**: Yüksek çözünürlük

#### Logo Tasarım Önerileri:
- 🕌 İslami motifler (cami, hilal, yıldız)
- 🎨 Sarı-beyaz tema (uygulamanın renkleri)
- ⚡ Basit ve tanınabilir
- 📱 Küçük boyutlarda okunabilir

---

### 2️⃣ Logo Dosyasını Koyun

```bash
# Logo dosyanızı bu klasöre kopyalayın:
ezan_asistani/assets/logo.png
```

**Not**: Dosya adı tam olarak `logo.png` olmalıdır (küçük harf).

---

### 3️⃣ Paketi Yükleyin

```bash
cd c:\flutter_projects\ezan_asistani
flutter pub get
```

---

### 4️⃣ İkon Oluşturun

```bash
# Tüm boyutlarda ikonları otomatik oluşturur
flutter pub run flutter_launcher_icons
```

**Çıktı**:
```
Creating icons...
✓ Creating launcher icons for Android
  • mipmap-mdpi (48x48)
  • mipmap-hdpi (72x72)
  • mipmap-xhdpi (96x96)
  • mipmap-xxhdpi (144x144)
  • mipmap-xxxhdpi (192x192)
  • Adaptive icon (foreground + background)

✓ Successfully generated launcher icons
```

---

### 5️⃣ Uygulamayı Çalıştırın

```bash
# Temizle ve yeniden derle
flutter clean
flutter pub get
flutter run
```

---

## 🎨 Adaptive Icon (Android)

### Nedir?
Android 8.0+ cihazlarda şekillendirilebilir ikonlar.

### Yapılandırma:
```yaml
adaptive_icon_background: "#FFC107"  # Sarı arka plan
adaptive_icon_foreground: "assets/logo.png"  # Logo
```

### Görünümler:
- **Daire**: 🔵 Logo daire içinde
- **Kare**: 🟨 Logo kare içinde  
- **Squircle**: ◽ Logo yuvarlatılmış kare içinde

---

## 📐 Logo Boyutları (Otomatik Oluşturulur)

| Klasör | Boyut | Kullanım |
|--------|-------|----------|
| mipmap-mdpi | 48x48 | Düşük yoğunluk |
| mipmap-hdpi | 72x72 | Yüksek yoğunluk |
| mipmap-xhdpi | 96x96 | Ekstra yüksek |
| mipmap-xxhdpi | 144x144 | Ekstra ekstra yüksek |
| mipmap-xxxhdpi | 192x192 | Ekstra ekstra ekstra yüksek |

**Not**: Bu dosyalar otomatik oluşturulur, manuel düzenlemeyin!

---

## 🎨 Renk Şeması

### Uygulama Temaları:
```
Ana Renk (Primary): #FFC107 (Sarı)
Koyu Renk (Dark): #FFA000 (Koyu Sarı)
Açık Renk (Light): #FFECB3 (Açık Sarı)
```

### Logo için Öneriler:
1. **Şeffaf arka plan** + Sarı detaylar
2. **Beyaz arka plan** + Sarı/Siyah detaylar
3. **Gradient**: Sarıdan turuncu'ya

---

## 🔧 Yapılandırma Detayları

### pubspec.yaml:
```yaml
flutter_launcher_icons:
  android: true              # Android için aktif
  ios: false                 # iOS için kapalı
  image_path: "assets/logo.png"  # Logo yolu
  min_sdk_android: 21        # Minimum Android SDK
  adaptive_icon_background: "#FFC107"  # Arka plan rengi
  adaptive_icon_foreground: "assets/logo.png"  # Ön plan görseli
```

---

## 🎯 Örnek Logolar

### 1. Cami Silueti
```
┌──────────────┐
│              │
│   🕌 ┇ ┇     │  (Basit cami)
│   ━━━━━━━    │
│              │
└──────────────┘
```

### 2. Hilal ve Yıldız
```
┌──────────────┐
│              │
│   ☪️  ⭐     │  (İslam sembolleri)
│              │
│              │
└──────────────┘
```

### 3. Ezan Vakti
```
┌──────────────┐
│   🕌         │
│   ⏰ 12:30   │  (Cami + Saat)
│              │
│              │
└──────────────┘
```

---

## 🐛 Sorun Giderme

### Logo Görünmüyor:
```bash
# 1. Dosya yolunu kontrol et
ls assets/logo.png

# 2. Yeniden oluştur
flutter pub run flutter_launcher_icons

# 3. Temizle ve derle
flutter clean
flutter pub get
flutter run
```

### Hata: "Image not found"
```bash
# Dosya adını kontrol et (tam olarak logo.png olmalı)
# Klasörü kontrol et (assets/ klasöründe olmalı)
```

### Hata: "Invalid image"
```bash
# PNG formatında olmalı
# Bozuk dosya olabilir, yeniden kaydet
```

---

## 📱 Test Etme

### Android Cihazda:
1. Uygulamayı kur
2. Ana ekrana dön
3. Uygulama ikonunu kontrol et
4. Farklı launcher'larda dene (Samsung, Xiaomi vb.)

### Emulator'de:
```bash
flutter run
# Ana ekrana git
# İkonu kontrol et
```

---

## 🎨 Logo Tasarım Araçları

### Ücretsiz:
- **Canva**: canva.com
- **Figma**: figma.com  
- **GIMP**: gimp.org
- **Inkscape**: inkscape.org

### Online:
- **Photopea**: photopea.com (Photoshop benzeri)
- **Remove.bg**: remove.bg (arka plan kaldırma)
- **TinyPNG**: tinypng.com (boyut küçültme)

---

## 📋 Checklist

Logonuzu eklemeden önce kontrol edin:

- [ ] Logo 512x512 px veya daha büyük
- [ ] PNG formatında
- [ ] Dosya adı `logo.png` (küçük harf)
- [ ] `assets/` klasöründe
- [ ] Kare oran (1:1)
- [ ] Yüksek kalite
- [ ] Temaya uygun renkler
- [ ] Küçük boyutlarda okunabilir

---

## 🚀 Hızlı Başlangıç

```bash
# 1. Logo dosyasını kopyala
copy your_logo.png assets\logo.png

# 2. Paketi yükle
flutter pub get

# 3. İkon oluştur
flutter pub run flutter_launcher_icons

# 4. Çalıştır
flutter clean
flutter run

# ✅ Hazır!
```

---

## 💡 İpuçları

### Logo Hazırlarken:
1. **Basit tut**: Fazla detay küçük ekranlarda kaybolur
2. **Kontrast kullan**: Arka plan ile logo ayrışmalı
3. **Test et**: Farklı renk temalarda dene
4. **Safe zone**: Merkezde %80 alan kullan (kenarlar kesilebilir)

### Renkler:
- Sarı (#FFC107) - Ana tema
- Siyah/Beyaz - Kontrast için
- Gradient - Modern görünüm

---

## 📊 Boyut Önerileri

```
📱 Ekran Görünümü:
┌─────────────┐
│ 192x192 px  │  ← XXXHDPI (en büyük)
└─────────────┘
┌───────────┐
│ 144x144   │  ← XXHDPI
└───────────┘
┌─────────┐
│ 96x96   │  ← XHDPI
└─────────┘
┌───────┐
│ 72x72 │  ← HDPI
└───────┘
┌─────┐
│48x48│  ← MDPI
└─────┘
```

---

## 🎉 Sonuç

Logo kurulumu tamamlandıktan sonra:

1. ✅ Ana ekranda uygulama ikonu görünür
2. ✅ Bildirim çekmecesinde ikon görünür
3. ✅ Ayarlarda uygulama ikonu görünür
4. ✅ Adaptive icon desteklenir (Android 8.0+)
5. ✅ Tüm çözünürlüklerde net görünür

---

## 📞 Yardım

Sorun mu yaşıyorsunuz?

1. Bu dosyayı baştan okuyun
2. Sorun Giderme bölümünü kontrol edin
3. Komutları sırayla çalıştırın
4. Log'ları kontrol edin

---

**🎨 Logoyu ekleyin ve uygulamanızı kişiselleştirin!**
