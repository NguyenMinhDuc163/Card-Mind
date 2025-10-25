import 'package:card_mind/init.dart';
import 'package:card_mind/modules/message/services/chat_bot_service.dart';

class ChatNotifier extends ChangeNotifier {
  ChatBotService chatBotService = ChatBotService();
  void sendMessage({required String message}) {
    chatBotService.sendMessage(message: message);
  }
}