import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/init.dart';
import 'package:card_mind/modules/library/model/content_data.dart';
import 'package:card_mind/modules/course/screen/course_info_screen.dart';
import 'package:flutter/material.dart';

class ClassContentItemWidget extends StatelessWidget {
  const ClassContentItemWidget({
    super.key,
    required this.content,
    this.onRemove,
    this.isPendingRemoval = false,
    this.onToggleRemoval,
  });

  final ContentData content;
  final VoidCallback? onRemove;
  final bool isPendingRemoval;
  final VoidCallback? onToggleRemoval;

  void _navigateToCourseInfo(BuildContext context) {
    Navigator.pushNamed(
      context,
      CourseInfoScreen.routeName,
      arguments: content.id,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color:
            isPendingRemoval
                ? Colors.red.withOpacity(0.1)
                : context.colors.onPrimary.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              isPendingRemoval
                  ? Colors.red.withOpacity(0.5)
                  : context.colors.onPrimary.withOpacity(0.2),
          width: isPendingRemoval ? 2 : 1,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _navigateToCourseInfo(context),
          borderRadius: BorderRadius.circular(12),
          child: Padding(
            padding: AppPad.h16v12,
            child: Row(
              children: [
                Container(
                  width: 40,
                  height: 40,
                  decoration: BoxDecoration(
                    color: context.colors.onPrimary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.credit_card,
                    color: context.colors.onPrimary,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content.title,
                        style: AppTextStyles.textContent2.copyWith(
                          color: context.colors.onPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '${content.totalTerms} thuật ngữ • ${content.author}',
                        style: AppTextStyles.textContent3.copyWith(
                          color: context.colors.onPrimary.withOpacity(0.7),
                        ),
                      ),
                    ],
                  ),
                ),
                if (onToggleRemoval != null)
                  IconButton(
                    onPressed: onToggleRemoval,
                    icon: Icon(
                      isPendingRemoval
                          ? Icons.undo
                          : Icons.remove_circle_outline,
                      color:
                          isPendingRemoval
                              ? Colors.orange
                              : Colors.red.withOpacity(0.7),
                      size: 20,
                    ),
                    tooltip: isPendingRemoval ? 'Hủy xóa' : 'Đánh dấu xóa',
                  ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: context.colors.onPrimary.withOpacity(0.4),
                  size: 14,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
