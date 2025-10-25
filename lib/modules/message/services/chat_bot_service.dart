import 'package:card_mind/core/constants/api_path.dart';
import 'package:card_mind/data/api_client.dart';
import 'package:card_mind/data/models/request_method.dart';
import 'package:card_mind/modules/message/services/chat_bot_interface.dart';

class ChatBotService implements IChatBotInterface {
  ApiClient apiClient = ApiClient();

  @override
  Future<void> sendMessage({required String message}) async {
    final body = {"message": message};
    apiClient.fetch(ApiPath.chatBot, RequestMethod.post, rawData: body);
  }
}
