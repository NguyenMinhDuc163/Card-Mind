import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../../data/models/course.dart';
import '../../../core/theme/theme_extensions.dart';

class CourseInfoWidget extends StatelessWidget {
  final Course course;
  final int? reviewCardsCount;

  const CourseInfoWidget({
    super.key,
    required this.course,
    this.reviewCardsCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.brandColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'course_info.basic_info'.tr(args: [course.title]),
            style: TextStyle(
              color: context.brandColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: context.brandColors.buttonPrimary,
                  borderRadius: BorderRadius.circular(8),
                ),
                child:
                    course.iconUrl != null
                        ? ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: Image.network(
                            course.iconUrl!,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Icon(
                                Icons.school,
                                color: context.brandColors.textPrimary,
                                size: 18,
                              );
                            },
                          ),
                        )
                        : Icon(
                          Icons.school,
                          color: context.brandColors.textPrimary,
                          size: 18,
                        ),
              ),
              const SizedBox(width: 12),
              Text(
                course.title,
                style: TextStyle(
                  color: context.brandColors.textPrimary,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              if (course.isVerified)
                Icon(
                  Icons.verified,
                  color: context.brandColors.progressValue,
                  size: 16,
                ),
              const SizedBox(width: 16),
              Container(
                width: 1,
                height: 20,
                color: context.brandColors.textMuted,
              ),
              const SizedBox(width: 16),
              Text(
                'course_info.terms'.tr(args: [course.totalTerms.toString()]),
                style: TextStyle(
                  color: context.brandColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            course.description,
            style: TextStyle(
              color: context.brandColors.textSecondary,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.person,
                color: context.brandColors.textMuted,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'course_info.author_label'.tr(args: [course.author]),
                style: TextStyle(
                  color: context.brandColors.textMuted,
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.category,
                color: context.brandColors.textMuted,
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                course.category,
                style: TextStyle(
                  color: context.brandColors.textMuted,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          if (reviewCardsCount != null && reviewCardsCount! > 0) ...[
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: context.brandColors.progressValue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.brandColors.progressValue.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.schedule,
                    color: context.brandColors.progressValue,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'course_info.review_cards'.tr(
                      args: [reviewCardsCount.toString()],
                    ),
                    style: TextStyle(
                      color: context.brandColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}
