# 🚀 Play Store Hazırlık Rehberi - Ezan Asistanı

**Tarih:** 10 Kasım 2025  
**Versiyon:** 1.0.0  
**Package Name:** com.xnx.ezanasistani

---

## ✅ Yapılan Değişiklikler

### 1. Package Name Güncellendi
```
Eski: com.example.ezan_asistani
Yeni: com.xnx.ezanasistani ✅
```

### 2. AndroidManifest.xml Temizlendi
```
✓ Tekrarlayan izinler kaldırıldı
✓ Açıklayıcı yorumlar eklendi
✓ Package tanımlandı
✓ Play Store uyumlu hale getirildi
```

### 3. Build Configuration
```
✓ versionCode: 1
✓ versionName: 1.0.0
✓ minSdk: 21 (Android 5.0+)
✓ targetSdk: 34 (Android 14)
✓ Signing config hazır
```

---

## 🔑 Adım 1: Keystore Oluşturma

### Keystore Dosyası Oluştur

Terminal'de şu komutu çalıştırın:

```bash
cd C:\flutter_projects\ezan_asistani\android

keytool -genkey -v -keystore ezan-asistani-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias ezan-asistani
```

**Sorulacak Bilgiler:**
```
1. Keystore şifresi: [GÜÇLÜ ŞİFRE GİRİN - SAKLAYINIZ]
2. Ad Soyad: XNX
3. Organizasyon: XNX Games
4. Şehir: İstanbul
5. Eyalet: İstanbul
6. Ülke Kodu: TR
7. Key şifresi: [AYNI ŞİFREYİ KULLANIN]
```

**⚠️ ÖNEMLİ:**
- Şifreleri güvenli bir yerde saklayın!
- Keystore dosyasını kaybetmeyin!
- Yedekleyin!

---

## 📝 Adım 2: key.properties Dosyası Oluşturma

`android/key.properties` dosyasını oluşturun:

```bash
cd C:\flutter_projects\ezan_asistani\android
New-Item -Path "key.properties" -ItemType File
```

Dosyanın içeriği:

```properties
storePassword=[KEYSTORE ŞİFRENİZ]
keyPassword=[KEY ŞİFRENİZ]
keyAlias=ezan-asistani
storeFile=ezan-asistani-release-key.jks
```

**Örnek:**
```properties
storePassword=MyStr0ngP@ssw0rd
keyPassword=MyStr0ngP@ssw0rd
keyAlias=ezan-asistani
storeFile=ezan-asistani-release-key.jks
```

**⚠️ ÖNEMLİ:**
- Bu dosyayı GitHub'a yüklemeyin!
- .gitignore'a ekleyin!

---

## 🗂️ Adım 3: .gitignore Güncelleme

`android/.gitignore` dosyasına ekleyin:

```gitignore
# Signing files
key.properties
*.jks
*.keystore
```

---

## 📦 Adım 4: AAB (Android App Bundle) Oluşturma

### Temizlik ve Build

```bash
# Proje kök dizinine gidin
cd C:\flutter_projects\ezan_asistani

# Flutter temizliği
flutter clean

# Paketleri yükleyin
flutter pub get

# AAB oluşturun
flutter build appbundle --release
```

### Build Çıktısı

AAB dosyası şurada olacak:
```
build/app/outputs/bundle/release/app-release.aab
```

**Beklenen Boyut:** ~15-20 MB

---

## 📊 Adım 5: APK Oluşturma (Opsiyonel Test İçin)

### Universal APK

```bash
flutter build apk --release
```

Konum: `build/app/outputs/flutter-apk/app-release.apk`

### Split APK (Her ABI için ayrı)

```bash
flutter build apk --release --split-per-abi
```

Oluşacak dosyalar:
```
app-armeabi-v7a-release.apk  (~10 MB)
app-arm64-v8a-release.apk    (~11 MB)
app-x86_64-release.apk       (~12 MB)
```

---

## 🎨 Adım 6: Play Store Asset'leri Hazırlama

### Gerekli Görseller

#### 1. Uygulama İkonu
```
✓ 512x512 PNG (transparency: HAYIR)
✓ Yüksek çözünürlük
✓ Logo.png zaten mevcut, resize edin
```

#### 2. Ekran Görüntüleri (Screenshots)

**Telefon:**
- 16:9 veya 9:16 aspect ratio
- Minimum 320px
- Maximum 3840px
- 2-8 adet screenshot
- PNG veya JPEG

**Önerilen Boyutlar:**
```
1080 x 1920 px (Portrait)
1920 x 1080 px (Landscape)
```

