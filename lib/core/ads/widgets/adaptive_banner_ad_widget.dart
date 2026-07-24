import 'package:card_mind/core/ads/ad_config.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A banner ad widget for placement at the bottom of screens.
///
/// Falls back to [SizedBox.shrink] on load failure to avoid layout jumps.
class AdaptiveBannerAdWidget extends StatefulWidget {
  final String adUnitId;

  const AdaptiveBannerAdWidget({super.key, required this.adUnitId});

  @override
  State<AdaptiveBannerAdWidget> createState() => _AdaptiveBannerAdWidgetState();
}

class _AdaptiveBannerAdWidgetState extends State<AdaptiveBannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Only load when the ad hasn't been loaded AND the old one is fully gone.
    if (!_isLoaded && _bannerAd == null) {
      _loadAd();
    }
  }

  void _loadAd() {
    // Ensure any previous platform view is fully disposed before creating a
    // new one – avoids "trying to create an already created view" on iOS.
    _bannerAd?.dispose();
    _bannerAd = null;

    // Defer creation so the platform has time to tear down the old view.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isLoaded || _bannerAd != null) return;

      _bannerAd = BannerAd(
        adUnitId: widget.adUnitId,
        request: const AdRequest(),
        size: AdSize.banner,
        listener: BannerAdListener(
          onAdLoaded: (ad) {
            if (mounted) setState(() => _isLoaded = true);
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('[Ads] Banner load failed: $error');
            ad.dispose();
            _bannerAd = null;
            if (mounted) setState(() => _isLoaded = false);
          },
          onAdOpened: (_) {},
          onAdClosed: (_) {},
          onAdImpression: (_) {
            debugPrint('[Ads] Banner impression');
          },
        ),
      )..load();
    });
  }

  @override
  Widget build(BuildContext context) {
    // Test mode: show a visible placeholder even when the ad hasn't loaded.
    if (AdConfig.testMode && (!_isLoaded || _bannerAd == null)) {
      return SafeArea(
        child: Container(
          width: double.infinity,
          height: 60,
          decoration: BoxDecoration(
            color: Colors.red.withValues(alpha: 0.05),
            border: Border.all(color: Colors.red, width: 2),
          ),
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.ad_units, color: Colors.red, size: 20),
                const SizedBox(width: 8),
                Text(
                  'BANNER AD SLOT',
                  style: TextStyle(
                    color: Colors.red,
                    fontWeight: FontWeight.w700,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }

    if (!_isLoaded || _bannerAd == null) return const SizedBox.shrink();

    Widget adWidget = SizedBox(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      child: AdWidget(ad: _bannerAd!),
    );

    if (AdConfig.testMode) {
      adWidget = Container(
        decoration: BoxDecoration(
          border: Border.all(color: Colors.red, width: 2),
        ),
        child: adWidget,
      );
    }

    return SafeArea(child: adWidget);
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
