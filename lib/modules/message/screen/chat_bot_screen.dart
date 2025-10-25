import 'package:card_mind/init.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/core/theme/app_colors.dart';
import 'package:card_mind/modules/message/provider/chat_notifier.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_html/flutter_html.dart';
import 'package:provider/provider.dart';

class ChatBotScreen extends StatefulWidget {
  const ChatBotScreen({super.key});
  static const String routeName = '/chatBotScreen';
  @override
  State<ChatBotScreen> createState() => _ChatBotScreenState();
}

class _ChatBotScreenState extends State<ChatBotScreen> {
  final TextEditingController _textController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _textController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return FunctionScreenTemplate(
      title: "Chat Bot",
      isShowDrawer: true,
      isShowBottomButton: false,
      backgroundColor: context.colors.primary,
      screen: Consumer<ChatNotifier>(
        builder: (context, notifier, child) {
          // Scroll to bottom khi có tin nhắn mới
          if (notifier.messages.isNotEmpty) {
            _scrollToBottom();
          }

          return Column(
            children: [
              Expanded(
                child:
                    notifier.messages.isEmpty && !notifier.isLoading
                        ? Center(
                          child: Text(
                            'Gửi tin nhắn để bắt đầu trò chuyện',
                            style: AppTextStyles.textContent2.copyWith(
                              color: Colors.white.withOpacity(0.6),
                            ),
                          ),
                        )
                        : ListView.separated(
                          controller: _scrollController,
                          padding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 12,
                          ),
                          itemCount:
                              notifier.messages.length +
                              (notifier.isLoading ? 1 : 0),
                          separatorBuilder:
                              (_, __) => const SizedBox(height: 12),
                          itemBuilder: (context, index) {
                            if (index == notifier.messages.length &&
                                notifier.isLoading) {
                              return _TypingIndicator();
                            }
                            final message = notifier.messages[index];
                            return _MessageCard(message: message);
                          },
                        ),
              ),
              // Hiển thị error message
              if (notifier.hasError && notifier.errorMessage != null)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: Text(
                    notifier.errorMessage!,
                    style: AppTextStyles.textContent3.copyWith(
                      color: Colors.red.shade300,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              const SizedBox(height: 4),
              _ChatInput(
                controller: _textController,
                isLoading: notifier.isLoading,
                onSend: () {
                  final text = _textController.text.trim();
                  if (text.isEmpty || notifier.isLoading) return;

                  notifier.sendMessage(message: text);
                  _textController.clear();
                },
              ),
              const SizedBox(height: 8),
            ],
          );
        },
      ),
    );
  }
}

class _TypingIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: AppColors.highlight.withOpacity(0.2),
          child: Icon(Icons.smart_toy, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.silverGray,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.coolGray.withOpacity(0.3)),
            ),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildDot(0),
                  const SizedBox(width: 4),
                  _buildDot(1),
                  const SizedBox(width: 4),
                  _buildDot(2),
                ],
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildDot(int index) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 400),
      width: 8,
      height: 8,
      decoration: BoxDecoration(
        color: AppColors.deepBlue.withOpacity(0.7),
        shape: BoxShape.circle,
      ),
    );
  }
}

class _MessageCard extends StatelessWidget {
  final ChatMessage message;
  const _MessageCard({required this.message});

  @override
  Widget build(BuildContext context) {
    final bool isUser = message.isUser;
    final bool isAiMessage = !isUser;

    if (isAiMessage) {
      return Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: AppColors.highlight.withOpacity(0.2),
            child: Icon(Icons.smart_toy, size: 18, color: Colors.white),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppColors.silverGray,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'AI Chat Bot',
                      style: AppTextStyles.textContent3.copyWith(
                        fontWeight: FontWeight.w700,
                        color: AppColors.deepBlue,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Html(
                      data: message.text,
                      style: {
                        'p': Style(
                          color: Colors.black87,
                          fontSize: FontSize(16),
                          lineHeight: LineHeight(1.4),
                        ),
                      },
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        _ActionIcon(
                          icon: Icons.copy_outlined,
                          label: 'Copy Text',
                          color: AppColors.deepBlue,
                          onTap: () {
                            Clipboard.setData(
                              ClipboardData(text: message.text),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text('Đã copy vào clipboard'),
                                duration: const Duration(seconds: 2),
                                backgroundColor: AppColors.deepBlue,
                              ),
                            );
                          },
                        ),
                        const SizedBox(width: 10),
                        _ActionIcon(
                          icon: Icons.thumb_up_alt_outlined,
                          color: AppColors.deepBlue,
                        ),
                        const SizedBox(width: 10),
                        _ActionIcon(
                          icon: Icons.thumb_down_alt_outlined,
                          color: AppColors.deepBlue,
                        ),
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

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        CircleAvatar(
          radius: 16,
          backgroundColor: Colors.white.withOpacity(0.2),
          child: Icon(Icons.person, size: 18, color: Colors.white),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.skyBlue,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Text(
                message.text,
                style: AppTextStyles.textContent2.copyWith(
                  color: Colors.white,
                  height: 1.4,
                ),
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
  final Color color;
  final VoidCallback? onTap;

  const _ActionIcon({
    required this.icon,
    this.label,
    this.color = Colors.white,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final content = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 18, color: color.withOpacity(0.8)),
        if (label != null) ...[
          const SizedBox(width: 6),
          Text(
            label!,
            style: AppTextStyles.textContent4.copyWith(
              color: color.withOpacity(0.8),
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ],
    );

    if (onTap != null) {
      return GestureDetector(onTap: onTap, child: content);
    }

    return content;
  }
}

class _ChatInput extends StatelessWidget {
  final TextEditingController controller;
  final VoidCallback onSend;
  final bool isLoading;

  const _ChatInput({
    required this.controller,
    required this.onSend,
    required this.isLoading,
  });

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
                      enabled: !isLoading,
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
                  // IconButton(
                  //   icon: Icon(
                  //     Icons.attachment,
                  //     color: Colors.white.withOpacity(0.8),
                  //   ),
                  //   onPressed: isLoading ? null : () {},
                  // ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 12),
          GestureDetector(
            onTap: isLoading ? null : onSend,
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color:
                    isLoading
                        ? AppColors.skyBlue.withOpacity(0.5)
                        : AppColors.skyBlue,
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.send_rounded,
                color: isLoading ? Colors.white.withOpacity(0.5) : Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
