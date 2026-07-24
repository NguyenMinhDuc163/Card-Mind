import 'package:card_mind/core/ads/ad_config.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';

/// Storage keys used by [AdFrequencyCap].
class AdStorageKeys {
  AdStorageKeys._();

  static const String lastInterstitialShownAt =
      'ads_last_interstitial_shown_at';
  static const String completedSessionsSinceLastInterstitial =
      'ads_completed_sessions_since_last_interstitial';
  static const String dailyInterstitialCount = 'ads_daily_interstitial_count';
  static const String dailyRewardedCount = 'ads_daily_rewarded_count';
  static const String dailyCounterDate = 'ads_daily_counter_date';
  static const String lastRewardedShownAt = 'ads_last_rewarded_shown_at';
  static const String lastAppOpenShownAt = 'ads_last_app_open_shown_at';
  static const String isLearningSession = 'ads_is_learning_session';
  static const String isTestSession = 'ads_is_test_session';
  static const String openedFromReviewNotification =
      'ads_opened_from_review_notification';
}

/// Enforces frequency caps and session-awareness rules for all ad formats.
///
/// Uses [LocalStorageHelper] (Hive) for lightweight persistence. All methods
/// are async so they can be called from any isolate / service.
class AdFrequencyCap {
  AdFrequencyCap._();

  static final AdFrequencyCap instance = AdFrequencyCap._();

  // ── Daily counter helpers ──

  Future<void> _resetDailyIfNeeded() async {
    final today = _todayKey();
    final stored = LocalStorageHelper.getValue(AdStorageKeys.dailyCounterDate);
    if (stored != today) {
      await LocalStorageHelper.setValue(
        AdStorageKeys.dailyCounterDate,
        today,
      );
      await LocalStorageHelper.setValue(
        AdStorageKeys.dailyInterstitialCount,
        0,
      );
      await LocalStorageHelper.setValue(AdStorageKeys.dailyRewardedCount, 0);
    }
  }

  Future<int> _getDailyInterstitialCount() async {
    await _resetDailyIfNeeded();
    return LocalStorageHelper.getValue(
          AdStorageKeys.dailyInterstitialCount,
        ) as int? ??
        0;
  }

  Future<int> _getDailyRewardedCount() async {
    await _resetDailyIfNeeded();
    return LocalStorageHelper.getValue(AdStorageKeys.dailyRewardedCount) as int? ??
        0;
  }

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  // ── Timestamp helpers ──

  int _nowMs() => DateTime.now().millisecondsSinceEpoch;

  int? _getTimestamp(String key) =>
      LocalStorageHelper.getValue(key) as int?;

  int _secondsSince(int? timestampMs) {
    if (timestampMs == null) return 999999;
    return ((_nowMs() - timestampMs) / 1000).round();
  }

  // ── Interstitial ──

  /// Whether an after-study interstitial can be shown.
  Future<bool> canShowStudyInterstitial({
    required int sessionCards,
  }) async {
    if (!AdConfig.adsEnabled) return false;
    if (sessionCards < AdConfig.minStudyCardsForInterstitial) return false;

    return _canShowInterstitialCommon();
  }

  /// Whether an after-test interstitial can be shown.
  Future<bool> canShowTestInterstitial({
    required int questionCount,
  }) async {
    if (!AdConfig.adsEnabled) return false;
    if (questionCount < AdConfig.minTestQuestionsForInterstitial) return false;

    return _canShowInterstitialCommon();
  }

  Future<bool> _canShowInterstitialCommon() async {
    final completedSessions = LocalStorageHelper.getValue(
          AdStorageKeys.completedSessionsSinceLastInterstitial,
        ) as int? ??
        0;
    if (completedSessions < AdConfig.minCompletedSessionsBetweenInterstitials) {
      return false;
    }

    final dailyCount = await _getDailyInterstitialCount();
    if (dailyCount >= AdConfig.maxInterstitialPerDay) return false;

    final lastInterstitial = _getTimestamp(
      AdStorageKeys.lastInterstitialShownAt,
    );
    if (_secondsSince(lastInterstitial) < AdConfig.interstitialCooldownSeconds) {
      return false;
    }

    final lastRewarded = _getTimestamp(AdStorageKeys.lastRewardedShownAt);
    if (_secondsSince(lastRewarded) <
        AdConfig.rewardedToInterstitialCooldownSeconds) {
      return false;
    }

    if (await isLearningSessionActive()) return false;
    if (await isTestSessionActive()) return false;

    return true;
  }

