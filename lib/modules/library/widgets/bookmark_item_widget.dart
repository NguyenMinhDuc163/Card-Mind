import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/init.dart';
import 'package:flutter/material.dart';

class BookmarkItemWidget extends StatelessWidget {
  const BookmarkItemWidget({
    super.key,
    required this.courseData,
    required this.onTap,
    this.isBookmarked = false,
  });

  final Map<String, dynamic> courseData;
  final VoidCallback onTap;
  final bool isBookmarked;

  @override
  Widget build(BuildContext context) {
    final courseTitle =
        courseData['courseTitle'] as String? ?? 'Không có tiêu đề';
    final courseDescription = courseData['courseDescription'] as String? ?? '';
    final courseCategory = courseData['courseCategory'] as String?;
    final courseTopic = courseData['courseTopic'] as String?;
    final unlearnedCount = courseData['unlearnedCount'] as int?;
    final bookmarkedCount = courseData['bookmarkedCount'] as int?;
    final lastUpdated = courseData['lastUpdated'] as String? ?? '';

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: context.colors.secondary,
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
                          color: Colors.white,
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
                            color: Colors.white,
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
                    color: (isBookmarked
                            ? AppColors.highlight
                            : context.colors.error)
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (isBookmarked
                              ? AppColors.highlight
                              : context.colors.error)
                          .withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isBookmarked) ...[
                        Icon(
                          Icons.bookmark,
                          size: 14,
                          color: AppColors.highlight,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        isBookmarked
                            ? '$bookmarkedCount thẻ đã đánh dấu'
                            : '$unlearnedCount thẻ',
                        style: AppTextStyles.textContent3.copyWith(
                          color:
                              isBookmarked
                                  ? AppColors.highlight
                                  : context.colors.error,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
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
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  courseCategory ?? courseTopic ?? 'Không có',
                  style: AppTextStyles.textContent3.copyWith(
                    color: Colors.white.withOpacity(0.7),
                  ),
                ),
                const Spacer(),
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: Colors.white.withOpacity(0.7),
                ),
                const SizedBox(width: 4),
                Text(
                  _formatDate(lastUpdated),
                  style: AppTextStyles.textContent3.copyWith(
                    color: Colors.white.withOpacity(0.7),
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
