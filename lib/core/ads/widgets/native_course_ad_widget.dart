import 'package:card_mind/core/ads/ad_config.dart';
import 'package:flutter/material.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/core/theme/app_text_styles.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// A native ad widget styled to match the Card Mind app design.
///
/// Displays a Google native ad as a card with dark/light theme support.
/// If the ad fails to load, returns [SizedBox.shrink] to avoid layout jumps.
class NativeCourseAdWidget extends StatefulWidget {
  final String adUnitId;
  final EdgeInsetsGeometry? margin;

  const NativeCourseAdWidget({
    super.key,
    required this.adUnitId,
    this.margin,
  });

  @override
  State<NativeCourseAdWidget> createState() => _NativeCourseAdWidgetState();
}

class _NativeCourseAdWidgetState extends State<NativeCourseAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoaded = false;

  @override
  void initState() {
    super.initState();
    _loadAd();
  }

  void _loadAd() {
    // Ensure any previous platform view is fully disposed before creating a
    // new one – avoids "trying to create an already created view" on iOS.
    _nativeAd?.dispose();
    _nativeAd = null;

    // Defer creation so the platform has time to tear down the old view.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || _isLoaded || _nativeAd != null) return;

      _nativeAd = NativeAd(
        adUnitId: widget.adUnitId,
        factoryId: 'listTile',
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (ad) {
            if (mounted) {
              setState(() => _isLoaded = true);
            }
          },
          onAdFailedToLoad: (ad, error) {
            debugPrint('[Ads] Native ad load failed: $error');
            ad.dispose();
            _nativeAd = null;
            if (mounted) {
              setState(() => _isLoaded = false);
            }
          },
          onAdImpression: (_) {
            debugPrint('[Ads] Native ad impression');
          },
        ),
      )..load();
    });
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.width > 400 ? 120.0 : 100.0;

    // Test mode: always show a visible placeholder so the developer can
    // see where the ad slot is, even if the real ad hasn't loaded yet.
    if (AdConfig.testMode && (!_isLoaded || _nativeAd == null)) {
      return Container(
        margin: widget.margin ?? const EdgeInsets.only(bottom: 12),
        height: height,
        decoration: BoxDecoration(
          color: Colors.red.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.red, width: 3),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.ad_units, color: Colors.red, size: 32),
              const SizedBox(height: 6),
              Text(
                'NATIVE AD SLOT',
                style: AppTextStyles.textContent4.copyWith(
                  color: Colors.red,
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                _isLoaded ? 'LOADED (no ad)' : 'LOADING…',
                style: AppTextStyles.textContent4.copyWith(
                  color: Colors.red.withValues(alpha: 0.7),
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }

    final borderColor = AdConfig.testMode
        ? Colors.red
        : context.colors.primary.withValues(alpha: 0.2);
    final borderWidth = AdConfig.testMode ? 3.0 : 1.0;

    return Container(
      margin: widget.margin ?? const EdgeInsets.only(bottom: 12),
      height: height,
      decoration: BoxDecoration(
        color: context.brandColors.cardBackground.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: borderColor,
          width: borderWidth,
        ),
      ),
      child: Stack(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: AdWidget(ad: _nativeAd!),
          ),
          // "Ad" badge
          Positioned(
            top: 6,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color:
                    context.brandColors.buttonPrimary.withValues(alpha: 0.9),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Text(
                'Ad',
                style: AppTextStyles.textContent4.copyWith(
                  color: context.brandColors.textPrimary,
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          if (AdConfig.testMode)
            Positioned(
              top: 6,
              left: 8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'TEST',
                  style: AppTextStyles.textContent4.copyWith(
                    color: Colors.white,
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }
}
