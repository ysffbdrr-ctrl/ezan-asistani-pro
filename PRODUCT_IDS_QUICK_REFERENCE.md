# Ürün Kimliği Hızlı Referans

## Tüm Ürün Kimliklerinin Listesi

```
sadaka_2tl
sadaka_5tl
sadaka_10tl
sadaka_20tl
sadaka_50tl
sadaka_100tl
```

## Kopyala-Yapıştır Tablosu

Google Play Console ve Apple App Store Connect'te kullanmak için:

### Google Play Console

| Ürün Kimliği | Başlık | Fiyat | Açıklama |
|---|---|---|---|
| `sadaka_2tl` | 2 TL Sadaka Bağışı | 2,00 TL | Ezan Asistanı Pro uygulamasını desteklemek için 2 TL bağış yapın. |
| `sadaka_5tl` | 5 TL Sadaka Bağışı | 5,00 TL | Ezan Asistanı Pro uygulamasını desteklemek için 5 TL bağış yapın. |
| `sadaka_10tl` | 10 TL Sadaka Bağışı | 10,00 TL | Ezan Asistanı Pro uygulamasını desteklemek için 10 TL bağış yapın. |
| `sadaka_20tl` | 20 TL Sadaka Bağışı | 20,00 TL | Ezan Asistanı Pro uygulamasını desteklemek için 20 TL bağış yapın. |
| `sadaka_50tl` | 50 TL Sadaka Bağışı | 50,00 TL | Ezan Asistanı Pro uygulamasını desteklemek için 50 TL bağış yapın. |
| `sadaka_100tl` | 100 TL Sadaka Bağışı | 100,00 TL | Ezan Asistanı Pro uygulamasını desteklemek için 100 TL bağış yapın. |

## Kodda Kullanılan Ürün Kimliği Haritası

```dart
// lib/services/payment_service.dart
static const Map<int, String> donationProducts = {
  2: 'sadaka_2tl',
  5: 'sadaka_5tl',
  10: 'sadaka_10tl',
  20: 'sadaka_20tl',
  50: 'sadaka_50tl',
  100: 'sadaka_100tl',
};
```

## Ürün Kimliği Kuralları

✅ **Doğru Format:**
- `sadaka_2tl` - küçük harfler, alt çizgi
- `sadaka_5tl` - sayılar ve harfler
- `sadaka_100tl` - tüm karakterler

❌ **Yanlış Format:**
- `Sadaka_2TL` - büyük harfler
- `sadaka-2tl` - tire kullanımı
- `sadaka 2tl` - boşluk
- `sadaka_2₺` - özel karakterler
- `sadaka_iki_tl` - Türkçe yazı

## Ürün Türü

Tüm ürünler: **Non-Consumable** (Tüketilmeyen)

## Fiyatlandırma

| Tutar | Türkiye Fiyatı |
|-------|-----------------|
| 2 TL | 2,00 TL |
| 5 TL | 5,00 TL |
| 10 TL | 10,00 TL |
| 20 TL | 20,00 TL |
| 50 TL | 50,00 TL |
| 100 TL | 100,00 TL |

## Kontrol Listesi

### Google Play Console ✅
- [x] Tüm 6 ürünü oluşturdunuz
- [x] Ürün kimliklerini doğru yazdınız
- [x] Tüm ürünleri **Active** durumuna getirdiniz
- [x] Fiyatları Türkiye'de doğru ayarladınız
- [x] Açıklamaları eklediniz

### Kod Tarafı
- [ ] `PaymentService.dart` dosyasında ürün kimliklerini kontrol ettiniz
- [ ] Ürün kimliklerinin Google Play Console'daki ürünlerle eşleştiğini doğruladınız
- [ ] Uygulamayı test ettiniz

## Detaylı Rehberler

- **Google Play Console Kurulumu**: `GOOGLE_PLAY_CONSOLE_SETUP.md`
- **In-App Purchase Kurulumu**: `IN_APP_PURCHASE_SETUP.md`
- **Bağış Akışı**: `DONATION_FLOW.md`

## Sorun Giderme

### "Ürün bulunamadı" hatası
1. Ürün kimliğini kontrol edin (tam eşleşme)
2. Ürünün platformda **Active** olduğunu doğrulayın
3. 24 saat bekleyin
4. Uygulamayı yeniden başlatın

### Ürünler yüklenmiyorsa
1. İnternet bağlantısını kontrol edin
2. Ürün kimliklerini doğrulayın
3. Logları kontrol edin
4. Test cihazını doğrulayın

## İletişim

Sorularınız için: xnxgamesdev@gmail.com
