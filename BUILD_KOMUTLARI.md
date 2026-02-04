# 🔨 Build Komutları - Ezan Asistanı

## 🔑 1. Keystore Oluşturma

```powershell
# Android klasörüne gidin
cd C:\flutter_projects\ezan_asistani\android

# Keystore oluşturun
keytool -genkey -v -keystore ezan-asistani-release-key.jks -keyalg RSA -keysize 2048 -validity 10000 -alias ezan-asistani
```

**Sorulara Cevaplar:**
```
Keystore password: [GÜÇLÜ BİR ŞİFRE - NOT EDİN]
Re-enter password: [AYNI ŞİFRE]
What is your first and last name? XNX
What is the name of your organizational unit? XNX Games
What is the name of your organization? XNX Games
What is the name of your City or Locality? Istanbul
What is the name of your State or Province? Istanbul
What is the two-letter country code? TR
Is CN=XNX, OU=XNX Games, O=XNX Games, L=Istanbul, ST=Istanbul, C=TR correct? yes
Key password: [AYNI ŞİFRE VEYA FARKLI - NOT EDİN]
```

---

## 📝 2. key.properties Oluşturma

```powershell
# android klasöründeyken
New-Item -Path "key.properties" -ItemType File
notepad key.properties
```

**Dosya İçeriği:**
```properties
storePassword=SIZIN_KEYSTORE_SIFRENIZ
keyPassword=SIZIN_KEY_SIFRENIZ
keyAlias=ezan-asistani
storeFile=ezan-asistani-release-key.jks
```

**Örnek:**
```properties
storePassword=MySecurePass123!
keyPassword=MySecurePass123!
keyAlias=ezan-asistani
storeFile=ezan-asistani-release-key.jks
```

---

## 🚀 3. AAB Build (Play Store için)

```powershell
# Proje kök dizinine dönün
cd C:\flutter_projects\ezan_asistani

# Temizlik
flutter clean

# Paketleri yükle
flutter pub get

# AAB Oluştur
flutter build appbundle --release

# Başarılı olursa dosya buradadır:
# build\app\outputs\bundle\release\app-release.aab
```

---

## 📦 4. APK Build (Test için)

### Universal APK
```powershell
flutter build apk --release

# Çıktı: build\app\outputs\flutter-apk\app-release.apk
```

### Split APK (Her CPU için ayrı - Önerilen)
```powershell
flutter build apk --release --split-per-abi

# Çıktılar:
# build\app\outputs\flutter-apk\app-armeabi-v7a-release.apk
# build\app\outputs\flutter-apk\app-arm64-v8a-release.apk
# build\app\outputs\flutter-apk\app-x86_64-release.apk
```

---

## ✅ 5. Build Öncesi Kontroller

```powershell
# Kod analizi
flutter analyze

# Build kontrolü
flutter doctor -v

# Clean build
flutter clean
flutter pub get
```

---

## 📱 6. Test Komutları

```powershell
# Debug modda çalıştır
flutter run

# Release modda çalıştır (performans testi)
flutter run --release

# Profile modda çalıştır (performans analizi)
flutter run --profile
```

---

## 🔍 7. Build Doğrulama

### AAB Boyutu Kontrol
```powershell
# Windows PowerShell
Get-ChildItem build\app\outputs\bundle\release\app-release.aab | Select-Object Name, @{Name="Size(MB)";Expression={[math]::round($_.Length/1MB,2)}}
```

### APK Boyutu Kontrol
```powershell
Get-ChildItem build\app\outputs\flutter-apk\*.apk | Select-Object Name, @{Name="Size(MB)";Expression={[math]::round($_.Length/1MB,2)}}
```

---

## 🛠️ 8. Sorun Giderme

### Build Hatası Alırsanız:

```powershell
# Tam temizlik
flutter clean
cd android
.\gradlew clean
cd ..

# Cache temizle
flutter pub cache repair

# Yeniden build
flutter pub get
flutter build appbundle --release
```

