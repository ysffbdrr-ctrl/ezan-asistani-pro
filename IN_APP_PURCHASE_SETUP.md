# Gerçek Satın Alma (In-App Purchase) Kurulumu

Bu dokümanda, Ezan Asistanı Pro uygulamasında sadaka/bağış bölümüne gerçek satın alma özelliğinin nasıl kurulacağı açıklanmaktadır.

## Genel Bakış

Uygulama artık aşağıdaki özellikleri desteklemektedir:

1. **Gerçek Ödeme**: Google Play Store üzerinden gerçek satın almalar
2. **Yerel Kayıt**: Ödeme yapılmadan sadece kayıt olarak bağış tutma
3. **Satın Alma Geçmişi**: Tüm satın almaların kaydı
4. **Otomatik Puan**: Her bağış için gamification puanları

## Bağış Tutarları

Aşağıdaki tutarlar için ürün tanımlanmıştır:
- 2 TL
- 5 TL
- 10 TL
- 20 TL
- 50 TL
- 100 TL

## Android Kurulumu (Google Play Store)

### 1. Google Play Console'da Ürün Oluşturma

1. [Google Play Console](https://play.google.com/console) açın
2. Uygulamanızı seçin
3. **Monetization** → **In-app products** bölümüne gidin
4. Aşağıdaki ürünleri oluşturun:

| Ürün ID | Fiyat | Açıklama |
|---------|-------|----------|
| `sadaka_2tl` | 2 TL | 2 TL Sadaka |
| `sadaka_5tl` | 5 TL | 5 TL Sadaka |
| `sadaka_10tl` | 10 TL | 10 TL Sadaka |
| `sadaka_20tl` | 20 TL | 20 TL Sadaka |
| `sadaka_50tl` | 50 TL | 50 TL Sadaka |
| `sadaka_100tl` | 100 TL | 100 TL Sadaka |

### 2. Android Manifest Güncellemesi

`android/app/src/main/AndroidManifest.xml` dosyasına aşağıdaki izni ekleyin:

```xml
<uses-permission android:name="com.android.vending.BILLING" />
```

### 3. Build.gradle Güncellemesi

`android/app/build.gradle` dosyasında `minSdkVersion` en az 21 olmalıdır:

```gradle
android {
    compileSdkVersion 34
    
    defaultConfig {
        minSdkVersion 21
        targetSdkVersion 34
        // ...
    }
}
```

## Kod Yapısı

### PaymentService (`lib/services/payment_service.dart`)

Tüm satın alma işlemlerini yönetir:

```dart
// Hizmeti başlat
await PaymentService.initialize();

// Satın alma yap
await PaymentService.purchaseDonation(10); // 10 TL

// Satın alma akışını dinle
PaymentService.getPurchaseStream().listen((purchases) {
  // Satın almalar işlenir
});
```

### SadakaYardim Screen (`lib/screens/sadaka_yardim.dart`)

Bağış UI'ını yönetir:

- Hızlı bağış butonları (2, 5, 10, 20, 50, 100 TL)
- Özel tutar girişi
- Gerçek ödeme seçeneği (eğer mevcut ise)
- Yerel kayıt seçeneği
- Satın alma geçmişi

## Özellikler

### 1. Çift Seçenek

Kullanıcılar bağış yaparken iki seçeneği vardır:
- **Ödeme Yap**: Gerçek satın alma (eğer mevcut ise)
- **Kayıt Et**: Yerel olarak kayıt (ödeme yapılmadan)

### 2. Otomatik Puan

Her bağış (gerçek veya yerel) için 5 puan kazanılır.

### 3. Satın Alma Geçmişi

Tüm satın almalar `SharedPreferences` içinde kaydedilir:
- `total_purchased`: Toplam satın alınan tutar
- `purchase_count`: Satın alma sayısı
- `recent_purchases`: Son satın almalar (son 20)

### 4. Hata Yönetimi

Satın alma başarısız olursa:
- Kullanıcıya hata mesajı gösterilir
- Ürün bulunamadı hatası durumunda uygun mesaj gösterilir
- Ağ hataları yakalanır

## Test Etme

### Android Test Cihazı

1. Google Play Console'da test cihazlarını ekleyin
2. Test hesaplarını oluşturun
3. Uygulamayı test cihazına yükleyin
4. Test hesabı ile giriş yapın

### iOS Test Cihazı

1. App Store Connect'te test hesapları oluşturun
2. Xcode'da test cihazını seçin
3. Uygulamayı çalıştırın
4. Test hesabı ile giriş yapın

## Sorun Giderme

### Ürünler Yüklenmiyorsa

1. Ürün ID'lerinin doğru olduğundan emin olun
2. Ürünlerin aktif olduğundan emin olun
3. İnternet bağlantısını kontrol edin
4. Logları kontrol edin: `adb logcat | grep "Payment"`

### Satın Alma Başarısız Oluyorsa

1. Ödeme yöntemi eklenmiş mi kontrol edin
2. Ülke/bölge ayarlarını kontrol edin
3. Test hesabı doğru mu kontrol edin
4. Uygulama imzası doğru mu kontrol edin

## Güvenlik Notları

1. **Ürün ID'leri**: Ürün ID'leri hem kodda hem de Play Store/App Store'da eşleşmelidir
2. **Satın Alma Doğrulaması**: Gerçek uygulamada sunucu tarafında satın almaları doğrulayın
3. **Gizli Anahtar**: Google Play'in gizli anahtarını güvenli bir yerde saklayın

## Kaynaklar

- [Flutter In-App Purchase Plugin](https://pub.dev/packages/in_app_purchase)
- [Google Play Billing Library](https://developer.android.com/google/play/billing)
- [App Store In-App Purchase](https://developer.apple.com/in-app-purchase/)
