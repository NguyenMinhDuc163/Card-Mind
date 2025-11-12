import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/init.dart';
import 'package:easy_localization/easy_localization.dart';
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
        courseData['courseTitle'] as String? ??
        'library.bookmark.no_title'.tr();
    final courseDescription = courseData['courseDescription'] as String? ?? '';
    final courseCategory = courseData['courseCategory'] as String?;
    final courseTopic = courseData['courseTopic'] as String?;
    final unlearnedCount = courseData['unlearnedCount'] as int?;
    final bookmarkedCount = courseData['bookmarkedCount'] as int?;
    final reviewCount = courseData['reviewCount'] as int?;
    final lastUpdated = courseData['lastUpdated'] as String? ?? '';

    
    final isReview = reviewCount != null && reviewCount > 0;

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
                    color: (isReview
                            ? context.brandColors.progressValue
                            : (isBookmarked
                                ? AppColors.highlight
                                : context.colors.error))
                        .withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: (isReview
                              ? context.brandColors.progressValue
                              : (isBookmarked
                                  ? AppColors.highlight
                                  : context.colors.error))
                          .withOpacity(0.3),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isReview) ...[
                        Icon(
                          Icons.schedule,
                          size: 14,
                          color: context.brandColors.progressValue,
                        ),
                        const SizedBox(width: 4),
                      ] else if (isBookmarked) ...[
                        Icon(
                          Icons.bookmark,
                          size: 14,
                          color: AppColors.highlight,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        isReview
                            ? 'library.bookmark.review_badge'.tr(
                              args: [reviewCount.toString()],
                            )
                            : (isBookmarked
                                ? 'library.bookmark.bookmarked_badge'.tr(
                                  args: [bookmarkedCount.toString()],
                                )
                                : 'library.bookmark.unlearned_badge'.tr(
                                  args: [unlearnedCount.toString()],
                                )),
                        style: AppTextStyles.textContent3.copyWith(
                          color:
                              isReview
                                  ? context.brandColors.progressValue
                                  : (isBookmarked
                                      ? AppColors.highlight
                                      : context.colors.error),
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
                  courseCategory ??
                      courseTopic ??
                      'library.bookmark.no_category'.tr(),
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
        return 'common.time_ago.days'.tr(args: [difference.inDays.toString()]);
      } else if (difference.inHours > 0) {
        return 'common.time_ago.hours'.tr(
          args: [difference.inHours.toString()],
        );
      } else if (difference.inMinutes > 0) {
        return 'common.time_ago.minutes'.tr(
          args: [difference.inMinutes.toString()],
        );
      } else {
        return 'common.time_ago.just_now'.tr();
      }
    } catch (e) {
      return 'library.bookmark.time_unknown'.tr();
    }
  }
}
