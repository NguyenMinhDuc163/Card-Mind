import 'dart:async';

import 'package:card_mind/core/ads/ad_frequency_cap.dart';
import 'package:card_mind/core/ads/ad_unit_ids.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Manages interstitial ads for after-study and after-test placements.
///
/// Pre-loads ads so they are ready when the frequency cap allows showing.
/// Always calls [onComplete] regardless of success — navigation must never
/// be blocked by a failed ad.
class InterstitialAdService {
  InterstitialAdService._();

  static final InterstitialAdService instance = InterstitialAdService._();

  InterstitialAd? _studyAd;
  InterstitialAd? _testAd;

  bool _studyAdLoading = false;
  bool _testAdLoading = false;

  final AdFrequencyCap _cap = AdFrequencyCap.instance;

  // ── Load ──

  Future<void> loadAfterStudyAd() async {
    if (_studyAdLoading) return;
    _studyAdLoading = true;

    await _disposeAd(_studyAd);
    _studyAd = null;

    try {
      await InterstitialAd.load(
        adUnitId: AdUnitIds.afterStudyInterstitial,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('[Ads] After-study interstitial loaded');
            _studyAd = ad;
            _studyAdLoading = false;
          },
          onAdFailedToLoad: (error) {
            debugPrint('[Ads] After-study interstitial load failed: $error');
            _studyAdLoading = false;
          },
        ),
      );
    } catch (e) {
      debugPrint('[Ads] After-study interstitial load error: $e');
      _studyAdLoading = false;
    }
  }

  Future<void> loadAfterTestAd() async {
    if (_testAdLoading) return;
    _testAdLoading = true;

    await _disposeAd(_testAd);
    _testAd = null;

    try {
      await InterstitialAd.load(
        adUnitId: AdUnitIds.afterTestInterstitial,
        request: const AdRequest(),
        adLoadCallback: InterstitialAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('[Ads] After-test interstitial loaded');
            _testAd = ad;
            _testAdLoading = false;
          },
          onAdFailedToLoad: (error) {
            debugPrint('[Ads] After-test interstitial load failed: $error');
            _testAdLoading = false;
          },
        ),
      );
    } catch (e) {
      debugPrint('[Ads] After-test interstitial load error: $e');
      _testAdLoading = false;
    }
  }

  /// Pre-load both interstitial types (call after SDK init).
  Future<void> preloadAll() async {
    await Future.wait([loadAfterStudyAd(), loadAfterTestAd()]);
  }

  // ── Show ──

  /// Show after-study interstitial if frequency cap allows.
  ///
  /// [onComplete] is called in all cases — ad shown, cap blocked, load failed,
  /// or user closed the ad.
  Future<void> showAfterStudyAdIfAvailable({
    required int sessionCards,
    required VoidCallback onComplete,
  }) async {
    final canShow = await _cap.canShowStudyInterstitial(
      sessionCards: sessionCards,
    );

    if (!canShow) {
      debugPrint('[Ads] After-study interstitial skipped (cap)');
      onComplete();
      return;
    }

    final ad = _studyAd;
    if (ad == null) {
      debugPrint('[Ads] After-study interstitial not loaded yet');
      onComplete();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('[Ads] After-study interstitial shown');
        _cap.markInterstitialShown();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[Ads] After-study interstitial show failed: $error');
        _disposeAd(ad);
        _studyAd = null;
        onComplete();
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[Ads] After-study interstitial dismissed');
        _disposeAd(ad);
        _studyAd = null;
        // Pre-load next ad
        loadAfterStudyAd();
        onComplete();
      },
      onAdImpression: (ad) {
        debugPrint('[Ads] After-study interstitial impression');
      },
    );

    try {
      await ad.show();
    } catch (e) {
      debugPrint('[Ads] After-study interstitial show exception: $e');
      _disposeAd(ad);
      _studyAd = null;
      onComplete();
    }
  }

  /// Show after-test interstitial if frequency cap allows.
  ///
  /// [onComplete] is called in all cases.
  Future<void> showAfterTestAdIfAvailable({
    required int questionCount,
    required VoidCallback onComplete,
  }) async {
    final canShow = await _cap.canShowTestInterstitial(
      questionCount: questionCount,
    );

    if (!canShow) {
      debugPrint('[Ads] After-test interstitial skipped (cap)');
      onComplete();
      return;
    }

    final ad = _testAd;
    if (ad == null) {
      debugPrint('[Ads] After-test interstitial not loaded yet');
      onComplete();
      return;
    }

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('[Ads] After-test interstitial shown');
        _cap.markInterstitialShown();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[Ads] After-test interstitial show failed: $error');
        _disposeAd(ad);
        _testAd = null;
        onComplete();
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[Ads] After-test interstitial dismissed');
        _disposeAd(ad);
        _testAd = null;
        loadAfterTestAd();
        onComplete();
      },
      onAdImpression: (ad) {
        debugPrint('[Ads] After-test interstitial impression');
      },
    );

    try {
      await ad.show();
    } catch (e) {
      debugPrint('[Ads] After-test interstitial show exception: $e');
      _disposeAd(ad);
      _testAd = null;
      onComplete();
    }
  }

  // ── Helpers ──

  Future<void> _disposeAd(InterstitialAd? ad) async {
    if (ad != null) {
      ad.fullScreenContentCallback = null;
      await ad.dispose();
    }
  }

  void dispose() {
    _disposeAd(_studyAd);
    _disposeAd(_testAd);
    _studyAd = null;
    _testAd = null;
  }
}
