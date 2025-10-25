import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/init.dart';
import 'package:flutter/material.dart';

class BookmarkItemWidget extends StatelessWidget {
  const BookmarkItemWidget({
    super.key,
    required this.courseData,
    required this.onTap,
  });

  final Map<String, dynamic> courseData;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final courseTitle = courseData['courseTitle'] as String;
    final courseDescription = courseData['courseDescription'] as String;
    final courseCategory = courseData['courseCategory'] as String;
    final unlearnedCount = courseData['unlearnedCount'] as int;
    final lastUpdated = courseData['lastUpdated'] as String;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.surface,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.colors.outline.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        courseTitle,
                        style: AppTextStyles.textContent1.copyWith(
                          color: context.colors.onSurface,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      if (courseDescription.isNotEmpty)
                        Text(
                          courseDescription,
                          style: AppTextStyles.textContent3.copyWith(
                            color: context.colors.onSurface.withOpacity(0.7),
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: context.colors.error.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.colors.error.withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Text(
                    '$unlearnedCount thẻ',
                    style: AppTextStyles.textContent3.copyWith(
                      color: context.colors.error,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Icon(
                  Icons.category,
                  size: 16,
                  color: context.colors.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  courseCategory,
                  style: AppTextStyles.textContent3.copyWith(
                    color: context.colors.onSurface.withOpacity(0.6),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: context.colors.onSurface.withOpacity(0.6),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(lastUpdated),
                  style: AppTextStyles.textContent3.copyWith(
                    color: context.colors.onSurface.withOpacity(0.6),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatDate(String dateString) {
    try {
      final date = DateTime.parse(dateString);
      final now = DateTime.now();
      final difference = now.difference(date);

      if (difference.inDays > 0) {
        return '${difference.inDays} ngày trước';
      } else if (difference.inHours > 0) {
        return '${difference.inHours} giờ trước';
      } else if (difference.inMinutes > 0) {
        return '${difference.inMinutes} phút trước';
      } else {
        return 'Vừa xong';
      }
    } catch (e) {
      return 'Không xác định';
    }
  }
}
