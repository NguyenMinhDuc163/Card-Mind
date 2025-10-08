import 'package:flutter/material.dart';
import '../../../data/models/course.dart';
import '../../../core/theme/theme_extensions.dart';

class CourseInfoWidget extends StatelessWidget {
  final Course course;

  const CourseInfoWidget({super.key, required this.course});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: context.colors.secondary,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Thông tin cơ bản về ${course.title}',
            style: const TextStyle(
              color: Colors.white,
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
                  color: Colors.blue,
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
                              return const Icon(
                                Icons.school,
                                color: Colors.white,
                                size: 18,
                              );
                            },
                          ),
                        )
                        : const Icon(
                          Icons.school,
                          color: Colors.white,
                          size: 18,
                        ),
              ),
              const SizedBox(width: 12),
              Text(
                course.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(width: 8),
              if (course.isVerified)
                const Icon(Icons.verified, color: Color(0xFF34C358), size: 16),
              const SizedBox(width: 16),
              Container(
                width: 1,
                height: 20,
                color: Colors.white.withOpacity(0.3),
              ),
              const SizedBox(width: 16),
              Text(
                '${course.totalTerms} thuật ngữ',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            course.description,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 14,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Icon(
                Icons.person,
                color: Colors.white.withOpacity(0.7),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                'Tác giả: ${course.author}',
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
              const Spacer(),
              Icon(
                Icons.category,
                color: Colors.white.withOpacity(0.7),
                size: 16,
              ),
              const SizedBox(width: 6),
              Text(
                course.category,
                style: TextStyle(
                  color: Colors.white.withOpacity(0.7),
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
