abstract class IChatBotInterface{
  Future<void> sendMessage({required String message});
}