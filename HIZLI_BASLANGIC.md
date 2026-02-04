# ⚡ HIZLI BAŞLANGIÇ - Play Store'a Çıkma

## 🚀 3 Adımda Play Store

### ✅ ADIM 1: Keystore Oluştur (5 dk)

```powershell
cd C:\flutter_projects\ezan_asistani\android

keytool -genkey -v -keystore ezan-asistani-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias ezan-asistani
```

**Sorulara Cevap Ver:**
- Şifre: [GÜÇLÜ ŞİFRE - NOT ET!]
- İsim: XNX
- Organizasyon: XNX Games
- Şehir: Istanbul
- Ülke: TR

---

### ✅ ADIM 2: key.properties Oluştur (2 dk)

```powershell
# android/ klasöründe key.properties oluştur
New-Item -Path "key.properties" -ItemType File
notepad key.properties
```

**Dosya içeriği:** (Kendi şifrenizi yazın)
```properties
storePassword=SIZIN_SIFRENIZ
keyPassword=SIZIN_SIFRENIZ
keyAlias=ezan-asistani
storeFile=ezan-asistani-release-key.jks
```

**KAYDET VE KAPAT!**

---

### ✅ ADIM 3: AAB Build Et (5 dk)

```powershell
# Proje köküne dön
cd C:\flutter_projects\ezan_asistani

# Build et
flutter clean
flutter pub get
flutter build appbundle --release
```

**✅ BAŞARILI!**

AAB dosyası:
```
build\app\outputs\bundle\release\app-release.aab
```

---

## 📱 Play Console'da

### 1. Play Console'a Git
https://play.google.com/console

### 2. Yeni Uygulama Oluştur
- İsim: **Ezan Asistanı**
- Dil: **Türkçe**
- Kategori: **Lifestyle**

### 3. AAB Yükle
```
Production > Create release > Upload AAB
```

### 4. Store Listingdoldur
```
Kısa açıklama:
"Namaz vakitleri, Kur'an, kıble ve daha fazlası. İslami yaşam asistanınız."

Ekran görüntüleri: Min 2 adet (uygulamadan screenshot al)
Uygulama ikonu: 512x512 PNG
```

### 5. Gizlilik Politikası
```
Geçici olarak bu URL'yi kullan:
https://raw.githubusercontent.com/flutter/flutter/master/examples/hello_world/android/app/src/main/AndroidManifest.xml

(Sonra kendi URL'nizi ekleyin)
```

### 6. İçerik Derecelendirmesi
- Yaş: **3+**
- İçerik: Eğitici, Dini

### 7. İncelemeye Gönder
```
Review > Submit
```

---

## 📊 Hazır Bilgiler

```yaml
Package Name: com.xnx.ezanasistani
Version: 1.0.0
Version Code: 1
Min SDK: 21 (Android 5.0)
Target SDK: 34 (Android 14)

İzinler:
- Konum (Namaz vakitleri için)
- Bildirim (Hatırlatmalar için)
- İnternet (API çağrıları için)
```

---

## ⚠️ ÖNEMLİ

### ✅ MUTLAKA YAP:
1. Keystore şifrelerini KAYDET
2. .jks dosyasını YEDEKLE
3. key.properties'i GİTHUB'a YÜKLEME

### ❌ YAPMA:
1. Keystore şifresini unutma (ASLA GERİ GETİREMEZSİN!)
2. key.properties'i public yapma
3. Package name'i değiştirme (sonra değiştiremezsin)

---

## 🎯 Test Et (Opsiyonel)

```powershell
# APK oluştur ve cihazda test et
flutter build apk --release --split-per-abi
```

Dosyalar:
```
build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
```

Cihaza yükle ve test et!

---

## 📞 Sorun mu Var?

### Build Hatası:
```powershell
flutter clean
cd android
.\gradlew clean
cd ..
flutter pub get
flutter build appbundle --release
```

### Keystore Hatası:
- key.properties android/ klasöründe mi?
- Şifreler doğru mu?
- .jks dosyası orada mı?

---

## ✅ SON KONTROL

Build öncesi:
```
✓ Flutter doctor OK
✓ Package name: com.xnx.ezanasistani
✓ Keystore oluşturuldu
✓ key.properties hazır
✓ flutter analyze OK
```

Build sonrası:
```
✓ AAB dosyası var (15-20 MB)
✓ Boyut normal
✓ Hata yok
```

Play Console:
```
✓ Developer account ($25)
✓ Uygulama oluşturuldu
✓ AAB yüklendi
✓ Store listing dolu
✓ Gizlilik politikası var
✓ İncelemeye gönderildi
```

---

## 🎉 TAMAMDIR!

**Yapman gerekenler:**
1. ✅ 3 komutu çalıştır (yukarıda)
2. ✅ Play Console'u doldur
3. ✅ İncelemeye gönder
4. ✅ 7-14 gün bekle
5. ✅ Yayınlandı! 🎊

**İnceleme sürerken:**
- Crash'lere bak
- Yanıt hazırla
- Screenshot'ları güzelleştir
- Açıklamayı iyileştir

---

**BAŞARILAR! 🚀**

*Detaylı bilgi: PLAY_STORE_HAZIRLIGI.md*  
*Build komutları: BUILD_KOMUTLARI.md*
