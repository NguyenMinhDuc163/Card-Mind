import 'package:flutter/material.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';

enum LearningMode { flashcards, learn, test, match, blast, gravity, delete }

class LearningOptionsWidget extends StatelessWidget {
  final Function(LearningMode)? onOptionTap;

  const LearningOptionsWidget({super.key, this.onOptionTap});

  @override
  Widget build(BuildContext context) {
    final options = [
      LearningOption(
        mode: LearningMode.flashcards,
        title: 'Thẻ ghi nhớ',
        icon: Icons.style,
        description: 'Học từ vựng với thẻ flashcard',
      ),
      LearningOption(
        mode: LearningMode.learn,
        title: 'Sửa',
        icon: Icons.autorenew,
        description: 'Học từ vựng theo phương pháp thích ứng',
      ),
      LearningOption(
        mode: LearningMode.test,
        title: 'Kiểm tra',
        icon: Icons.quiz,
        description: 'Kiểm tra kiến thức với các câu hỏi',
      ),
      LearningOption(
        mode: LearningMode.delete,
        title: 'Xóa học phần',
        icon: Icons.delete_outline,
        description: 'Xóa học phần này khỏi thư viện',
        isDestructive: true,
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Chế độ học tập',
            style: TextStyle(
              color: context.brandColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...options
              .map((option) => _buildOptionItem(context, option))
              .toList(),
        ],
      ),
    );
  }

  Widget _buildOptionItem(BuildContext context, LearningOption option) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color:
            option.isDestructive
                ? context.brandColors.buttonDestructive.withOpacity(0.2)
                : context.brandColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border:
            option.isDestructive
                ? Border.all(
                  color: context.brandColors.buttonDestructive.withOpacity(0.3),
                  width: 1,
                )
                : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onOptionTap?.call(option.mode),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color:
                        option.isDestructive
                            ? context.brandColors.buttonDestructive.withOpacity(
                              0.2,
                            )
                            : context.brandColors.avatarBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    option.icon,
                    color:
                        option.isDestructive
                            ? context.brandColors.buttonDestructive
                            : context.brandColors.textPrimary,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style: TextStyle(
                          color:
                              option.isDestructive
                                  ? context.brandColors.buttonDestructive
                                  : context.brandColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option.description,
                        style: TextStyle(
                          color:
                              option.isDestructive
                                  ? context.brandColors.buttonDestructive
                                      .withOpacity(0.7)
                                  : context.brandColors.textSecondary,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  option.isDestructive
                      ? Icons.delete_forever
                      : Icons.arrow_forward_ios,
                  color:
                      option.isDestructive
                          ? context.brandColors.buttonDestructive
                          : context.brandColors.textMuted,
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LearningOption {
  final LearningMode mode;
  final String title;
  final IconData icon;
  final String description;
  final bool isDestructive;

  const LearningOption({
    required this.mode,
    required this.title,
    required this.icon,
    required this.description,
    this.isDestructive = false,
  });
}
