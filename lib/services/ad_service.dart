import 'package:ai_system_architecture/services/keys.dart';
import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:shared_preferences/shared_preferences.dart';

class AdService extends ChangeNotifier {
  static const _prefKeyTotal = 'generation_count';
  static const _prefKeyFeatureBase = 'feature_count_';
  static const _adsPerReward = AdKeys.adsPerReward;
  static const _adsPerRewardPreview = AdKeys.adsPerRewardPreview;

  static const _featureThresholds = <String, int>{
    'blueprint': _adsPerReward,
    'preview': _adsPerRewardPreview,
    'flow': _adsPerRewardPreview,
  };

  /// Fallback threshold for any feature not listed above.
  static const _defaultThreshold = 3;

  // ── Ad Unit IDs ───────────────────────────────────────────────────────────
  static String get _rewardedAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return kDebugMode ? AdKeys.testRewardAdKey : AdKeys().rewardAdKey;
    }
    return AdKeys.testRewardAdKeyIOS; // iOS test
  }

  static String get bannerAdUnitId {
    if (defaultTargetPlatform == TargetPlatform.android) {
      return kDebugMode ? AdKeys.testBannerAdKey : AdKeys().bannerAdKey;
    }
    return AdKeys.testBannerAdKeyIOS; // iOS test
  }

  // ── State ─────────────────────────────────────────────────────────────────
  RewardedAd? _rewardedAd;
  bool _isRewardedLoaded = false;
  int _blueprintCount = 0;
  final Map<String, int> _featureCounts = {};

  // ── Public getters ────────────────────────────────────────────────────────
  bool get isRewardedLoaded => _isRewardedLoaded;
  int get generationCount => _blueprintCount;
  int get adsWatched =>
      _blueprintCount ~/ (_featureThresholds['blueprint'] ?? _defaultThreshold);

  // ── Init ──────────────────────────────────────────────────────────────────
  Future<void> init() async {
    await MobileAds.instance.initialize();
    final prefs = await SharedPreferences.getInstance();

    _blueprintCount = prefs.getInt(_prefKeyTotal) ?? 0;

    for (final key in _featureThresholds.keys) {
      _featureCounts[key] = prefs.getInt('$_prefKeyFeatureBase$key') ?? 0;
    }

    _loadRewardedAd();
    notifyListeners();
  }

  void _loadRewardedAd() {
    RewardedAd.load(
      adUnitId: _rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) {
          _rewardedAd = ad;
          _isRewardedLoaded = true;
          notifyListeners();
        },
        onAdFailedToLoad: (err) {
          debugPrint('Rewarded ad failed to load: $err');
          _isRewardedLoaded = false;
        },
      ),
    );
  }

  // ── Core ad gate ──────────────────────────────────────────────────────────
  Future<bool> handleFeatureAction({
    required String featureKey,
    required VoidCallback onAdComplete,
    required VoidCallback onAdSkipped,
  }) async {
    final prefs = await SharedPreferences.getInstance();
    final prefKey = '$_prefKeyFeatureBase$featureKey';

    final newCount = (_featureCounts[featureKey] ?? 0) + 1;
    _featureCounts[featureKey] = newCount;
    await prefs.setInt(prefKey, newCount);

    if (featureKey == 'blueprint') {
      _blueprintCount++;
      await prefs.setInt(_prefKeyTotal, _blueprintCount);
    }

    notifyListeners();

    final threshold = _featureThresholds[featureKey] ?? _defaultThreshold;

    if (newCount % threshold == 0) {
      if (_isRewardedLoaded && _rewardedAd != null) {
        _rewardedAd!.fullScreenContentCallback = FullScreenContentCallback(
          onAdDismissedFullScreenContent: (ad) {
            ad.dispose();
            _rewardedAd = null;
            _isRewardedLoaded = false;
            _loadRewardedAd();
            onAdComplete();
          },
          onAdFailedToShowFullScreenContent: (ad, err) {
            debugPrint('Rewarded ad failed to show: $err');
            ad.dispose();
            _rewardedAd = null;
            _isRewardedLoaded = false;
            _loadRewardedAd();
            onAdSkipped();
          },
        );
        await _rewardedAd!.show(
          onUserEarnedReward: (_, reward) {
            debugPrint('User earned: ${reward.amount} ${reward.type}');
          },
        );
        return true;
      } else {
        _loadRewardedAd();
        onAdSkipped();
        return false;
      }
    }

    onAdComplete();
    return false;
  }

  /// Backwards-compatible wrapper for blueprint generation.
  Future<bool> handlePreGeneration({
    required VoidCallback onAdComplete,
    required VoidCallback onAdSkipped,
  }) => handleFeatureAction(
    featureKey: 'blueprint',
    onAdComplete: onAdComplete,
    onAdSkipped: onAdSkipped,
  );

  BannerAd createBannerAd({required BannerAdListener listener}) => BannerAd(
    adUnitId: bannerAdUnitId,
    size: AdSize.banner,
    request: const AdRequest(),
    listener: listener,
  );

  @override
  void dispose() {
    _rewardedAd?.dispose();
    super.dispose();
  }
}
