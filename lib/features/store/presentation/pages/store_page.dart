import 'package:flutter/material.dart';
import 'package:color_connect/core/theme/app_theme.dart';
import 'package:color_connect/services/iap_service.dart';
import 'package:color_connect/services/ads_service.dart';
import 'package:color_connect/services/consent_service.dart';
import 'package:color_connect/services/hints_manager.dart';
import 'package:color_connect/core/config/feature_flags.dart';
import 'package:color_connect/features/store/presentation/pages/star_store_page.dart';
// import 'package:purchases_flutter/purchases_flutter.dart'; // Temporarily disabled

// Temporary StoreProduct class for testing
class StoreProduct {
  final String identifier;
  final String title;
  final String description;
  final double price;
  final String priceString;
  final String currencyCode;

  StoreProduct({
    required this.identifier,
    required this.title,
    required this.description,
    required this.price,
    required this.priceString,
    required this.currencyCode,
  });
}

class StorePage extends StatefulWidget {
  const StorePage({super.key});

  @override
  State<StorePage> createState() => _StorePageState();
}

class _StorePageState extends State<StorePage> {
  bool _isLoading = false;
  List<StoreProduct> _availableProducts = [];
  bool _hasRemoveAds = false;
  int _currentHints = 0;

  @override
  void initState() {
    super.initState();
    _loadStoreData();
  }

  Future<void> _loadStoreData() async {
    setState(() => _isLoading = true);
    
    try {
      // Load available products (temporarily disabled)
      _availableProducts = [
        StoreProduct(
          identifier: ProductIds.removeAds,
          title: 'Remove Ads',
          description: 'Remove all ads from the game',
          price: 2.99,
          priceString: '\$2.99',
          currencyCode: 'USD',
        ),
        StoreProduct(
          identifier: ProductIds.hints5,
          title: '5 Hints',
          description: 'Get 5 hints',
          price: 0.99,
          priceString: '\$0.99',
          currencyCode: 'USD',
        ),
      ];
      
      // Check current remove ads status (temporarily disabled)
      _hasRemoveAds = false;
      
      // Load current hints
      _currentHints = HintsManager().hintCount;
      
      setState(() {});
    } catch (e) {
      debugPrint('Error loading store data: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _purchaseRemoveAds() async {
    setState(() => _isLoading = true);
    
    try {
      // Temporarily disabled IAP
      _showErrorDialog('IAP temporarily disabled for testing');
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _purchaseHints(String productId, int hintCount) async {
    setState(() => _isLoading = true);
    
    try {
      // Temporarily disabled IAP - just add hints for testing
      await HintsManager().init();
      await HintsManager().add(hintCount);
      setState(() {
        _currentHints = HintsManager().hintCount;
      });
      _showSuccessDialog('$hintCount hints added to your account! (Testing mode)');
    } catch (e) {
      _showErrorDialog('Error: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _restorePurchases() async {
    setState(() => _isLoading = true);
    
    try {
      // Temporarily disabled IAP
      _showErrorDialog('IAP temporarily disabled for testing');
    } catch (e) {
      _showErrorDialog('Error restoring purchases: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _manageConsent() async {
    try {
      // Temporarily disabled
      _showErrorDialog('Consent management temporarily disabled for testing');
    } catch (e) {
      _showErrorDialog('Error managing consent: $e');
    }
  }

  void _showSuccessDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Success'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Error'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  Widget _buildRemoveAdsSection() {
    if (_hasRemoveAds) {
      return Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 32),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Remove Ads',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Text(
                      'Ads are disabled',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      );
    }

    final removeAdsProduct = _availableProducts
        .firstWhere((p) => p.identifier == ProductIds.removeAds, 
                   orElse: () => _createDummyProduct(ProductIds.removeAds, 'Remove Ads', 2.99));

    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.block, color: Colors.red, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Remove Ads',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        removeAdsProduct.priceString,
                        style: const TextStyle(
                          fontSize: 16,
                          color: Colors.green,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _purchaseRemoveAds,
                child: _isLoading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2),
                      )
                    : const Text('Purchase'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHintsSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.lightbulb, color: Colors.amber, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Hint Packs',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        'Current balance: $_currentHints hints',
                        style: const TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildHintPackButton(ProductIds.hints5, 5),
            const SizedBox(height: 8),
            _buildHintPackButton(ProductIds.hints10, 10),
            const SizedBox(height: 8),
                                     _buildHintPackButton(ProductIds.hints20, 20),
                       ],
                     ),
                   ),
                 );
               }

  Widget _buildStarStoreSection() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.star, color: Colors.amber, size: 32),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Star Store',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text(
                        'Earn stars through gameplay and rewards',
                        style: TextStyle(color: Colors.grey),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  debugPrint('🚀 Navigating to StarStorePage');
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const StarStorePage(),
                    ),
                  );
                },
                icon: const Icon(Icons.star),
                label: const Text('Go to Star Store'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHintPackButton(String productId, int hintCount) {
    final product = _availableProducts
        .firstWhere((p) => p.identifier == productId, 
                   orElse: () => _createDummyProduct(productId, '$hintCount Hints', 0.99));

    return SizedBox(
      width: double.infinity,
      child: OutlinedButton(
        onPressed: _isLoading ? null : () => _purchaseHints(productId, hintCount),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text('$hintCount Hints'),
            Text(
              product.priceString,
              style: const TextStyle(
                color: Colors.green,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  StoreProduct _createDummyProduct(String identifier, String title, double price) {
    // This is a fallback for when products aren't loaded yet
    return StoreProduct(
      identifier: identifier,
      title: title,
      description: '',
      price: price,
      priceString: '\$${price.toStringAsFixed(2)}',
      currencyCode: 'USD',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Store'),
        backgroundColor: Theme.of(context).colorScheme.surface,
        foregroundColor: Theme.of(context).colorScheme.onSurface,
      ),
      body: _isLoading && _availableProducts.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildRemoveAdsSection(),
                  const SizedBox(height: 16),
                                           _buildHintsSection(),
                         const SizedBox(height: 16),
                         _buildStarStoreSection(),
                         const SizedBox(height: 16),
                         Card(
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Account',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 16),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _isLoading ? null : _restorePurchases,
                              child: const Text('Restore Purchases'),
                            ),
                          ),
                          const SizedBox(height: 8),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: _manageConsent,
                              child: const Text('Manage Consent'),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}
