# Apple App Store Connect'te Ürün Oluşturma Rehberi

## Ürün Kimliği (Product ID) Listesi

Aşağıdaki ürün kimliklerini Apple App Store Connect'te **tam olarak** bu şekilde oluşturmalısınız:

| Tutar | Ürün Kimliği | Fiyat | Açıklama |
|-------|--------------|-------|----------|
| 2 TL | `sadaka_2tl` | 2,00 TL | 2 TL Sadaka Bağışı |
| 5 TL | `sadaka_5tl` | 5,00 TL | 5 TL Sadaka Bağışı |
| 10 TL | `sadaka_10tl` | 10,00 TL | 10 TL Sadaka Bağışı |
| 20 TL | `sadaka_20tl` | 20,00 TL | 20 TL Sadaka Bağışı |
| 50 TL | `sadaka_50tl` | 50,00 TL | 50 TL Sadaka Bağışı |
| 100 TL | `sadaka_100tl` | 100,00 TL | 100 TL Sadaka Bağışı |

## Adım Adım Kurulum

### 1. App Store Connect'e Giriş

1. [App Store Connect](https://appstoreconnect.apple.com) açın
2. Apple ID ile giriş yapın
3. Ezan Asistanı Pro uygulamasını seçin

### 2. In-App Purchase Ürünü Oluşturma Sayfasına Gitme

1. Sol menüden **Pricing and Availability** seçeneğine tıklayın
2. **In-App Purchases** seçeneğine tıklayın
3. **+** (Artı) butonuna tıklayın
4. **Non-Consumable** (Tüketilmeyen Ürün) seçeneğini seçin

### 3. İlk Ürünü Oluşturma (sadaka_2tl)

#### Adım 1: Ürün Kimliği Giriş
```
Product ID: sadaka_2tl
```
⚠️ **ÖNEMLİ**: Ürün kimliğini tam olarak bu şekilde yazın (küçük harfler, alt çizgi)

#### Adım 2: Referans Adı
```
Reference Name: 2 TL Sadaka Bağışı
```

#### Adım 3: Fiyatlandırma

**Pricing Tier seçin:**
- Türkiye'de 2 TL karşılık gelen tier'ı seçin
- Genellikle **Tier 1** veya **Tier 2** olur

**Fiyat Kontrolü:**
- Seçtiğiniz tier'ın Türkiye fiyatını doğrulayın
- 2,00 TL olmalıdır

#### Adım 4: Lokalizasyon

**Türkçe Başlık:**
```
2 TL Sadaka Bağışı
```

**Türkçe Açıklama:**
```
Ezan Asistanı Pro uygulamasını desteklemek için 2 TL bağış yapın.
```

#### Adım 5: Durumu Aktif Yapma
- **Status** seçeneğini **Ready to Submit** yapın
- **Save** (Kaydet) butonuna tıklayın

### 4. Diğer Ürünleri Oluşturma

Aynı adımları aşağıdaki ürünler için tekrarlayın:

#### sadaka_5tl
```
Product ID: sadaka_5tl
Reference Name: 5 TL Sadaka Bağışı
Turkish Title: 5 TL Sadaka Bağışı
Turkish Description: Ezan Asistanı Pro uygulamasını desteklemek için 5 TL bağış yapın.
Price: 5,00 TL
```

#### sadaka_10tl
```
Product ID: sadaka_10tl
Reference Name: 10 TL Sadaka Bağışı
Turkish Title: 10 TL Sadaka Bağışı
Turkish Description: Ezan Asistanı Pro uygulamasını desteklemek için 10 TL bağış yapın.
Price: 10,00 TL
```

#### sadaka_20tl
```
Product ID: sadaka_20tl
Reference Name: 20 TL Sadaka Bağışı
Turkish Title: 20 TL Sadaka Bağışı
Turkish Description: Ezan Asistanı Pro uygulamasını desteklemek için 20 TL bağış yapın.
Price: 20,00 TL
```

#### sadaka_50tl
```
Product ID: sadaka_50tl
Reference Name: 50 TL Sadaka Bağışı
Turkish Title: 50 TL Sadaka Bağışı
Turkish Description: Ezan Asistanı Pro uygulamasını desteklemek için 50 TL bağış yapın.
Price: 50,00 TL
```

#### sadaka_100tl
```
Product ID: sadaka_100tl
Reference Name: 100 TL Sadaka Bağışı
Turkish Title: 100 TL Sadaka Bağışı
Turkish Description: Ezan Asistanı Pro uygulamasını desteklemek için 100 TL bağış yapın.
Price: 100,00 TL
```

## Önemli Notlar

### ⚠️ Ürün Kimliği Kuralları

1. **Küçük harfler kullanın**: `sadaka_2tl` ✅ | `Sadaka_2TL` ❌
2. **Alt çizgi kullanın**: `sadaka_2tl` ✅ | `sadaka-2tl` ❌
3. **Boşluk kullanmayın**: `sadaka_2tl` ✅ | `sadaka 2tl` ❌
4. **Türkçe karakter kullanmayın**: `sadaka_2tl` ✅ | `sadaka_2tl` ❌

### 📋 Ürün Türü

Tüm ürünler **Non-Consumable** (Tüketilmeyen) olmalıdır çünkü:
- Bağış sadece bir kez yapılır
- Tekrar satın alınmaz
- Kalıcı bir kayıt olarak tutulur

### 💰 Fiyatlandırma

- Türkiye'de fiyatlandırma yapın (TL cinsinden)
- App Store Connect otomatik olarak diğer ülkelere çevirme yapacaktır
- Fiyat değişiklikleri hemen uygulanmaz (24 saat sürebilir)

### ✅ Durumu Kontrol Etme

Ürünleri oluşturduktan sonra:

1. **In-App Purchases** sayfasına geri dönün
2. Tüm 6 ürünü listede görebilmelisiniz
3. Her birinin durumu **Ready to Submit** olmalıdır
4. Ürün kimliklerini kontrol edin (tam eşleşme)

## Fiyat Tier'ları

Apple'ın fiyat tier'ları:

| Tier | Türkiye Fiyatı | Açıklama |
|------|-----------------|----------|
| Tier 1 | ~2 TL | En düşük fiyat |
| Tier 2 | ~5 TL | Düşük fiyat |
| Tier 3 | ~10 TL | Orta fiyat |
| Tier 4 | ~20 TL | Yüksek fiyat |
| Tier 5 | ~50 TL | Çok yüksek fiyat |
| Tier 6 | ~100 TL | En yüksek fiyat |

## Ürün Kimliklerini Doğrulama

Ürünleri oluşturduktan sonra, kodda bu kimlikler kullanılacaktır:

```dart
// PaymentService.dart içinde
static const Map<int, String> donationProducts = {
  2: 'sadaka_2tl',      // ✅ App Store'de oluşturulmuş olmalı
  5: 'sadaka_5tl',      // ✅ App Store'de oluşturulmuş olmalı
  10: 'sadaka_10tl',    // ✅ App Store'de oluşturulmuş olmalı
  20: 'sadaka_20tl',    // ✅ App Store'de oluşturulmuş olmalı
  50: 'sadaka_50tl',    // ✅ App Store'de oluşturulmuş olmalı
  100: 'sadaka_100tl',  // ✅ App Store'de oluşturulmuş olmalı
};
```

## Sık Sorulan Sorular

### S: Ürün kimliğini yanlış yazarsam ne olur?
**C:** Uygulama ürünü bulamaz ve "Ürün bulunamadı" hatası gösterir.

### S: Ürün kimliğini değiştirebilir miyim?
**C:** Hayır, ürün oluşturduktan sonra kimliği değiştirilemez. Yeni ürün oluşturmalısınız.

### S: Fiyatı değiştirebilir miyim?
**C:** Evet, fiyatı istediğiniz zaman değiştirebilirsiniz.

### S: Ürünü devre dışı bırakabilir miyim?
**C:** Evet, ürünü silebilir veya devre dışı bırakabilirsiniz.

### S: Kaç tane ürün oluşturabilirim?
**C:** Sınırsız sayıda ürün oluşturabilirsiniz.

## Test Etme

Ürünleri oluşturduktan sonra:

1. Test cihazını App Store Connect'te ekleyin
2. Test hesabı oluşturun
3. Uygulamayı test cihazına yükleyin
4. Ödeme akışını test edin

## Sorun Giderme

### Ürünler yüklenmiyorsa:

1. Ürün kimliklerinin doğru olduğundan emin olun
2. Ürünlerin **Ready to Submit** durumda olduğundan emin olun
3. 24 saat bekleyin (yeni ürünler yayınlanması zaman alabilir)
4. Uygulamayı yeniden başlatın
5. Xcode'da logları kontrol edin

### "Ürün bulunamadı" hatası:

1. Ürün kimliğini tam olarak kontrol edin
2. App Store Connect'te ürünün varlığını doğrulayın
3. Ürünün **Ready to Submit** olduğundan emin olun
4. Uygulamayı yeniden derleyin ve yükleyin

## Sonraki Adımlar

1. ✅ Tüm 6 ürünü App Store Connect'te oluşturun
2. ✅ Ürün kimliklerini doğrulayın
3. ✅ Test cihazında test edin
4. ✅ Uygulamayı yayınlayın

## İletişim

Sorunlarınız için:
- Email: xnxgamesdev@gmail.com
- App Store Connect yardım: https://support.apple.com/app-store-connect
