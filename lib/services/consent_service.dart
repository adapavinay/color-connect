import 'package:flutter/foundation.dart';

class ConsentService {
  static final ConsentService _i = ConsentService._();
  factory ConsentService() => _i;
  ConsentService._();

  Future<void> initAndRequestIfNeeded() async {
    // Simplified for testing - UMP not available in google_mobile_ads 4.0.0
    // TODO: Implement UMP when upgrading to google_mobile_ads 5.0+
    debugPrint('ConsentService initialized (UMP not available in v4.0.0)');
  }

  Future<bool> canRequestAds() async {
    // Default to true for testing
    return true;
  }

  Future<void> showPrivacyOptions() async {
    // TODO: Implement when UMP is available
    debugPrint('Privacy options not available in current version');
  }
}