  /// Call after an interstitial is shown to update counters.
  Future<void> markInterstitialShown() async {
    await LocalStorageHelper.setValue(
      AdStorageKeys.lastInterstitialShownAt,
      _nowMs(),
    );

    final current = await _getDailyInterstitialCount();
    await LocalStorageHelper.setValue(
      AdStorageKeys.dailyInterstitialCount,
      current + 1,
    );

    // Reset completed sessions counter
    await LocalStorageHelper.setValue(
      AdStorageKeys.completedSessionsSinceLastInterstitial,
      0,
    );
  }

  /// Call after a study or test session completes (regardless of ad shown).
  Future<void> markCompletedSession() async {
    final current = LocalStorageHelper.getValue(
          AdStorageKeys.completedSessionsSinceLastInterstitial,
        ) as int? ??
        0;
    await LocalStorageHelper.setValue(
      AdStorageKeys.completedSessionsSinceLastInterstitial,
      current + 1,
    );
  }

  // ── Rewarded ──

  /// Whether a rewarded ad can be shown (user-initiated).
  Future<bool> canShowRewarded() async {
    if (!AdConfig.adsEnabled) return false;
    final dailyCount = await _getDailyRewardedCount();
    return dailyCount < AdConfig.maxRewardedPerDay;
  }

  /// Call after a rewarded ad is shown.
  Future<void> markRewardedShown() async {
    await LocalStorageHelper.setValue(
      AdStorageKeys.lastRewardedShownAt,
      _nowMs(),
    );
    final current = await _getDailyRewardedCount();
    await LocalStorageHelper.setValue(
      AdStorageKeys.dailyRewardedCount,
      current + 1,
    );
  }

  // ── App Open ──

  /// Whether an App Open ad can be shown on app resume.
  Future<bool> canShowAppOpen() async {
    if (!AdConfig.adsEnabled) return false;

    final lastAppOpen = _getTimestamp(AdStorageKeys.lastAppOpenShownAt);
    final cooldownSec = AdConfig.appOpenCooldownHours * 3600;
    if (_secondsSince(lastAppOpen) < cooldownSec) return false;

    final lastInterstitial = _getTimestamp(
      AdStorageKeys.lastInterstitialShownAt,
    );
    final interstitialCooldownSec =
        AdConfig.appOpenAfterInterstitialCooldownMinutes * 60;
    if (_secondsSince(lastInterstitial) < interstitialCooldownSec) return false;

    if (await isLearningSessionActive()) return false;
    if (await isTestSessionActive()) return false;

    final openedFromReview = LocalStorageHelper.getValue(
          AdStorageKeys.openedFromReviewNotification,
        ) as bool? ??
        false;
    if (openedFromReview) return false;

    return true;
  }

  /// Call after an App Open ad is shown.
  Future<void> markAppOpenShown() async {
    await LocalStorageHelper.setValue(
      AdStorageKeys.lastAppOpenShownAt,
      _nowMs(),
    );
  }

  // ── Session flags ──

  Future<void> setLearningSessionActive(bool value) async {
    await LocalStorageHelper.setValue(AdStorageKeys.isLearningSession, value);
  }

  Future<void> setTestSessionActive(bool value) async {
    await LocalStorageHelper.setValue(AdStorageKeys.isTestSession, value);
  }

  Future<bool> isLearningSessionActive() async {
    return LocalStorageHelper.getValue(AdStorageKeys.isLearningSession) as bool? ??
        false;
  }

  Future<bool> isTestSessionActive() async {
    return LocalStorageHelper.getValue(AdStorageKeys.isTestSession) as bool? ??
        false;
  }

  // ── Notification flag ──

  Future<void> setOpenedFromReviewNotification(bool value) async {
    await LocalStorageHelper.setValue(
      AdStorageKeys.openedFromReviewNotification,
      value,
    );
  }

  /// Reset all daily counters if the stored date doesn't match today.
  /// Called automatically by the daily counter helpers; exposed for early
  /// reset if needed (e.g. on app init).
  Future<void> resetDailyCountersIfNeeded() async {
    await _resetDailyIfNeeded();
  }
}
