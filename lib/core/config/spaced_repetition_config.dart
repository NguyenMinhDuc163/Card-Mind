/// 🧪 Config cho Spaced Repetition
///
/// ⚡ CHỈ CẦN THAY ĐỔI 1 CHỖ DUY NHẤT:
/// Đổi [isTestMode] = true/false để switch giữa test và production
class SpacedRepetitionConfig {
  SpacedRepetitionConfig._();

  // ============================================================
  // 🎯 THAY ĐỔI CHỖ NÀY ĐỂ SWITCH MODE
  // ============================================================

  /// 🧪 TEST MODE
  /// - true: Dùng PHÚT để test nhanh (1 phút, 3 phút, 8 phút...)
  /// - false: Dùng NGÀY cho production (1 ngày, 3 ngày, 8 ngày...)
  static const bool isTestMode = true; // 👈 THAY ĐỔI Ở ĐÂY!

  // ============================================================

  // ============ PRODUCTION INTERVALS (NGÀY) ============
  static const int _productionInterval1 = 1; // 1 ngày
  static const int _productionInterval2 = 3; // 3 ngày
  static const int _productionMaxInterval = 180; // 180 ngày (6 tháng)

  // ============ TEST INTERVALS (PHÚT) ============
  static const int _testInterval1 = 1; // 1 phút
  static const int _testInterval2 = 3; // 3 phút
  static const int _testMaxInterval = 30; // 30 phút

  // ============ AUTO-SELECTED INTERVALS ============

  /// Interval cho lần ôn tập đầu tiên
  /// - Production: 1 ngày
  /// - Test: 1 phút
  static int get interval1 => isTestMode ? _testInterval1 : _productionInterval1;

  /// Interval cho lần ôn tập thứ 2
  /// - Production: 3 ngày
  /// - Test: 3 phút
  static int get interval2 => isTestMode ? _testInterval2 : _productionInterval2;

  /// Interval tối đa
  /// - Production: 180 ngày (6 tháng)
  /// - Test: 30 phút
  static int get maxInterval => isTestMode ? _testMaxInterval : _productionMaxInterval;

  /// Đơn vị thời gian đang dùng
  /// - Production: "ngày"
  /// - Test: "phút"
  static String get timeUnit => isTestMode ? 'phút' : 'ngày';

  /// Tạo Duration cho interval
  /// - Production: Duration(days: interval)
  /// - Test: Duration(minutes: interval)
  static Duration getDuration(int interval) {
    return isTestMode
        ? Duration(minutes: interval)
        : Duration(days: interval);
  }

  // ============ EASE FACTOR CONFIG ============

  /// Ease factor ban đầu (SuperMemo SM-2)
  static const double initialEaseFactor = 2.5;

  /// Ease factor tăng khi swipe right (đã nhớ)
  static const double easeFactorIncrement = 0.1;

  /// Ease factor giảm khi swipe left (chưa nhớ)
  static const double easeFactorDecrement = 0.2;

  /// Ease factor tối thiểu
  static const double minEaseFactor = 1.3;

  /// Ease factor tối đa
  static const double maxEaseFactor = 2.5;

  // ============ QUALITY CONFIG ============

  /// Quality khi swipe right (đã nhớ)
  static const int qualityCorrect = 4;

  /// Quality khi swipe left (chưa nhớ)
  static const int qualityIncorrect = 1;

  /// Quality mặc định
  static const int qualityDefault = 3;

  // ============ DEBUG HELPERS ============

  /// In ra thông tin config hiện tại
  static void printConfig() {
    print('');
    print('╔════════════════════════════════════════════════════════╗');
    print('║     SPACED REPETITION CONFIG                          ║');
    print('╠════════════════════════════════════════════════════════╣');
    print('║ Mode: ${isTestMode ? "🧪 TEST MODE (PHÚT)" : "🚀 PRODUCTION MODE (NGÀY)"}');
    print('║ Interval 1: ${interval1} $timeUnit');
    print('║ Interval 2: ${interval2} $timeUnit');
    print('║ Max Interval: ${maxInterval} $timeUnit');
    print('║ Ease Factor: $initialEaseFactor (±$easeFactorIncrement/$easeFactorDecrement)');
    print('╚════════════════════════════════════════════════════════╝');
    print('');
  }

  /// Ví dụ timeline với config hiện tại
  static void printTimeline() {
    print('');
    print('📅 TIMELINE ÔN TẬP VỚI CONFIG HIỆN TẠI:');
    print('─────────────────────────────────────────');
    print('Lần 1: Ôn lại sau $interval1 $timeUnit');
    print('Lần 2: Ôn lại sau $interval2 $timeUnit');
    final interval3 = (interval2 * initialEaseFactor).round();
    print('Lần 3: Ôn lại sau $interval3 $timeUnit (≈ ${interval2} × ${initialEaseFactor})');
    final interval4 = (interval3 * initialEaseFactor).round();
    print('Lần 4: Ôn lại sau $interval4 $timeUnit (≈ $interval3 × ${initialEaseFactor})');
    print('Max: $maxInterval $timeUnit');
    print('─────────────────────────────────────────');
    print('');
  }
}
