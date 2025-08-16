import 'package:flutter/foundation.dart';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:color_connect/services/ads_service.dart';

class IapService {
  static final IapService _instance = IapService._internal();
  factory IapService() => _instance;
  IapService._internal();

  bool _initialized = false;
  bool _removeAds = false;
  
  // RevenueCat API keys - replace with your real keys before release
  static const String _androidKey = 'your_android_key_here';
  static const String _iosKey = 'your_ios_key_here';
  
  // Product IDs - must match your App Store / Play Console products
  static const String _removeAdsProductId = 'remove_ads';
  static const String _hints5ProductId = 'hints_5';
  static const String _hints10ProductId = 'hints_10';
  static const String _hints20ProductId = 'hints_20';
  
  Future<void> init() async {
    if (_initialized) return;
    
    try {
      // Initialize RevenueCat
      await Purchases.setLogLevel(LogLevel.debug);
      
      // Set API key based on platform
      if (defaultTargetPlatform == TargetPlatform.android) {
        await Purchases.configure(PurchasesConfiguration(_androidKey));
      } else if (defaultTargetPlatform == TargetPlatform.iOS) {
        await Purchases.configure(PurchasesConfiguration(_iosKey));
      }
      
      // Add customer info update listener for live updates
      Purchases.addCustomerInfoUpdateListener(_onCustomerInfoUpdated);
      
      // Check if user has remove ads entitlement
      await _checkRemoveAdsEntitlement();
      
      _initialized = true;
      debugPrint('IapService initialized successfully');
    } catch (e) {
      debugPrint('Failed to initialize IapService: $e');
    }
  }
  
  Future<void> _checkRemoveAdsEntitlement() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      _removeAds = customerInfo.entitlements.active.containsKey('remove_ads');
      debugPrint('Remove ads entitlement: $_removeAds');
    } catch (e) {
      debugPrint('Error checking entitlements: $e');
    }
  }
  
  bool get removeAds => _removeAds;
  
  Future<bool> purchaseRemoveAds() async {
    if (!_initialized) return false;
    
    try {
      final offerings = await Purchases.getOfferings();
      final removeAdsPackage = offerings.current?.availablePackages
          .firstWhere((package) => package.storeProduct.identifier == _removeAdsProductId);
      
      if (removeAdsPackage == null) {
        debugPrint('Remove ads package not found');
        return false;
      }
      
      final customerInfo = await Purchases.purchasePackage(removeAdsPackage);
      _removeAds = customerInfo.entitlements.active.containsKey('remove_ads');
      
      if (_removeAds) {
        _logPurchaseEvent('iap_purchase_succeeded', _removeAdsProductId);
        debugPrint('Successfully purchased remove ads');
        return true;
      }
      
      _logPurchaseEvent('iap_purchase_failed', _removeAdsProductId, success: false);
      return false;
    } catch (e) {
      debugPrint('Error purchasing remove ads: $e');
      return false;
    }
  }
  
  Future<bool> purchaseHintsPack(String productId) async {
    if (!_initialized) return false;
    
    try {
      final offerings = await Purchases.getOfferings();
      final hintsPackage = offerings.current?.availablePackages
          .firstWhere((package) => package.storeProduct.identifier == productId);
      
      if (hintsPackage == null) {
        debugPrint('Hints package not found: $productId');
        return false;
      }
      
      final customerInfo = await Purchases.purchasePackage(hintsPackage);
      // For consumable products, you might want to track the purchase
      // and grant hints to the user
      _logPurchaseEvent('iap_purchase_succeeded', productId);
      debugPrint('Successfully purchased hints: $productId');
      return true;
    } catch (e) {
      debugPrint('Error purchasing hints: $e');
      return false;
    }
  }
  
  Future<bool> restore() async {
    if (!_initialized) return false;
    
    try {
      final customerInfo = await Purchases.restorePurchases();
      _removeAds = customerInfo.entitlements.active.containsKey('remove_ads');
      debugPrint('Purchases restored, remove ads: $_removeAds');
      return true;
    } catch (e) {
      debugPrint('Error restoring purchases: $e');
      return false;
    }
  }
  
  Future<List<StoreProduct>> getAvailableProducts() async {
    if (!_initialized) return [];
    
    try {
      final offerings = await Purchases.getOfferings();
      final packages = offerings.current?.availablePackages ?? [];
      
      return packages.map((package) => package.storeProduct).toList();
    } catch (e) {
      debugPrint('Error getting available products: $e');
      return [];
    }
  }
  
  Future<bool> isProductAvailable(String productId) async {
    final products = await getAvailableProducts();
    return products.any((product) => product.identifier == productId);
  }
  
  /// Customer info update listener for live entitlement updates
  void _onCustomerInfoUpdated(CustomerInfo customerInfo) {
    final hasRemoveAds = customerInfo.entitlements.active.containsKey('remove_ads');
    
    // Update local state
    _removeAds = hasRemoveAds;
    
    // Notify AdsService to disable ads immediately
    AdsService().setRemoveAds(hasRemoveAds);
    
    // Log analytics event
    _logAnalyticsEvent('entitlement_updated', {
      'remove_ads': hasRemoveAds,
      'entitlements': customerInfo.entitlements.active.keys.toList(),
    });
    
    debugPrint('Customer info updated. Remove ads: $_removeAds');
  }
  
  /// Log analytics events (replace with your analytics service)
  void _logAnalyticsEvent(String eventName, Map<String, dynamic> parameters) {
    // TODO: Replace with your analytics service (Firebase, Amplitude, etc.)
    debugPrint('Analytics: $eventName - $parameters');
  }
  
  /// Log purchase events for analytics
  void _logPurchaseEvent(String eventName, String productId, {bool success = true}) {
    _logAnalyticsEvent(eventName, {
      'product_id': productId,
      'success': success,
      'platform': defaultTargetPlatform.toString(),
    });
  }
}