**Hangi Ekranlar:**
1. Ana ekran (Ezan Vakitleri)
2. Kur'an okuma ekranı
3. Kıble yönü
4. Namaz takip
5. Ayarlar ekranı
6. Uygulama tanıtım ekranı

#### 3. Feature Graphic
```
Boyut: 1024 x 500 px
Format: PNG veya JPEG
Kullanım: Play Store'da üst banner
```

#### 4. Promo Video (Opsiyonel)
```
YouTube linki
30-120 saniye
Uygulama tanıtımı
```

---

## 📱 Adım 7: Play Console Bilgileri

### Uygulama Detayları

```yaml
Uygulama Adı: "Ezan Asistanı"

Kısa Açıklama (80 karakter):
"Namaz vakitleri, Kur'an, kıble ve daha fazlası. İslami yaşam asistanınız."

Uzun Açıklama:
```

**Uzun Açıklama Örneği:**

```
🕌 Ezan Asistanı - İslami Yaşam Uygulamanız

Ezan Asistanı ile dini hayatınızı kolaylaştırın! Namaz vakitlerini takip edin, Kur'an okuyun, kıble yönünü bulun ve daha fazlası...

⏰ NAMAZ VAKİTLERİ
• Bulunduğunuz konuma göre doğru namaz vakitleri
• Ezan vakti bildirimleri
• 5 vakit için hatırlatmalar
• Manuel şehir seçimi

📖 KUR'AN-I KERİM
• Tüm sureler ve ayetler
• Türkçe meal
• Kolay okuma arayüzü
• Sure ve ayet gezinme

🧭 KİBLE YÖNÜ
• Dijital pusula
• GPS destekli kıble bulma
• Doğru yön göstergesi

✅ NAMAZ TAKİP
• Kıldığınız namazları işaretleyin
• İstatistikler görün
• Puan kazanın
• Rozet toplayın

🎓 İSLAMİ EĞİTİM
• Günlük dualar
• İslam quiz
• Bilgi kartları
• Günlük sorular

🎯 DİĞER ÖZELLİKLER
• Hicri takvim
• Namaz rehberi
• Tesbihat (Zikirmatik)
• Zekat hesaplama
• Umre & Hac rehberi
• Karanlık mod
• Yazı boyutu ayarı

📱 KOLAY KULLANIM
• Modern ve sade tasarım
• Türkçe arayüz
• Hızlı ve akıcı
• Offline çalışma

🔒 GİZLİLİK
• Verileriniz sadece cihazınızda
• Üçüncü taraflarla paylaşım yok
• Güvenli ve şeffaf

İndirin ve dini yaşantınızı kolaylaştırın!

Geliştirici: XNX
İletişim: xnxgamesdev@gmail.com
```

### Kategori
```
Kategori: Lifestyle
Alt Kategori: Religion & Spirituality
```

### İçerik Derecelendirmesi
```
Yaş: 3+ (Herkes için uygun)
İçerik: Dini içerik, Eğitici
```

### Etiketler (Keywords)
```
ezan, namaz, kuran, kıble, islam, müslüman, dua, tesbih, 
takvim, hicri, zekat, umre, hac, vakit, mevlid
```

---

## 🔐 Adım 8: İzin Açıklamaları

Play Console'da izinleri açıklamanız gerekecek:

### Konum İzni
```
Sebep: Kullanıcının bulunduğu konuma göre doğru namaz 
vakitlerini hesaplamak ve göstermek için kullanılır.

Kullanım: GPS koordinatları ile API'den namaz vakitleri çekilir.
```

### Bildirim İzni
```
Sebep: Kullanıcılara namaz vakitlerinde zamanında hatırlatma 
göndermek için kullanılır.

Kullanım: Ezan vakti geldiğinde bildirim gönderilir.
```

### İnternet İzni
```
Sebep: Namaz vakitlerini ve Kur'an verilerini almak için 
API çağrıları yapılır.

Kullanım: Aladhan API ve Quran.com API kullanılır.
```

---

## 📋 Adım 9: Gizlilik Politikası URL'i

Play Store gizlilik politikası URL'i gerektirir.

**Seçenekler:**

1. **GitHub Pages (Ücretsiz)**
```
1. GitHub repo oluşturun
2. privacy-policy.html yükleyin
3. Settings > Pages > Enable
4. URL: https://yourusername.github.io/repo/privacy-policy.html
```

2. **Basit HTML Hosting**
```
- 000webhost.com (Ücretsiz)
- Netlify (Ücretsiz)
- Vercel (Ücretsiz)
```

**İçerik:**
Uygulamadaki `lib/screens/gizlilik_politikasi.dart` içeriğini HTML'e çevirin.

---

## ✅ Adım 10: Yayınlama Öncesi Kontrol Listesi

