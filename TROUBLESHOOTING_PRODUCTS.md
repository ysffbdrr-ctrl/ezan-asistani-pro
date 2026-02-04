# "Ürün Bulunamadı" Sorunu Giderme Rehberi

## Sorun
Ürünler Google Play Console'da var ama uygulama "Ürün bulunamadı" hatası veriyor.

## Çözüm Adımları

### 1. Logları Kontrol Edin

Uygulamayı çalıştırırken logları izleyin:

```bash
flutter run
```

Loglar içinde aşağıdakileri arayın:

```
🔄 PaymentService başlatılıyor...
In-App Purchase Kullanılabilir: true
📦 Ürünler yükleniyor...
=== ÜRÜN YÜKLEME BAŞLADI ===
Aranacak ürün kimliklerini: [sadaka_2tl, sadaka_5tl, ...]
Bulunan ürünler sayısı: 6
Bulunan ürünler: [sadaka_2tl, sadaka_5tl, ...]
=== ÜRÜN YÜKLEME TAMAMLANDI ===
```

### 2. Hata Mesajlarını Kontrol Edin

Loglar içinde bu hata mesajlarını arayın:

#### ❌ "In-App Purchase bu cihazda kullanılabilir değil!"
**Sebep:** Cihazda Google Play Services yüklü değil veya güncel değil

**Çözüm:**
1. Cihazda Google Play Store uygulaması yüklü mü kontrol edin
2. Google Play Services'i güncelleyin
3. Cihazı yeniden başlatın

#### ❌ "BULUNAMAYAN ÜRÜNLERİ: [sadaka_2tl, ...]"
**Sebep:** Ürün kimliği Google Play Console'daki ürünle eşleşmiyor

**Çözüm:**
1. Google Play Console'da ürün kimliklerini kontrol edin
2. Ürün kimliklerinin tam olarak eşleştiğini doğrulayın:
   - Küçük harfler: `sadaka_2tl` ✅
   - Alt çizgi: `sadaka_2tl` ✅
   - Boşluk YOK: `sadaka 2tl` ❌

#### ❌ "HATA: ..."
**Sebep:** Google Play Billing Library hatası

**Çözüm:**
1. Hata mesajını tam olarak okuyun
2. Google Play Console'da uygulamanın yayınlandığını doğrulayın
3. Ürünlerin **Active** durumda olduğunu doğrulayın

### 3. Google Play Console Kontrol Listesi

Google Play Console'da aşağıdakileri doğrulayın:

#### ✅ Ürünler Oluşturuldu Mu?
1. Google Play Console açın
2. Uygulamayı seçin
3. **Monetization** → **In-app products** gidin
4. Tüm 6 ürünü listede görebilmelisiniz:
   - sadaka_2tl
   - sadaka_5tl
   - sadaka_10tl
   - sadaka_20tl
   - sadaka_50tl
   - sadaka_100tl

#### ✅ Ürünler Active Mi?
Her ürün için:
1. Ürüne tıklayın
2. **Status** bölümünü kontrol edin
3. **Active** olmalıdır

#### ✅ Ürün Kimliği Doğru Mu?
Her ürün için:
1. Ürüne tıklayın
2. **Product ID** bölümünü kontrol edin
3. Tam olarak bu şekilde olmalıdır:
   - `sadaka_2tl` (küçük harfler, alt çizgi)

### 4. Kod Tarafı Kontrol Listesi

#### ✅ PaymentService.dart Kontrol
Dosyayı açın: `lib/services/payment_service.dart`

Ürün kimliklerini kontrol edin:
```dart
static const Map<int, String> donationProducts = {
  2: 'sadaka_2tl',      // ✅ Google Play'de var mı?
  5: 'sadaka_5tl',      // ✅ Google Play'de var mı?
  10: 'sadaka_10tl',    // ✅ Google Play'de var mı?
  20: 'sadaka_20tl',    // ✅ Google Play'de var mı?
  50: 'sadaka_50tl',    // ✅ Google Play'de var mı?
  100: 'sadaka_100tl',  // ✅ Google Play'de var mı?
};
```

#### ✅ pubspec.yaml Kontrol
Dosyayı açın: `pubspec.yaml`

