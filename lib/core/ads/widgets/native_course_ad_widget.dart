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
    _nativeAd?.dispose();
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
  }

  @override
  Widget build(BuildContext context) {
    if (!_isLoaded || _nativeAd == null) {
      return const SizedBox.shrink();
    }

    final height = MediaQuery.of(context).size.width > 400 ? 120.0 : 100.0;

    return Container(
      margin: widget.margin ?? const EdgeInsets.only(bottom: 12),
      height: height,
      decoration: BoxDecoration(
        color: context.brandColors.cardBackground.withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: context.colors.primary.withValues(alpha: 0.2),
          width: 1,
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
