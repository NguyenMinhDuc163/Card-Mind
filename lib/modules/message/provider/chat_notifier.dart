import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/init.dart';
import 'package:card_mind/modules/message/services/chat_bot_service.dart';
import 'package:card_mind/modules/message/model/chat_response.dart';
import 'package:easy_localization/easy_localization.dart';

class ChatMessage {
  final bool isUser;
  final String text;

  ChatMessage({required this.isUser, required this.text});
}

/// Quota keys stored in Hive via LocalStorageHelper.
class _ChatQuotaKeys {
  _ChatQuotaKeys._();
  static const String chatDate = 'chat_quota_date';
  static const String chatCount = 'chat_quota_count';
  static const String rewardedCount = 'chat_rewarded_count';
}

class ChatNotifier extends ChangeNotifier {
  ChatBotService chatBotService = ChatBotService();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;

  // ── Quota config ──
  static const int _freeQuota = 5;
  static const int _bonusPerAd = 3;
  static const int _maxAdWatches = 3;

  int _todayChatCount = 0;
  int _todayRewardedCount = 0;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  /// Total turns used today (free + bonus).
  int get todayChatCount => _todayChatCount;

  /// How many rewarded ads the user has watched today.
  int get todayRewardedCount => _todayRewardedCount;

  /// Turns remaining today.
  int get remainingTurns {
    final totalQuota = _freeQuota + (_todayRewardedCount * _bonusPerAd);
    return (totalQuota - _todayChatCount).clamp(0, totalQuota);
  }

  /// Whether the user can send a message today.
  bool get canSend => remainingTurns > 0;

  /// Whether the user can still watch a rewarded ad for more turns.
  bool get canWatchRewardedAd => _todayRewardedCount < _maxAdWatches;

  ChatNotifier() {
    _loadQuota();
  }

  // ── Quota helpers ──

  String _todayKey() {
    final now = DateTime.now();
    return '${now.year}-${now.month}-${now.day}';
  }

  void _loadQuota() {
    final storedDate = LocalStorageHelper.getValue(_ChatQuotaKeys.chatDate) as String?;
    final today = _todayKey();

    if (storedDate == today) {
      _todayChatCount = LocalStorageHelper.getValue(_ChatQuotaKeys.chatCount) as int? ?? 0;
      _todayRewardedCount = LocalStorageHelper.getValue(_ChatQuotaKeys.rewardedCount) as int? ?? 0;
    } else {
      // New day — reset counters
      _todayChatCount = 0;
      _todayRewardedCount = 0;
      LocalStorageHelper.setValue(_ChatQuotaKeys.chatDate, today);
      LocalStorageHelper.setValue(_ChatQuotaKeys.chatCount, 0);
      LocalStorageHelper.setValue(_ChatQuotaKeys.rewardedCount, 0);
    }
  }

  void _saveQuota() {
    LocalStorageHelper.setValue(_ChatQuotaKeys.chatDate, _todayKey());
    LocalStorageHelper.setValue(_ChatQuotaKeys.chatCount, _todayChatCount);
    LocalStorageHelper.setValue(_ChatQuotaKeys.rewardedCount, _todayRewardedCount);
  }

  /// Call after a successful rewarded ad to grant bonus turns.
  void addRewardedBonus() {
    if (_todayRewardedCount < _maxAdWatches) {
      _todayRewardedCount++;
      _saveQuota();
      notifyListeners();
    }
  }

  Future<void> sendMessage({required String message}) async {
    if (message.trim().isEmpty) return;

    // Check quota before sending
    if (!canSend) return;

    _messages.add(ChatMessage(isUser: true, text: message));
    _todayChatCount++;
    _saveQuota();
    _errorMessage = null;
    _isLoading = true;
    notifyListeners();

    try {
      final ChatResponse response = await chatBotService.sendMessage(
        message: message,
      );

      final String? answer = response.data?.answer;

      if (answer != null && answer.isNotEmpty) {
        _messages.add(ChatMessage(isUser: false, text: answer));
        _errorMessage = null;
      } else {
        _errorMessage = tr('message.chat_bot.error.no_response');
      }
    } catch (e) {
      if (e.toString().contains('connection error') ||
          e.toString().contains('Failed host lookup')) {
        _errorMessage = tr('message.chat_bot.error.network');
      } else if (e.toString().contains('timeout')) {
        _errorMessage = tr('message.chat_bot.error.timeout');
      } else {
        _errorMessage = tr('message.chat_bot.error.generic');
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
