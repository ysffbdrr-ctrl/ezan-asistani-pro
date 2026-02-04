# Firebase Setup - Ezan Asistanı Pro

## 📋 Firebase Kurulumu

Bu dokümanda, Google Sign-In ve Cloud Firestore entegrasyonunu ayarlamak için gereken adımlar açıklanmaktadır.

---

## 🔧 Adım 1: Firebase Projesi Oluştur

1. [Firebase Console](https://console.firebase.google.com/) adresine git
2. **Yeni Proje Oluştur** butonuna tıkla
3. Proje adını gir: `ezan-asistani-pro`
4. Google Analytics'i etkinleştir (opsiyonel)
5. **Proje Oluştur** butonuna tıkla

---

## 🔧 Adım 2: Android Yapılandırması

### 2.1 SHA-1 Fingerprint Al

```bash
# Windows
cd android
./gradlew signingReport

# macOS/Linux
cd android
./gradlew signingReport
```

Çıktıda `SHA1` değerini kopyala.

### 2.2 Firebase Console'da Android Uygulaması Ekle

1. Firebase Console'da proje seç
2. **Proje Ayarları** → **Uygulamalar** sekmesine git
3. **Android Uygulaması Ekle** butonuna tıkla
4. Paket adını gir: `com.example.ezan_asistani`
5. SHA-1 fingerprint'i yapıştır
6. **Uygulamayı Kaydet** butonuna tıkla
7. `google-services.json` dosyasını indir

### 2.3 google-services.json Dosyasını Yerleştir

```
android/app/google-services.json
```

### 2.4 Android Build Dosyalarını Güncelle

**android/build.gradle:**
```gradle
buildscript {
  dependencies {
    classpath 'com.google.gms:google-services:4.3.15'
  }
}
```

**android/app/build.gradle:**
```gradle
apply plugin: 'com.google.gms.google-services'
```

---

## 🔧 Adım 3: iOS Yapılandırması (Opsiyonel)

### 3.1 Firebase Console'da iOS Uygulaması Ekle

1. Firebase Console'da **iOS Uygulaması Ekle** butonuna tıkla
2. Bundle ID'yi gir: `com.example.ezanAsistani`
3. `GoogleService-Info.plist` dosyasını indir

### 3.2 Xcode'da Yapılandır

1. Xcode'u aç: `open ios/Runner.xcworkspace`
2. `GoogleService-Info.plist` dosyasını Runner'a sürükle
3. **Copy items if needed** seçeneğini işaretle

---

## 🔧 Adım 4: Google Sign-In Yapılandırması

### 4.1 Google Cloud Console'da OAuth 2.0 Kimliği Oluştur

1. [Google Cloud Console](https://console.cloud.google.com/) adresine git
2. Firebase projesini seç
3. **APIs & Services** → **Credentials** sekmesine git
4. **Create Credentials** → **OAuth 2.0 Client ID** seçeneğini tıkla
5. **Android** seçeneğini seç
6. Paket adını ve SHA-1 fingerprint'i gir
7. **Create** butonuna tıkla

### 4.2 Firebase Console'da Google Sign-In'i Etkinleştir

1. Firebase Console'da proje seç
2. **Authentication** → **Sign-in method** sekmesine git
3. **Google** seçeneğini etkinleştir
4. Proje adını ve destek e-postasını gir
5. **Save** butonuna tıkla

---

## 🔧 Adım 5: Cloud Firestore Yapılandırması

### 5.1 Firestore Veritabanı Oluştur

1. Firebase Console'da proje seç
2. **Firestore Database** sekmesine git
3. **Create Database** butonuna tıkla
4. Bölgeyi seç: `europe-west1` (Avrupa)
5. Güvenlik kurallarını seç: **Test Mode** (geliştirme için)
6. **Create** butonuna tıkla

### 5.2 Firestore Güvenlik Kuralları

**Geliştirme (Test Mode):**
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /{document=**} {
      allow read, write: if request.auth != null;
    }
  }
}
```

**Üretim (Production):**
```
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /users/{userId} {
      allow read, write: if request.auth.uid == userId;
      
      match /data/{document=**} {
        allow read, write: if request.auth.uid == userId;
      }
    }
  }
}
```

---

## 📱 Test Etme

### 1. Uygulamayı Çalıştır

```bash
flutter run
```

### 2. Giriş Ekranında "Google ile Giriş Yap" Butonuna Tıkla

### 3. Google Hesabını Seç

### 4. Verilerin Firestore'a Kaydedildiğini Kontrol Et

Firebase Console → Firestore Database → `users` koleksiyonunu kontrol et.

---

## 🔐 Güvenlik Notları

1. **API Keys**: `google-services.json` dosyasını asla GitHub'a yükleme
2. **Firestore Rules**: Üretim ortamında güvenlik kurallarını ayarla
3. **Authentication**: Sadece Google Sign-In kullan
4. **Data Privacy**: Kullanıcı verilerini şifrele

---

## 🐛 Sorun Giderme

### "google-services.json not found" Hatası

```bash
# Dosyanın doğru konumda olduğunu kontrol et
ls android/app/google-services.json
```

### "Sign in failed" Hatası

1. SHA-1 fingerprint'in doğru olduğunu kontrol et
2. Google Cloud Console'da OAuth 2.0 kimliğini kontrol et
3. Firebase Console'da Google Sign-In'in etkinleştirildiğini kontrol et

### Firestore Bağlantı Hatası

1. İnternet bağlantısını kontrol et
2. Firestore güvenlik kurallarını kontrol et
3. Firebase Console'da proje seçimini kontrol et

---

## 📚 Kaynaklar

- [Firebase Flutter Dokumentasyonu](https://firebase.flutter.dev/)
- [Google Sign-In for Flutter](https://pub.dev/packages/google_sign_in)
- [Cloud Firestore for Flutter](https://pub.dev/packages/cloud_firestore)
- [Firebase Authentication](https://firebase.google.com/docs/auth)

---

**Kurulum tamamlandı!** 🎉
