import 'package:card_mind/init.dart';
import 'package:card_mind/modules/message/services/chat_bot_service.dart';
import 'package:card_mind/modules/message/model/chat_response.dart';
import 'package:easy_localization/easy_localization.dart';

class ChatMessage {
  final bool isUser;
  final String text;

  ChatMessage({required this.isUser, required this.text});
}

class ChatNotifier extends ChangeNotifier {
  ChatBotService chatBotService = ChatBotService();

  List<ChatMessage> _messages = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ChatMessage> get messages => _messages;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get hasError => _errorMessage != null;

  Future<void> sendMessage({required String message}) async {
    if (message.trim().isEmpty) return;

    
    _messages.add(ChatMessage(isUser: true, text: message));
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
