import 'package:in_app_purchase/in_app_purchase.dart';
import 'package:shared_preferences/shared_preferences.dart';

class PaymentService {
  static final InAppPurchase _inAppPurchase = InAppPurchase.instance;
  static const String _donationProductPrefix = 'sadaka_';

  static const String removeAdsProductId = 'reklamsiz';
  
  // Ürün ID'leri (Google Play Store ve App Store'da tanımlanmalı)
  static const Map<int, String> donationProducts = {
    2: '${_donationProductPrefix}2tl',
    5: '${_donationProductPrefix}5tl',
    10: '${_donationProductPrefix}10tl',
    20: '${_donationProductPrefix}20tl',
    50: '${_donationProductPrefix}50tl',
    100: '${_donationProductPrefix}100tl',
  };

  static bool _isAvailable = false;
  static List<ProductDetails> _products = [];

  /// İn-app satın alma hizmetini başlat
  static Future<bool> initialize() async {
    try {
      print('🔄 PaymentService başlatılıyor...');
      _isAvailable = await _inAppPurchase.isAvailable();
      print('In-App Purchase Kullanılabilir: $_isAvailable');
      
      if (_isAvailable) {
        print('📦 Ürünler yükleniyor...');
        await _loadProducts();
      } else {
        print('❌ In-App Purchase bu cihazda kullanılabilir değil!');
      }
      return _isAvailable;
    } catch (e) {
      print('❌ Payment Service initialization error: $e');
      return false;
    }
  }

  static ProductDetails? getRemoveAdsProduct() {
    try {
      return _products.firstWhere((p) => p.id == removeAdsProductId);
    } catch (e) {
      return null;
    }
  }

  /// Ürünleri yükle
  static Future<void> _loadProducts() async {
    try {
      print('=== ÜRÜN YÜKLEME BAŞLADI ===');
      final productIds = <String>{
        ...donationProducts.values,
        removeAdsProductId,
      };
      print('Aranacak ürün kimliklerini: ${productIds.toList()}');
      
      final ProductDetailsResponse response =
          await _inAppPurchase.queryProductDetails(productIds);
      
      print('Bulunan ürünler sayısı: ${response.productDetails.length}');
      print('Bulunan ürünler: ${response.productDetails.map((p) => p.id).toList()}');
      
      if (response.notFoundIDs.isNotEmpty) {
        print('❌ BULUNAMAYAN ÜRÜNLERİ: ${response.notFoundIDs}');
        print('⚠️ Bu ürünleri Google Play Console\'da kontrol edin!');
      }
      
      if (response.error != null) {
        print('❌ HATA: ${response.error}');
      }
      
      _products = response.productDetails;
      print('=== ÜRÜN YÜKLEME TAMAMLANDI ===');
    } catch (e) {
      print('❌ Error loading products: $e');
    }
  }

  /// Belirli bir tutar için ürün detaylarını al
  static ProductDetails? getProductForAmount(int amount) {
    final productId = donationProducts[amount];
    if (productId == null) return null;
    
    try {
      return _products.firstWhere((p) => p.id == productId);
    } catch (e) {
      return null;
    }
  }

  /// Satın alma işlemini başlat
  static Future<bool> purchaseDonation(int amount) async {
    try {
      final product = getProductForAmount(amount);
      if (product == null) {
        print('Ürün bulunamadı: $amount TL');
        return false;
      }

      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      return true;
    } catch (e) {
      print('Purchase error: $e');
      return false;
    }
  }

  static Future<bool> purchaseRemoveAds() async {
    try {
      final product = getRemoveAdsProduct();
      if (product == null) {
        print('Ürün bulunamadı: $removeAdsProductId');
        return false;
      }

      final PurchaseParam purchaseParam = PurchaseParam(productDetails: product);
      await _inAppPurchase.buyNonConsumable(purchaseParam: purchaseParam);
      return true;
    } catch (e) {
      print('Purchase error: $e');
      return false;
    }
  }

  /// Satın alma akışını dinle
  static Stream<List<PurchaseDetails>> getPurchaseStream() {
    return _inAppPurchase.purchaseStream;
  }

  /// Bekleyen satın almaları tamamla
  static Future<void> completePendingPurchases() async {
    try {
      // Purchases are completed by calling completePurchase(purchase)
    } catch (e) {
      print('Error completing purchases: $e');
    }
  }

  static Future<void> restorePurchases() async {
    try {
      await _inAppPurchase.restorePurchases();
    } catch (e) {
      print('Restore purchases error: $e');
    }
  }

  /// Satın alma geçmişini kaydet
  static Future<void> savePurchaseHistory(int amount) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Toplam satın alınan tutarı güncelle
      double totalPurchased = prefs.getDouble('total_purchased') ?? 0;
      totalPurchased += amount;
      await prefs.setDouble('total_purchased', totalPurchased);
      
      // Satın alma sayısını güncelle
      int purchaseCount = prefs.getInt('purchase_count') ?? 0;
      purchaseCount++;
      await prefs.setInt('purchase_count', purchaseCount);
      
      // Son satın almaları kaydet
      String now = DateTime.now().toString().substring(0, 16);
      List<String> purchases = prefs.getStringList('recent_purchases') ?? [];
      purchases.insert(0, '$amount|$now|paid');
      
      if (purchases.length > 20) {
        purchases = purchases.sublist(0, 20);
      }
      await prefs.setStringList('recent_purchases', purchases);
    } catch (e) {
      print('Error saving purchase history: $e');
    }
  }

  /// Toplam satın alınan tutarı al
  static Future<double> getTotalPurchased() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('total_purchased') ?? 0;
  }

  /// Satın alma sayısını al
  static Future<int> getPurchaseCount() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt('purchase_count') ?? 0;
  }

  /// Hizmetin kullanılabilir olup olmadığını kontrol et
  static bool get isAvailable => _isAvailable;

  /// Ürünleri al
  static List<ProductDetails> get products => _products;
}
