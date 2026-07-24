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
    if (_bannerAd == null && !_isLoaded) {
      _loadAd();
    }
  }

  void _loadAd() {
    _bannerAd?.dispose();

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
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _bannerAd == null) return const SizedBox.shrink();

    return SafeArea(
      child: SizedBox(
        width: _bannerAd!.size.width.toDouble(),
        height: _bannerAd!.size.height.toDouble(),
        child: AdWidget(ad: _bannerAd!),
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }
}
