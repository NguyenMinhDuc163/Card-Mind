import 'package:card_mind/init.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/core/theme/app_colors.dart';
import 'package:card_mind/modules/message/screen/chat_history_screen.dart';
import 'package:flutter_svg/flutter_svg.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});
  static const String routeName = '/chatBotScreen';
  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _textController = TextEditingController();

  final List<_ChatMessage> _messages = [
    _ChatMessage(isUser: true, text: 'What is AI chat bot ?'),
    _ChatMessage(
      isUser: false,
      text:
          'An AI chatbot is a computer program designed to simulate human conversation through text or voice interactions. What sets it apart from traditional chatbots is its ability to understand and respond to user input in a natural, human-like way.',
    ),
    _ChatMessage(isUser: true, text: 'How Does it Work?'),
    _ChatMessage(
      isUser: false,
      text:
          'User Input:\nYou type or speak a message.\nProcessing:\nThe chatbot\'s AI analyzes your message to understand its meaning.',
    ),
  ];

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FunctionScreenTemplate(
      title: "Chat Bot",
      isShowDrawer: true,
      isShowBottomButton: false,
      backgroundColor: context.colors.primary,
      // actionsWidget: [
      //   InkWell(
      //     onTap:
      //         () => Navigator.pushNamed(context, ChatHistoryScreen.routeName),
      //     child: SvgPicture.asset(IconPath.iconHistory),
      //   ),
      // ],
      screen: Column(
        children: [
          Expanded(
            child: ListView.separated(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              itemCount: _messages.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final message = _messages[index];
                return _MessageCard(message: message);
              },
            ),
          ),
          const SizedBox(height: 4),
          _ChatInput(
            controller: _textController,
            onSend: () {
              final text = _textController.text.trim();
              if (text.isEmpty) return;
              setState(() {
                _messages.add(_ChatMessage(isUser: true, text: text));
              });
              _textController.clear();
            },
          ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}

class _ChatMessage {
  final bool isUser;
  final String text;
  _ChatMessage({required this.isUser, required this.text});
}

class _MessageCard extends StatelessWidget {
  final _ChatMessage message;
  const _MessageCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.isUser;
    final Color borderColor = AppColors.coolGray.withOpacity(0.3);
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor:
              isUser
                  ? Colors.white.withOpacity(0.2)
                  : AppColors.highlight.withOpacity(0.2),
          child: Icon(
            isUser ? Icons.person : Icons.smart_toy,
            size: 18,
            color: Colors.white,
          ),
        ),
        const SizedBox(width: 10),

        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.deepBlue,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: borderColor),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isUser)
                    Text(
                      'User Input:',
                      style: AppTextStyles.textContent2.copyWith(
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                  if (!isUser) const SizedBox(height: 2),
                  Text(
                    message.text,
                    style: AppTextStyles.textContent2.copyWith(
                      color: Colors.white,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    children: const [
                      _ActionIcon(
                        icon: Icons.copy_outlined,
                        label: 'Copy Text',
                      ),
                      SizedBox(width: 10),
                      _ActionIcon(icon: Icons.thumb_up_alt_outlined),
                      SizedBox(width: 10),
                      _ActionIcon(icon: Icons.thumb_down_alt_outlined),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _ActionIcon extends StatelessWidget {
  final IconData icon;
  final String? label;
  const _ActionIcon({required this.icon, this.label});

  @override
  Widget build(BuildContext context) {
    final Color color = Colors.white.withOpacity(0.8);
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color),
        if (label != null) ...[
          const SizedBox(width: 6),
          Text(
            label!,
            style: AppTextStyles.textContent4.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  const _ChatInput({required this.controller, required this.onSend});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.deepBlue,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.white.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  const SizedBox(width: 12),
                  Icon(Icons.search, color: Colors.white.withOpacity(0.8)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: TextField(
                      controller: controller,
                      decoration: InputDecoration(
                        hintText: 'Ask ai chat anything',
                        hintStyle: AppTextStyles.textContent3.copyWith(
                          color: Colors.white.withOpacity(0.6),
                        ),
                        border: InputBorder.none,
                      ),
                      style: AppTextStyles.textContent2.copyWith(
                        color: Colors.white,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(
                      Icons.attachment,
                      color: Colors.white.withOpacity(0.8),
                    ),
                    onPressed: () {},
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: onSend,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.highlight,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.send_rounded, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
