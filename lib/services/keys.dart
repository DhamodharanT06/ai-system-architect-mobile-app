class AdKeys {
  // Test Android
  static const String testRewardAdKey =
      'ca-app-pub-3940256099942544/5224354917';
  static const String testBannerAdKey =
      'ca-app-pub-3940256099942544/6300978111';

  // Test iOS
  static const String testRewardAdKeyIOS =
      'ca-app-pub-3940256099942544/1712485313';
  static const String testBannerAdKeyIOS =
      'ca-app-pub-3940256099942544/2934735716';

  // Real Android
  static const String _rewardAd = 'ca-app-pub-5197112083845726/2055303339';
  static const String _bannerAd = 'ca-app-pub-5197112083845726/5067077114';

  static const int adsPerReward = 3;
  static const int adsPerRewardPreview = 3;

  String get rewardAdKey => _rewardAd;
  String get bannerAdKey => _bannerAd;
}

class BackendAPI {
  static const String _backurl = 'https://ai-system-architect-ba2x.vercel.app/';
  String get BackendURL => _backurl;
}
