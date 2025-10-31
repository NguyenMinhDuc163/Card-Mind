import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';

enum LearningMode {
  flashcards,
  review,
  learn,
  test,
  match,
  blast,
  gravity,
  delete,
}

class LearningOptionsWidget extends StatelessWidget {
  final Function(LearningMode)? onOptionTap;
  final int reviewCardsCount;

  const LearningOptionsWidget({
    super.key,
    this.onOptionTap,
    this.reviewCardsCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    final options = [
      if (reviewCardsCount > 0)
        LearningOption(
          mode: LearningMode.review,
          title: 'course_info.mode_review'.tr(
            args: [reviewCardsCount.toString()],
          ),
          icon: Icons.schedule,
          description: 'course_info.mode_review_desc'.tr(),
          isHighlighted: true,
        ),
      LearningOption(
        mode: LearningMode.flashcards,
        title: 'course_info.mode_flashcards'.tr(),
        icon: Icons.style,
        description: 'course_info.mode_flashcards_desc'.tr(),
      ),
      LearningOption(
        mode: LearningMode.learn,
        title: 'course_info.mode_edit'.tr(),
        icon: Icons.autorenew,
        description: 'course_info.mode_edit_desc'.tr(),
      ),
      LearningOption(
        mode: LearningMode.test,
        title: 'course_info.mode_test'.tr(),
        icon: Icons.quiz,
        description: 'course_info.mode_test_desc'.tr(),
      ),
      LearningOption(
        mode: LearningMode.delete,
        title: 'course_info.mode_delete'.tr(),
        icon: Icons.delete_outline,
        description: 'course_info.mode_delete_desc'.tr(),
        isDestructive: true,
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'course_info.learning_modes'.tr(),
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
                : option.isHighlighted
                ? context.brandColors.progressValue.withOpacity(0.1)
                : context.brandColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border:
            option.isDestructive
                ? Border.all(
                  color: context.brandColors.buttonDestructive.withOpacity(0.3),
                  width: 1,
                )
                : option.isHighlighted
                ? Border.all(
                  color: context.brandColors.progressValue.withOpacity(0.5),
                  width: 2,
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
                            : option.isHighlighted
                            ? context.brandColors.progressValue
                            : context.brandColors.avatarBackground,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    option.icon,
                    color:
                        option.isDestructive
                            ? context.brandColors.buttonDestructive
                            : option.isHighlighted
                            ? Colors.white
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
                                  : option.isHighlighted
                                  ? context.brandColors.progressValue
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
  final bool isHighlighted;

  const LearningOption({
    required this.mode,
    required this.title,
    required this.icon,
    required this.description,
    this.isDestructive = false,
    this.isHighlighted = false,
  });
}
