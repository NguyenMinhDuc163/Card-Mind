/// Centralized ad configuration for Card Mind.
///
/// All frequency caps, placement rules, and behavioral toggles live here so
/// they can be tuned without touching individual screens or services.
class AdConfig {
  AdConfig._();

  /// Master kill-switch. Set to `false` to disable all ads globally.
  static const bool adsEnabled = true;

  /// Test mode: bypasses all frequency caps, cooldowns, session checks,
  /// and daily limits so ads show immediately. Also paints a red border
  /// around every ad widget for easy visual identification.
  ///
  /// Toggle this at runtime (e.g. in a debug menu) — never ship `true`.
  static bool testMode = false;

  // ── Interstitial ──

  /// Minimum cards studied before an interstitial can be shown.
  static const int minStudyCardsForInterstitial = 5;

  /// Minimum test questions before an interstitial can be shown.
  static const int minTestQuestionsForInterstitial = 5;

  /// Seconds between two interstitial showings.
  static const int interstitialCooldownSeconds = 180;

  /// Number of completed sessions required between interstitials.
  static const int minCompletedSessionsBetweenInterstitials = 2;

  /// Maximum interstitial impressions per user per calendar day.
  static const int maxInterstitialPerDay = 5;

  // ── Rewarded ──

  /// Maximum rewarded ad views per user per calendar day.
  static const int maxRewardedPerDay = 10;

  /// Seconds after a rewarded ad before an interstitial can be shown.
  static const int rewardedToInterstitialCooldownSeconds = 120;

  // ── App Open ──

  /// Minimum hours between two App Open ad impressions.
  static const int appOpenCooldownHours = 6;

  /// Minimum minutes after any interstitial before an App Open can be shown.
  static const int appOpenAfterInterstitialCooldownMinutes = 5;

  // ── Native placements ──

  /// Home: minimum courses before a native ad is inserted.
  static const int homeNativeMinCourses = 4;

  /// Home: insert native ad after this index (0-based).
  static const int homeNativeInsertAfterIndex = 2;

  /// Library: insert first native ad after this index.
  static const int libraryNativeFirstInsertAfterIndex = 3;

  /// Library: insert second native ad after this index.
  static const int libraryNativeSecondInsertAfterIndex = 10;

  /// Library: minimum items required for second native ad.
  static const int libraryNativeMinItemsForSecondAd = 12;

  /// Library: maximum native ads.
  static const int libraryNativeMaxAds = 2;

  /// Search: minimum results before inserting a native ad.
  static const int searchNativeMinResults = 5;

  /// Search: insert native ad after this index.
  static const int searchNativeInsertAfterIndex = 3;

}