### Keystore Hatası:

```
Error: key.properties not found
```

**Çözüm:**
```powershell
# key.properties dosyasının android/ klasöründe olduğundan emin olun
cd android
dir key.properties
```

### Signing Hatası:

```
Error: Signing config 'release' not found
```

**Çözüm:**
- key.properties dosyası doğru mu?
- Keystore dosyası android/ klasöründe mi?
- Şifreler doğru mu?

---

## 📊 9. Build İstatistikleri

### Beklenen Boyutlar:

```
AAB (App Bundle):     ~15-20 MB
Universal APK:        ~18-25 MB
Split APK (ARM64):    ~10-12 MB
Split APK (ARMv7):    ~9-11 MB
Split APK (x86_64):   ~11-13 MB
```

### Build Süreleri:

```
İlk Build:    5-10 dakika
Sonraki:      2-5 dakika
```

---

## 🎯 10. Hızlı Build Script

`build.ps1` dosyası oluşturun:

```powershell
# build.ps1
Write-Host "Ezan Asistanı - AAB Build" -ForegroundColor Green

# Temizlik
Write-Host "Temizleniyor..." -ForegroundColor Yellow
flutter clean

# Paketler
Write-Host "Paketler yükleniyor..." -ForegroundColor Yellow
flutter pub get

# Build
Write-Host "AAB oluşturuluyor..." -ForegroundColor Yellow
flutter build appbundle --release

# Sonuç
if ($LASTEXITCODE -eq 0) {
    Write-Host "`nBASARILI!" -ForegroundColor Green
    Write-Host "AAB Konumu: build\app\outputs\bundle\release\app-release.aab"
    
    # Boyut göster
    $aab = Get-Item "build\app\outputs\bundle\release\app-release.aab"
    $sizeMB = [math]::round($aab.Length/1MB, 2)
    Write-Host "Boyut: $sizeMB MB" -ForegroundColor Cyan
} else {
    Write-Host "`nHATA! Build başarısız." -ForegroundColor Red
}
```

**Kullanım:**
```powershell
.\build.ps1
```

---

## 📋 11. Checklist

Build öncesi kontrol listesi:

```
✓ key.properties oluşturuldu
✓ Keystore (.jks) oluşturuldu
✓ Şifreler not edildi ve güvende saklandı
✓ flutter analyze hatası yok
✓ Package name doğru (com.xnx.ezanasistani)
✓ Version code ve name güncel
✓ AndroidManifest.xml temiz
✓ Proguard rules eklendi
✓ .gitignore güncellendi
```

---

## 🔒 12. Güvenlik

### .gitignore'a Ekleyin:

```gitignore
# Keystore files
*.jks
*.keystore
key.properties

# Build outputs
build/
```

### Yedekleme:

```powershell
# Keystore'u güvenli bir yere kopyalayın
Copy-Item android\ezan-asistani-release-key.jks -Destination "D:\Backup\ezan-keystore-backup.jks"

# key.properties'i güvenli bir yere kaydedin (şifrelerle birlikte)
```

---

## 🚀 13. Final Build Komutları

```powershell
# TÜM SÜRECİ TEK TEK:

# 1. Kök dizine gidin
cd C:\flutter_projects\ezan_asistani

# 2. Temizlik
flutter clean

# 3. Paketler
flutter pub get

# 4. Analiz (opsiyonel)
flutter analyze

# 5. AAB Build
flutter build appbundle --release

# 6. Dosya konumunu göster
explorer build\app\outputs\bundle\release
```

---

## 📞 Destek

**Hata alırsanız:**
1. Hata mesajını okuyun
2. Flutter doctor çalıştırın: `flutter doctor -v`
3. Clean build yapın
4. Gerekirse keystore'u yeniden oluşturun

**Email:** xnxgamesdev@gmail.com

---

✅ **Başarılar! Play Store'da görüşmek üzere!** 🎉
