import 'package:card_mind/core/ads/ad_frequency_cap.dart';
import 'package:card_mind/core/ads/app_open_ad_service.dart';
import 'package:card_mind/core/ads/interstitial_ad_service.dart';
import 'package:card_mind/core/ads/rewarded_ad_service.dart';
import 'package:flutter/foundation.dart';

/// Single facade for all ad operations.
///
/// Screens should ONLY call [AdManager] — never reach into individual
/// services or [AdFrequencyCap] directly.
class AdManager {
  AdManager._();

  static final AdManager instance = AdManager._();

  final AdFrequencyCap _cap = AdFrequencyCap.instance;
  final InterstitialAdService _interstitial = InterstitialAdService.instance;
  final RewardedAdService _rewarded = RewardedAdService.instance;
  final AppOpenAdService _appOpen = AppOpenAdService.instance;

  /// Initialize all ad services and pre-load assets.
  /// Call AFTER [MobileAds.instance.initialize()] in `main.dart`.
  Future<void> initialize() async {
    await _cap.resetDailyCountersIfNeeded();
    await _interstitial.preloadAll();
    await _rewarded.loadRewardedAiAd();
    await _appOpen.initialize();
    debugPrint('[Ads] AdManager fully initialized');
  }

  // ── Session flags ──

  /// Call when the user enters a learning (flashcard) session.
  Future<void> setLearningSessionActive(bool value) async {
    await _cap.setLearningSessionActive(value);
  }

  /// Call when the user enters a test session.
  Future<void> setTestSessionActive(bool value) async {
    await _cap.setTestSessionActive(value);
  }

  /// Whether a learning session is currently active.
  Future<bool> isLearningSessionActive() async {
    return _cap.isLearningSessionActive();
  }

  /// Whether a test session is currently active.
  Future<bool> isTestSessionActive() async {
    return _cap.isTestSessionActive();
  }

  // ── Study completion (interstitial) ──

  /// Call when the user taps a navigation action on the study result screen.
  ///
  /// [sessionCards] is the total number of cards studied in this session.
  /// [onComplete] is always called regardless of ad shown/skipped.
  Future<void> onStudySessionCompleted({
    required int sessionCards,
    required VoidCallback onComplete,
  }) async {
    await _cap.markCompletedSession();
    await _interstitial.showAfterStudyAdIfAvailable(
      sessionCards: sessionCards,
      onComplete: onComplete,
    );
  }

  // ── Test completion (interstitial) ──

  /// Call when the user taps a navigation action on the test result screen.
  ///
  /// [questionCount] is the number of questions in the test.
  /// [onComplete] is always called regardless of ad shown/skipped.
  Future<void> onTestCompleted({
    required int questionCount,
    required VoidCallback onComplete,
  }) async {
    await _cap.markCompletedSession();
    await _interstitial.showAfterTestAdIfAvailable(
      questionCount: questionCount,
      onComplete: onComplete,
    );
  }

  // ── Rewarded (AI) ──

  /// Show a rewarded ad for AI quota.
  ///
  /// - [onRewardEarned]: User earned the reward (e.g. +3 AI turns).
  /// - [onClosed]: Ad closed (reward may or may not have been earned).
  /// - [onFailed]: Ad could not be shown.
  Future<void> showRewardedAi({
    required VoidCallback onRewardEarned,
    required VoidCallback onClosed,
    required VoidCallback onFailed,
  }) async {
    await _rewarded.showRewardedAiAdIfAvailable(
      onRewardEarned: onRewardEarned,
      onClosed: onClosed,
      onFailed: onFailed,
    );
  }

  /// Whether a rewarded ad is ready to show.
  bool get isRewardedReady => _rewarded.isAdReady;

  // ── Dispose ──

  void dispose() {
    _interstitial.dispose();
    _rewarded.dispose();
    _appOpen.dispose();
  }
}
