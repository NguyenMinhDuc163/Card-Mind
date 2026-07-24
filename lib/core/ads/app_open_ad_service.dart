import 'dart:async';

import 'package:card_mind/core/ads/ad_frequency_cap.dart';
import 'package:card_mind/core/ads/ad_unit_ids.dart';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Manages App Open ads shown when the app returns from background.
///
/// Listens to [WidgetsBindingObserver] lifecycle events and shows an
/// App Open ad on resume if frequency cap allows.
class AppOpenAdService with WidgetsBindingObserver {
  AppOpenAdService._();

  static final AppOpenAdService instance = AppOpenAdService._();

  AppOpenAd? _ad;
  bool _loading = false;
  bool _initialized = false;
  bool _isShowing = false;

  final AdFrequencyCap _cap = AdFrequencyCap.instance;

  /// Initialize lifecycle observer and pre-load the first ad.
  Future<void> initialize() async {
    if (_initialized) return;
    _initialized = true;
    WidgetsBinding.instance.addObserver(this);
    await _cap.resetDailyCountersIfNeeded();
    await loadAd();
    debugPrint('[Ads] App Open service initialized');
  }

  /// Load an App Open ad.
  Future<void> loadAd() async {
    if (_loading) return;
    _loading = true;

    await _disposeAd(_ad);
    _ad = null;

    try {
      await AppOpenAd.load(
        adUnitId: AdUnitIds.appOpen,
        request: const AdRequest(),
        adLoadCallback: AppOpenAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('[Ads] App Open ad loaded');
            _ad = ad;
            _loading = false;
          },
          onAdFailedToLoad: (error) {
            debugPrint('[Ads] App Open ad load failed: $error');
            _loading = false;
          },
        ),
      );
    } catch (e) {
      debugPrint('[Ads] App Open ad load error: $e');
      _loading = false;
    }
  }

  /// Show App Open ad if frequency cap allows.
  Future<void> showAdIfAvailable() async {
    if (!_initialized) return;
    if (_isShowing) return;

    final canShow = await _cap.canShowAppOpen();
    if (!canShow) {
      debugPrint('[Ads] App Open skipped (cap)');
      return;
    }

    final ad = _ad;
    if (ad == null) {
      debugPrint('[Ads] App Open ad not loaded');
      return;
    }

    _isShowing = true;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('[Ads] App Open shown');
        _cap.markAppOpenShown();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[Ads] App Open show failed: $error');
        _disposeAd(ad);
        _ad = null;
        _isShowing = false;
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[Ads] App Open dismissed');
        _disposeAd(ad);
        _ad = null;
        _isShowing = false;
        loadAd();
      },
      onAdImpression: (ad) {
        debugPrint('[Ads] App Open impression');
      },
    );

    try {
      await ad.show();
    } catch (e) {
      debugPrint('[Ads] App Open show exception: $e');
      _disposeAd(ad);
      _ad = null;
      _isShowing = false;
    }
  }

  // ── Lifecycle ──

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      debugPrint('[Ads] App resumed — checking App Open ad');
      showAdIfAvailable();
    }
  }

  // ── Helpers ──

  Future<void> _disposeAd(AppOpenAd? ad) async {
    if (ad != null) {
      ad.fullScreenContentCallback = null;
      await ad.dispose();
    }
  }

  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    _disposeAd(_ad);
    _ad = null;
    _initialized = false;
  }
}