In-app purchase bağımlılıkları var mı kontrol edin:
```yaml
dependencies:
  in_app_purchase: ^3.1.5
  in_app_purchase_android: ^0.3.5
```

### 5. Test Cihazı Kontrol Listesi

#### ✅ Google Play Store Yüklü Mü?
```bash
adb shell pm list packages | grep play
```

Çıktıda `com.android.vending` olmalıdır.

#### ✅ Google Play Services Güncel Mü?
1. Cihazda Settings açın
2. **Apps** → **Google Play Services** gidin
3. Güncellemeleri kontrol edin

#### ✅ Test Hesabı Eklenmiş Mi?
1. Google Play Console açın
2. **Settings** → **License Testing** gidin
3. Test cihazının email adresini ekleyin

### 6. Ürün Yükleme Süresi

**Yeni ürünler 24 saat kadar sürebilir!**

Eğer yeni ürün oluşturduysanız:
1. 24 saat bekleyin
2. Uygulamayı yeniden başlatın
3. Logları kontrol edin

### 7. Adım Adım Test

#### Adım 1: Logları Temizle
```bash
flutter clean
flutter pub get
```

#### Adım 2: Uygulamayı Yeniden Derle
```bash
flutter run
```

#### Adım 3: Logları İzle
Loglar içinde aşağıdaki mesajları arayın:
- `🔄 PaymentService başlatılıyor...`
- `In-App Purchase Kullanılabilir: true`
- `Bulunan ürünler sayısı: 6`

#### Adım 4: Bağış Bölümüne Git
1. Uygulamayı açın
2. **Sadaka & Yardım** bölümüne gidin
3. Bağış tutarına tıklayın
4. Dialog açılmalı

#### Adım 5: Ödeme Yap Butonuna Tıkla
1. **Ödeme Yap** butonuna tıklayın
2. Hata mesajı görürseniz, logları kontrol edin

## Sık Sorulan Sorular

### S: Loglar nerede?
**C:** Android Studio'da **Logcat** sekmesine bakın veya `adb logcat` kullanın.

### S: Ürün kimliğini yanlış yazarsam ne olur?
**C:** "Ürün bulunamadı" hatası görürsünüz. Loglar `BULUNAMAYAN ÜRÜNLERİ` gösterecektir.

### S: Kaç tane ürün bulunmalı?
**C:** Tam olarak 6 ürün: `sadaka_2tl`, `sadaka_5tl`, `sadaka_10tl`, `sadaka_20tl`, `sadaka_50tl`, `sadaka_100tl`

### S: Neden 24 saat bekliyorum?
**C:** Google Play Console yeni ürünleri hemen kullanılabilir hale getirmez. 24 saate kadar sürebilir.

### S: Test hesabı nedir?
**C:** Google Play Console'da lisans testine eklediğiniz Google hesabıdır. Bu hesap ile ödeme yapmadan test edebilirsiniz.

## Hızlı Kontrol Listesi

- [ ] Google Play Console'da 6 ürün var
- [ ] Tüm ürünler **Active** durumunda
- [ ] Ürün kimliklerini doğru yazdım
- [ ] pubspec.yaml'de in_app_purchase var
- [ ] Cihazda Google Play Store var
- [ ] Google Play Services güncel
- [ ] 24 saat bekledim (yeni ürünler için)
- [ ] Logları kontrol ettim
- [ ] Test hesabını ekledim
- [ ] Uygulamayı yeniden derledim

## Hala Çalışmıyorsa

1. Logları tam olarak kopyalayın
2. Email gönderin: xnxgamesdev@gmail.com
3. Aşağıdaki bilgileri ekleyin:
   - Loglar (özellikle hata mesajları)
   - Google Play Console'daki ürün listesi
   - Cihaz modeli ve Android sürümü
   - Ürün kimliklerinin ekran görüntüsü

## Kaynaklar

- [Flutter In-App Purchase Debugging](https://pub.dev/packages/in_app_purchase)
- [Google Play Billing Troubleshooting](https://developer.android.com/google/play/billing/troubleshooting)
- [Google Play Console Help](https://support.google.com/googleplay/android-developer)
