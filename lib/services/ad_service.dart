import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AdService {
  AdService._();
  static final AdService instance = AdService._();

  // ── Ad Unit IDs ────────────────────────────────────────────────────────────
  static const String _androidBannerAdUnitId =
      'ca-app-pub-1267014580635785/3044112991';

  /// Returns the correct banner ad unit ID for the current platform.
  /// Falls back to the AdMob test banner ID on any unsupported platform.
  static String get bannerAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return _androidBannerAdUnitId;
    }
    // AdMob test banner for iOS (replace with a real iOS unit ID when ready)
    return 'ca-app-pub-3940256099942544/2934735716';
  }

  bool _initialized = false;

  /// Call once from main() before runApp().
  Future<void> initialize() async {
    // AdMob SDK only works on Android / iOS
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.android &&
            defaultTargetPlatform != TargetPlatform.iOS)) {
      return;
    }
    if (_initialized) return;
    await MobileAds.instance.initialize();
    _initialized = true;
  }

  /// Whether ads are supported on the current platform.
  bool get isSupported =>
      !kIsWeb &&
      (defaultTargetPlatform == TargetPlatform.android ||
          defaultTargetPlatform == TargetPlatform.iOS);
}
