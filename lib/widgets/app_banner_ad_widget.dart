import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import '../services/ad_service.dart';

class AppBannerAdWidget extends StatefulWidget {
  const AppBannerAdWidget({super.key});

  @override
  State<AppBannerAdWidget> createState() => _AppBannerAdWidgetState();
}

class _AppBannerAdWidgetState extends State<AppBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _loadBanner();
  }

  Future<void> _loadBanner() async {
    if (_bannerAd != null) return;

    final AnchoredAdaptiveBannerAdSize? size =
        await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
          MediaQuery.of(context).size.width.truncate(),
        );

    if (size == null) return;

    _bannerAd = BannerAd(
      adUnitId: AdService.bannerAdUnitId,
      size: size,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (ad) {
          if (mounted) setState(() => _isLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          _bannerAd = null;
          debugPrint('Banner failed: $error');
        },
      ),
    );

    await _bannerAd!.load();
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) return const SizedBox.shrink();
    return Center(
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }
}

// import 'package:flutter/material.dart';
// import 'package:google_mobile_ads/google_mobile_ads.dart';
// import '../services/ad_service.dart';
//
// class AppBannerAdWidget extends StatefulWidget {
//   const AppBannerAdWidget({super.key});
//
//   @override
//   State<AppBannerAdWidget> createState() => _AppBannerAdWidgetState();
// }
//
// class _AppBannerAdWidgetState extends State<AppBannerAdWidget> {
//   BannerAd? _bannerAd;
//   bool _isLoaded = false;
//
//   @override
//   void didChangeDependencies() {
//     super.didChangeDependencies();
//     _loadBanner();
//   }
//
//   Future<void> _loadBanner() async {
//     if (_bannerAd != null) return;
//
//     final AnchoredAdaptiveBannerAdSize? size =
//         await AdSize.getCurrentOrientationAnchoredAdaptiveBannerAdSize(
//           MediaQuery.of(context).size.width.truncate(),
//         );
//
//     if (size == null) return;
//
//     _bannerAd = BannerAd(
//       adUnitId: AdService.bannerAdUnitId,
//       size: size,
//       request: const AdRequest(),
//       listener: BannerAdListener(
//         onAdLoaded: (ad) {
//           setState(() {
//             _isLoaded = true;
//           });
//         },
//         onAdFailedToLoad: (ad, error) {
//           ad.dispose();
//           _bannerAd = null;
//           debugPrint('Banner failed: $error');
//         },
//       ),
//     );
//
//     await _bannerAd!.load();
//   }
//
//   @override
//   void dispose() {
//     _bannerAd?.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (!_isLoaded || _bannerAd == null) {
//       return const SizedBox.shrink();
//     }
//
//     return Center(
//       child: SizedBox(
//         width: _bannerAd!.size.width.toDouble(),
//         height: _bannerAd!.size.height.toDouble(),
//         child: AdWidget(ad: _bannerAd!),
//       ),
//     );
//   }
// }
