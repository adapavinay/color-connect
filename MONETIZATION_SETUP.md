# Monetization Integration Setup Guide

This guide explains how to complete the setup for the monetization features that have been integrated into your Color Connect game.

## What's Been Added

### 1. AdMob Integration
- **Interstitial ads** shown after every 5 level completions
- **Rewarded ads** for hint system (fully integrated with hint button)
- Test ad unit IDs configured for development
- **Consent-aware ad requests** (GDPR/EEA compliant)
- **Test device configuration** for development

### 2. RevenueCat IAP Integration
- **Remove Ads** purchase (non-consumable)
- **Hint Packs** (5, 10, 20 hints - consumable)
- **Live entitlement updates** with immediate ad disabling
- **Restore purchases** functionality
- **Analytics event logging** for all purchases

### 3. Consent & Privacy Management
- **UMP consent forms** for GDPR/EEA compliance
- **App Tracking Transparency** (ATT) for iOS
- **Consent management** from settings
- **Non-personalized ads** for users who don't consent

### 4. Hint System
- **HintsManager** with persistent storage
- **Automatic rewarded ad integration** when out of hints
- **Hint balance tracking** and statistics
- **Seamless hint consumption** and earning

### 5. Complete Store UI
- **Remove Ads purchase** with live status updates
- **Hint pack purchases** with localized pricing
- **Restore purchases** button
- **Consent management** access
- **Real-time product availability** from RevenueCat

### 6. Feature Flags & Configuration
- `MonetizationFlags` for controlling ad behavior
- `ProductIds` for managing IAP products
- **Configurable ad intervals** and hint rewards

## Complete Setup Steps

### 1. Install Dependencies
Run this command to install the required packages:
```bash
flutter pub get
```

### 2. AdMob Configuration

#### Replace Test IDs with Real IDs
In `lib/services/ads_service.dart`, replace these test IDs:
```dart
// Replace with your real ad unit IDs
static const String _interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
static const String _rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
```

#### Android Configuration
The AdMob App ID has been added to `android/app/src/main/AndroidManifest.xml`:
```xml
<meta-data
    android:name="com.google.android.gms.ads.APPLICATION_ID"
    android:value="ca-app-pub-3940256099942544~3347511713" />
```
**Replace with your real AdMob App ID before release.**

### 3. RevenueCat Configuration

#### Replace API Keys
In `lib/services/iap_service.dart`, replace these placeholder keys:
```dart
// Replace with your real RevenueCat API keys
static const String _androidKey = 'your_android_key_here';
static const String _iosKey = 'your_ios_key_here';
```

#### Configure Products in RevenueCat Dashboard
1. Create an entitlement called `remove_ads`
2. Create these products:
   - `remove_ads` (non-consumable) → map to `remove_ads` entitlement
   - `hints_5` (consumable)
   - `hints_10` (consumable) 
   - `hints_20` (consumable)

#### Map to App Store / Play Console
- Create corresponding products in your app store accounts
- Link them to the RevenueCat products

### 4. iOS Configuration (if adding iOS support later)

#### Add to Info.plist:
```xml
<key>GADApplicationIdentifier</key>
<string>ca-app-pub-3940256099942544~3347511713</string>

<key>SKAdNetworkItems</key>
<array>
    <dict>
        <key>SKAdNetworkIdentifier</key>
        <string>cstr6suwn9.skadnetwork</string>
    </dict>
    <!-- Add more SKAdNetworkItems as per AdMob documentation -->
</array>
```

### 5. Testing

#### AdMob Testing
- Keep test IDs for development builds
- Test on real devices (ads don't work in simulators)
- Verify interstitial shows every 5 levels

#### IAP Testing
- **Android**: Use license testers in Play Console
- **iOS**: Use sandbox accounts in App Store Connect
- Test purchase flow and restore functionality

### 6. Optional: Wire Hint Button to Rewarded Ads

To automatically show rewarded ads when players run out of hints, find your hint button implementation and add:

```dart
// When hint button is pressed and no hints available
await AdsService().showRewardedForHint(
  onEarned: () {
    // Grant +1 hint
    setState(() {
      _hints++;
    });
  },
);
```

### 7. Store UI Integration

The monetization services are ready, but you'll need to create UI for:
- Remove Ads purchase button
- Hint pack purchase buttons  
- Restore purchases button

Example store page structure:
```dart
// In your store page
ElevatedButton(
  onPressed: () async {
    final success = await IapService().purchaseRemoveAds();
    if (success) {
      // Update UI, disable ads
    }
  },
  child: Text('Remove Ads - \$2.99'),
),

ElevatedButton(
  onPressed: () async {
    final success = await IapService().purchaseHintsPack(ProductIds.hints5);
    if (success) {
      // Grant 5 hints
    }
  },
  child: Text('5 Hints - \$0.99'),
),
```

## Current Status

✅ **Completed:**
- **AdMob service** with interstitial + rewarded ads + consent awareness
- **RevenueCat IAP service** with live entitlement updates + analytics
- **ConsentService** for UMP + ATT compliance
- **HintsManager** with persistence + rewarded ad integration
- **Complete Store UI** with Remove Ads, hint packs, and restore
- **Interstitial ads** wired to show after level completion
- **Hint button** fully integrated with rewarded ads
- **Feature flags** and configuration
- **Dependencies** added to pubspec.yaml
- **Android manifest** updated with AdMob app ID
- **iOS Info.plist** with ATT and SKAdNetwork configuration

🔄 **Ready for:**
- **Real ad unit IDs** and app IDs (replace test IDs)
- **Real RevenueCat API keys** (replace placeholder keys)
- **Store navigation** (add navigation to StorePage from your app)
- **Hint logic implementation** (add actual hint functionality)
- **Analytics service** (replace debug logging with your analytics)

## Troubleshooting

### Ads Not Showing
- Check device is real (not simulator)
- Verify ad unit IDs are correct
- Check AdMob console for any policy violations

### IAP Not Working
- Verify RevenueCat API keys
- Check product IDs match exactly
- Ensure products are active in app stores
- Test with sandbox/test accounts

### Build Errors
- Run `flutter clean` then `flutter pub get`
- For iOS: run `pod install` in ios/ directory
- Check Flutter and package versions compatibility

## New Features Added

### Consent & Privacy
- **UMP consent forms** automatically show on first launch for EEA users
- **ATT prompts** appear on iOS after consent (if tracking is intended)
- **Non-personalized ads** served to users who don't consent
- **Consent management** accessible from store settings

### Hint System Integration
- **Automatic rewarded ads** when players run out of hints
- **Seamless hint earning** through ad completion
- **Persistent hint balance** across app sessions
- **Hint statistics** for analytics and user engagement

### Live Store Updates
- **Remove Ads** status updates immediately after purchase
- **Real-time entitlement checking** from RevenueCat
- **Localized pricing** from app stores
- **Purchase restoration** for cross-device access

### Development & Testing
- **Test device IDs** configured for development builds
- **Debug logging** for all monetization events
- **Analytics event hooks** ready for your analytics service
- **Error handling** with graceful fallbacks

## Support

For issues with:
- **AdMob**: Check [AdMob documentation](https://developers.google.com/admob)
- **RevenueCat**: Check [RevenueCat documentation](https://docs.revenuecat.com)
- **Flutter**: Check [Flutter documentation](https://flutter.dev/docs)
- **UMP Consent**: Check [Google UMP documentation](https://developers.google.com/admob/ump)
- **ATT**: Check [Apple App Tracking Transparency](https://developer.apple.com/app-store/user-privacy-and-data-use/)
