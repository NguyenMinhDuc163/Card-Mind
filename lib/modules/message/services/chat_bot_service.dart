import 'package:card_mind/core/constants/api_path.dart';
import 'package:card_mind/data/api_client.dart';
import 'package:card_mind/data/models/request_method.dart';
import 'package:card_mind/modules/message/model/chat_response.dart';
import 'package:card_mind/modules/message/services/chat_bot_interface.dart';

class ChatBotService implements IChatBotInterface {
  ApiClient apiClient = ApiClient();

  @override
  Future<ChatResponse> sendMessage({required String message}) async {
    final body = {"message": message};
    final res = await apiClient.fetch(
      ApiPath.chatBot,
      RequestMethod.post,
      rawData: body,
    );

    
    dynamic jsonData;
    if (res.data is Map<String, dynamic>) {
      jsonData = res.data;
    } else if (res.data is Map) {
      jsonData = Map<String, dynamic>.from(res.data);
    } else {
      jsonData = res.data;
    }

    ChatResponse chatResponse = ChatResponse.fromJson(jsonData);

    return chatResponse;
  }
}
