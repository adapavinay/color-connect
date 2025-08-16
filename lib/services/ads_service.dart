import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdsService {
  static final AdsService _i = AdsService._();
  factory AdsService() => _i;
  AdsService._();

  InterstitialAd? _interstitial;
  RewardedAd? _rewarded;
  bool _removeAds = false;

  static const _kInterstitialId = kDebugMode
      ? 'ca-app-pub-3940256099942544/1033173712' // TEST
      : 'YOUR_REAL_INTERSTITIAL_ID';
  static const _kRewardedId = kDebugMode
      ? 'ca-app-pub-3940256099942544/5224354917' // TEST
      : 'YOUR_REAL_REWARDED_ID';

  Future<void> init({bool removeAds = false}) async {
    _removeAds = removeAds;
    await MobileAds.instance.initialize();
    if (kDebugMode) {
      await MobileAds.instance.updateRequestConfiguration(
        RequestConfiguration(testDeviceIds: const ['TEST_DEVICE_ID']),
      );
    }
    if (!_removeAds) {
      _loadInterstitial();
      _loadRewarded();
    }
  }

  void setRemoveAds(bool value) {
    _removeAds = value;
    if (_removeAds) {
      _interstitial?.dispose(); _interstitial = null;
    } else {
      _loadInterstitial();
    }
  }

  void _loadInterstitial() {
    if (_removeAds) return;
    InterstitialAd.load(
      adUnitId: _kInterstitialId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          _interstitial = ad..setImmersiveMode(true);
        },
        onAdFailedToLoad: (e) {
          _interstitial = null;
          if (kDebugMode) debugPrint('Interstitial failed to load: $e');
        },
      ),
    );
  }

  void _loadRewarded() {
    if (_removeAds) return;
    RewardedAd.load(
      adUnitId: _kRewardedId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewarded = ad..setImmersiveMode(true);
        },
        onAdFailedToLoad: (e) {
          _rewarded = null;
          if (kDebugMode) debugPrint('Rewarded failed to load: $e');
        },
      ),
    );
  }

  Future<void> showInterstitialIfEligible(int levelId, int everyN) async {
    if (_removeAds) return;
    if (everyN > 0 && levelId % everyN != 0) return;
    final ad = _interstitial;
    if (ad == null) { _loadInterstitial(); return; }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) { ad.dispose(); _loadInterstitial(); },
      onAdFailedToShowFullScreenContent: (ad, e) { ad.dispose(); _loadInterstitial(); },
    );
    await ad.show();
    _interstitial = null;
  }

  Future<bool> showRewardedForHint({required VoidCallback onEarned}) async {
    if (_removeAds) return false;
    final ad = _rewarded;
    if (ad == null) { _loadRewarded(); return false; }
    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdDismissedFullScreenContent: (ad) { ad.dispose(); _loadRewarded(); },
      onAdFailedToShowFullScreenContent: (ad, e) { ad.dispose(); _loadRewarded(); },
    );
    await ad.show(onUserEarnedReward: (_, __) => onEarned());
    _rewarded = null;
    return true;
  }
}