### Kod Kontrolü
```
✓ flutter analyze (no errors)
✓ flutter test (if tests exist)
✓ Debug mode'da test edildi
✓ Release mode'da test edildi
✓ APK/AAB oluşturuldu
```

### Asset Kontrolü
```
✓ Uygulama ikonu (512x512)
✓ Ekran görüntüleri (min 2)
✓ Feature graphic (1024x500)
✓ Kısa açıklama (<80 karakter)
✓ Uzun açıklama
✓ Gizlilik politikası URL'i
```

### Manifest Kontrolü
```
✓ Package name doğru
✓ Version code: 1
✓ Version name: 1.0.0
✓ İzinler açıklanmış
✓ Uygulama adı doğru
```

### Play Console
```
✓ Developer hesabı oluşturuldu ($25 tek seferlik)
✓ Uygulama oluşturuldu
✓ Store listing dolduruldu
✓ İçerik derecelendirmesi yapıldı
✓ Gizlilik politikası eklendi
✓ Fiyatlandırma: Ücretsiz
✓ Ülkeler seçildi
```

---

## 🚀 Adım 11: Yayınlama

### Play Console'da

1. **AAB Yükleme**
```
Production > Create new release
Upload > app-release.aab
Release notes ekle
```

2. **Release Notes (Türkçe)**
```
Sürüm 1.0.0 - İlk Yayın

✨ Yeni Özellikler:
• Namaz vakitleri (GPS ve manuel konum)
• Kur'an-ı Kerim okuma
• Kıble yönü bulucu
• Namaz takip sistemi
• İslam quiz ve eğitim
• Günlük dualar
• Hicri takvim
• Tesbihat (Zikirmatik)
• Zekat hesaplama
• Umre & Hac rehberi

🎨 Özellikler:
• Modern tasarım
• Karanlık mod desteği
• Bildirim sistemi
• Puan ve rozet sistemi

📱 İlk sürüm - Geri bildirimlerinizi bekliyoruz!
```

3. **İnceleme Gönderme**
```
Review > Submit for review
```

### İnceleme Süresi
```
İlk yayın: 7-14 gün
Güncellemeler: 1-3 gün
```

---

## 📊 Adım 12: Yayın Sonrası

### İzleme
```
✓ Crash raporlarını kontrol edin
✓ Kullanıcı yorumlarını okuyun
✓ Analitikleri inceleyin
✓ Hata bildirimlerini takip edin
```

### Güncelleme Planı
```
v1.0.1: Hata düzeltmeleri (1-2 hafta sonra)
v1.1.0: Yeni özellikler (1 ay sonra)
v2.0.0: Büyük güncellemeler (3 ay sonra)
```

---

## 🛠️ Hızlı Komutlar Özeti

```bash
# Keystore oluştur
keytool -genkey -v -keystore android/ezan-asistani-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias ezan-asistani

# AAB oluştur
flutter clean
flutter pub get
flutter build appbundle --release

# APK oluştur (test için)
flutter build apk --release --split-per-abi

# Analiz et
flutter analyze

# Cihazda test et (release mode)
flutter run --release
```

---

## 📞 Destek ve İletişim

**Geliştirici:** XNX  
**Email:** xnxgamesdev@gmail.com  
**Package:** com.xnx.ezanasistani  
**Versiyon:** 1.0.0

---

## ⚠️ Önemli Notlar

1. **Keystore Güvenliği**
   - Keystore dosyasını ve şifrelerini GÜVENLİ saklayın
   - Yedekleyin (Google Drive, USB, vs.)
   - Kaybederseniz güncellemeler yapılamaz!

2. **Package Name**
   - Package name DEĞİŞTİRİLEMEZ
   - Yayından sonra değiştiremezsiniz
   - com.xnx.ezanasistani DOĞRU

3. **Version Code**
   - Her güncellemede artar (1, 2, 3, ...)
   - Asla azaltılamaz
   - Play Store takip eder

4. **Testing**
   - Önce Internal Testing kullanın
   - Sonra Closed Testing
   - En son Production

5. **Gizlilik Politikası**
   - MUTLAKA gerekli
   - URL public olmalı
   - İçerik güncel olmalı

---

## 🎉 Başarılar!

Play Store'da yayınlanmak üzeresiniz!

**Son adımlar:**
1. ✅ Keystore oluşturun
2. ✅ key.properties ekleyin
3. ✅ AAB build edin
4. ✅ Asset'leri hazırlayın
5. ✅ Play Console'u doldurun
6. ✅ İncelemeye gönderin
7. ✅ Yayınlanmayı bekleyin

**Bol şanslar! 🚀**
