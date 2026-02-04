# Google Play Console'da Ürün Oluşturma Rehberi

## Ürün Kimliği (Product ID) Listesi

Aşağıdaki ürün kimliklerini Google Play Console'da **tam olarak** bu şekilde oluşturmalısınız:

| Tutar | Ürün Kimliği | Fiyat | Açıklama |
|-------|--------------|-------|----------|
| 2 TL | `sadaka_2tl` | 2,00 TL | 2 TL Sadaka Bağışı |
| 5 TL | `sadaka_5tl` | 5,00 TL | 5 TL Sadaka Bağışı |
| 10 TL | `sadaka_10tl` | 10,00 TL | 10 TL Sadaka Bağışı |
| 20 TL | `sadaka_20tl` | 20,00 TL | 20 TL Sadaka Bağışı |
| 50 TL | `sadaka_50tl` | 50,00 TL | 50 TL Sadaka Bağışı |
| 100 TL | `sadaka_100tl` | 100,00 TL | 100 TL Sadaka Bağışı |

## Adım Adım Kurulum

### 1. Google Play Console'a Giriş

1. [Google Play Console](https://play.google.com/console) açın
2. Google hesabınız ile giriş yapın
3. Ezan Asistanı Pro uygulamasını seçin

### 2. Ürün Oluşturma Sayfasına Gitme

1. Sol menüden **Monetization** (Para Kazanma) seçeneğine tıklayın
2. **In-app products** (Uygulama İçi Ürünler) seçeneğine tıklayın
3. **Create an in-app product** (Ürün Oluştur) butonuna tıklayın

### 3. İlk Ürünü Oluşturma (sadaka_2tl)

#### Adım 1: Ürün Kimliği Giriş
```
Product ID: sadaka_2tl
```
⚠️ **ÖNEMLİ**: Ürün kimliğini tam olarak bu şekilde yazın (küçük harfler, alt çizgi)

#### Adım 2: Ürün Türü Seçimi
```
Product type: Non-consumable (Tüketilmeyen Ürün)
```

#### Adım 3: Ürün Detayları

**Başlık (Title):**
```
2 TL Sadaka Bağışı
```

**Açıklama (Description):**
```
Ezan Asistanı Pro uygulamasını desteklemek için 2 TL bağış yapın.
```

**Fiyat (Price):**
```
2,00 TL (Türkiye)
```

#### Adım 4: Durumu Aktif Yapma
- **Status** seçeneğini **Active** (Aktif) yapın
- **Save** (Kaydet) butonuna tıklayın

### 4. Diğer Ürünleri Oluşturma

Aynı adımları aşağıdaki ürünler için tekrarlayın:

#### sadaka_5tl
```
Product ID: sadaka_5tl
Title: 5 TL Sadaka Bağışı
Price: 5,00 TL
Description: Ezan Asistanı Pro uygulamasını desteklemek için 5 TL bağış yapın.
```

#### sadaka_10tl
```
Product ID: sadaka_10tl
Title: 10 TL Sadaka Bağışı
Price: 10,00 TL
Description: Ezan Asistanı Pro uygulamasını desteklemek için 10 TL bağış yapın.
```

#### sadaka_20tl
```
Product ID: sadaka_20tl
Title: 20 TL Sadaka Bağışı
Price: 20,00 TL
Description: Ezan Asistanı Pro uygulamasını desteklemek için 20 TL bağış yapın.
```

#### sadaka_50tl
```
Product ID: sadaka_50tl
Title: 50 TL Sadaka Bağışı
Price: 50,00 TL
Description: Ezan Asistanı Pro uygulamasını desteklemek için 50 TL bağış yapın.
```

#### sadaka_100tl
```
Product ID: sadaka_100tl
Title: 100 TL Sadaka Bağışı
Price: 100,00 TL
Description: Ezan Asistanı Pro uygulamasını desteklemek için 100 TL bağış yapın.
```

## Önemli Notlar

### ⚠️ Ürün Kimliği Kuralları

1. **Küçük harfler kullanın**: `sadaka_2tl` ✅ | `Sadaka_2TL` ❌
2. **Alt çizgi kullanın**: `sadaka_2tl` ✅ | `sadaka-2tl` ❌
3. **Boşluk kullanmayın**: `sadaka_2tl` ✅ | `sadaka 2tl` ❌
4. **Türkçe karakter kullanmayın**: `sadaka_2tl` ✅ | `sadaka_2tl` ❌

### 📋 Ürün Türü

Tüm ürünler **Non-consumable** (Tüketilmeyen) olmalıdır çünkü:
- Bağış sadece bir kez yapılır
- Tekrar satın alınmaz
- Kalıcı bir kayıt olarak tutulur

### 💰 Fiyatlandırma

- Türkiye'de fiyatlandırma yapın (TL cinsinden)
- Google Play Console otomatik olarak diğer ülkelere çevirme yapacaktır
- Fiyat değişiklikleri hemen uygulanmaz (24 saat sürebilir)

### ✅ Durumu Kontrol Etme

Ürünleri oluşturduktan sonra:

1. **In-app products** sayfasına geri dönün
2. Tüm 6 ürünü listede görebilmelisiniz
3. Her birinin durumu **Active** olmalıdır
4. Ürün kimliklerini kontrol edin (tam eşleşme)

## Ürün Kimliklerini Doğrulama

Ürünleri oluşturduktan sonra, kodda bu kimlikler kullanılacaktır:

```dart
// PaymentService.dart içinde
static const Map<int, String> donationProducts = {
  2: 'sadaka_2tl',      // ✅ Google Play'de oluşturulmuş olmalı
  5: 'sadaka_5tl',      // ✅ Google Play'de oluşturulmuş olmalı
  10: 'sadaka_10tl',    // ✅ Google Play'de oluşturulmuş olmalı
  20: 'sadaka_20tl',    // ✅ Google Play'de oluşturulmuş olmalı
  50: 'sadaka_50tl',    // ✅ Google Play'de oluşturulmuş olmalı
  100: 'sadaka_100tl',  // ✅ Google Play'de oluşturulmuş olmalı
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
**C:** Evet, **Status** seçeneğini **Inactive** yapabilirsiniz.

### S: Kaç tane ürün oluşturabilirim?
**C:** Sınırsız sayıda ürün oluşturabilirsiniz.

## Test Etme

Ürünleri oluşturduktan sonra:

1. Test cihazını Google Play Console'da ekleyin
2. Test hesabı oluşturun
3. Uygulamayı test cihazına yükleyin
4. Ödeme akışını test edin

## Sorun Giderme

### Ürünler yüklenmiyorsa:

1. Ürün kimliklerinin doğru olduğundan emin olun
2. Ürünlerin **Active** durumda olduğundan emin olun
3. 24 saat bekleyin (yeni ürünler yayınlanması zaman alabilir)
4. Uygulamayı yeniden başlatın
5. Logları kontrol edin: `adb logcat | grep "Payment"`

### "Ürün bulunamadı" hatası:

1. Ürün kimliğini tam olarak kontrol edin
2. Google Play Console'da ürünün varlığını doğrulayın
3. Ürünün **Active** olduğundan emin olun
4. Uygulamayı yeniden derleyin ve yükleyin

## Sonraki Adımlar

1. ✅ Tüm 6 ürünü Google Play Console'da oluşturun
2. ✅ Ürün kimliklerini doğrulayın
3. ✅ Test cihazında test edin
4. ✅ Uygulamayı yayınlayın

## İletişim

Sorunlarınız için:
- Email: xnxgamesdev@gmail.com
- Google Play Console yardım: https://support.google.com/googleplay/android-developer
