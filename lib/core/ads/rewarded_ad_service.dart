import 'package:card_mind/core/ads/ad_frequency_cap.dart';
import 'package:card_mind/core/ads/ad_unit_ids.dart';
import 'package:flutter/foundation.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

/// Manages rewarded ads for AI chat quota and other reward-based placements.
///
/// Rewarded ads are user-initiated only — the user must actively tap to watch
/// an ad in exchange for a benefit. Never auto-show rewarded ads.
class RewardedAdService {
  RewardedAdService._();

  static final RewardedAdService instance = RewardedAdService._();

  RewardedAd? _ad;
  bool _loading = false;

  final AdFrequencyCap _cap = AdFrequencyCap.instance;

  /// Load a rewarded ad for the AI placement.
  Future<void> loadRewardedAiAd() async {
    if (_loading) return;
    _loading = true;

    await _disposeAd(_ad);
    _ad = null;

    try {
      await RewardedAd.load(
        adUnitId: AdUnitIds.rewardedAi,
        request: const AdRequest(),
        rewardedAdLoadCallback: RewardedAdLoadCallback(
          onAdLoaded: (ad) {
            debugPrint('[Ads] Rewarded AI ad loaded');
            _ad = ad;
            _loading = false;
          },
          onAdFailedToLoad: (error) {
            debugPrint('[Ads] Rewarded AI ad load failed: $error');
            _loading = false;
          },
        ),
      );
    } catch (e) {
      debugPrint('[Ads] Rewarded AI ad load error: $e');
      _loading = false;
    }
  }

  /// Show the rewarded ad if available and frequency cap allows.
  ///
  /// - [onRewardEarned]: Called when the user has earned the reward.
  /// - [onClosed]: Called when the ad is closed (reward may or may not be earned).
  /// - [onFailed]: Called when the ad cannot be shown.
  Future<void> showRewardedAiAdIfAvailable({
    required VoidCallback onRewardEarned,
    required VoidCallback onClosed,
    required VoidCallback onFailed,
  }) async {
    final canShow = await _cap.canShowRewarded();
    if (!canShow) {
      debugPrint('[Ads] Rewarded AI skipped (cap)');
      onFailed();
      return;
    }

    final ad = _ad;
    if (ad == null) {
      debugPrint('[Ads] Rewarded AI ad not loaded');
      onFailed();
      return;
    }

    bool rewardEarned = false;

    ad.fullScreenContentCallback = FullScreenContentCallback(
      onAdShowedFullScreenContent: (ad) {
        debugPrint('[Ads] Rewarded AI ad shown');
        _cap.markRewardedShown();
      },
      onAdFailedToShowFullScreenContent: (ad, error) {
        debugPrint('[Ads] Rewarded AI show failed: $error');
        _disposeAd(ad);
        _ad = null;
        onFailed();
      },
      onAdDismissedFullScreenContent: (ad) {
        debugPrint('[Ads] Rewarded AI ad dismissed');
        _disposeAd(ad);
        _ad = null;
        loadRewardedAiAd(); // Preload next
        if (rewardEarned) {
          onRewardEarned();
        }
        onClosed();
      },
      onAdImpression: (ad) {
        debugPrint('[Ads] Rewarded AI impression');
      },
    );

    try {
      await ad.show(
        onUserEarnedReward: (ad, reward) {
          debugPrint(
            '[Ads] Rewarded AI earned: ${reward.amount} ${reward.type}',
          );
          rewardEarned = true;
        },
      );
    } catch (e) {
      debugPrint('[Ads] Rewarded AI show exception: $e');
      _disposeAd(ad);
      _ad = null;
      onFailed();
    }
  }

  /// Whether a rewarded ad is currently loaded and ready to show.
  bool get isAdReady => _ad != null;

  Future<void> _disposeAd(RewardedAd? ad) async {
    if (ad != null) {
      ad.fullScreenContentCallback = null;
      await ad.dispose();
    }
  }

  void dispose() {
    _disposeAd(_ad);
    _ad = null;
  }
}
