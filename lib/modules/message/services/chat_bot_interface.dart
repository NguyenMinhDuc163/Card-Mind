import 'package:card_mind/modules/message/model/chat_response.dart';

abstract class IChatBotInterface {
  Future<ChatResponse> sendMessage({required String message});
}
