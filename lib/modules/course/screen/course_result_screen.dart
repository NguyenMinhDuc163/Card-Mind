import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/core/widgets/app_gap.dart';
import 'package:card_mind/init.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:flutter/material.dart';
import 'package:card_mind/core/theme/app_colors.dart';
import 'package:card_mind/core/theme/app_pad.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../provider/course_result_notifier.dart';

class CourseResultScreen extends StatefulWidget {
  static const String routeName = '/course-result';

  const CourseResultScreen({super.key});

  @override
  State<CourseResultScreen> createState() => _CourseResultScreenState();
}

class _CourseResultScreenState extends State<CourseResultScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final notifier = Provider.of<CourseResultNotifier>(context, listen: false);
    final courseId = ModalRoute.of(context)?.settings.arguments as String?;
    await notifier.initializeData(courseId: courseId);
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CourseResultNotifier>(
      builder: (context, notifier, child) {
        if (notifier.isLoading) {
          return FunctionScreenTemplate(
            isShowAppBar: false,
            backgroundColor: context.colors.primary,
            screen: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        if (notifier.hasError) {
          return FunctionScreenTemplate(
            isShowAppBar: false,
            backgroundColor: context.colors.primary,
            screen: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.error, color: Colors.white70, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    notifier.errorMessage ?? 'Có lỗi xảy ra',
                    style: const TextStyle(color: Colors.white70),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _initializeData(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        return FunctionScreenTemplate(
          isShowAppBar: false,
          backgroundColor: context.colors.primary,
          screen: SingleChildScrollView(
            child: Column(
              children: [
                _buildHeader(notifier),
                _buildCongratulationSection(notifier),
                _buildProgressSection(notifier),
                AppGap.h80,
                _buildActionButtons(notifier),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader(CourseResultNotifier notifier) {
    return Container(
      padding: AppPad.h16v20,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              padding: AppPad.a8,
              child: const Icon(Icons.close, color: AppColors.white, size: 24),
            ),
          ),
          Text(
            '${notifier.learnedCount}/${notifier.totalCards}',
            style: const TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCongratulationSection(CourseResultNotifier notifier) {
    return Padding(
      padding: AppPad.h16v20,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  notifier.congratulationMessage,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notifier.descriptionMessage,
                  style: const TextStyle(
                    color: AppColors.white,
                    fontSize: 14,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            flex: 1,
            child: SizedBox(
              width: 80,
              height: 80,
              child: SvgPicture.asset(IconPath.iconWow, fit: BoxFit.contain),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressSection(CourseResultNotifier notifier) {
    return Padding(
      padding: AppPad.h16v20,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tiến độ của bạn',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildProgressCircle(notifier),
              const SizedBox(width: 20),
              Expanded(child: _buildProgressLegend(notifier)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle(CourseResultNotifier notifier) {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.lightOrange, width: 12),
            ),
          ),

          SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: ProgressPainter(
                progress: notifier.progressPercentage,
                progressColor: AppColors.tealGreen,
                backgroundColor: Colors.transparent,
                strokeWidth: 12,
              ),
            ),
          ),

          Center(
            child: Text(
              '${(notifier.progressPercentage * 100).toInt()}%',
              style: const TextStyle(
                color: AppColors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLegend(CourseResultNotifier notifier) {
    return Column(
      children: [
        _buildLegendItem('Biết', AppColors.tealGreen, notifier.knownCount),
        const SizedBox(height: 8),
        _buildLegendItem(
          'Đang học',
          AppColors.lightOrange,
          notifier.learningCount,
        ),
        const SizedBox(height: 8),
        _buildLegendItem('Còn lại', AppColors.gray, notifier.remainingCount),
      ],
    );
  }

  Widget _buildLegendItem(String label, Color color, int count) {
    return Container(
      padding: AppPad.h12v8,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: AppColors.black50,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            count.toString(),
            style: const TextStyle(
              color: AppColors.black50,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons(CourseResultNotifier notifier) {
    return Padding(
      padding: AppPad.h16v20,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              width: double.infinity,
              padding: AppPad.v20,
              decoration: BoxDecoration(
                color: AppColors.vibrantBlue,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(
                    Icons.credit_card,
                    color: AppColors.white,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Tiếp tục ôn thuật ngữ',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              _resetLearningProgress(notifier);
            },
            child: Container(
              width: double.infinity,
              padding: AppPad.v20,
              decoration: BoxDecoration(
                color: context.colors.secondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Center(
                child: Text(
                  'Đặt lại thẻ nhớ',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
          GestureDetector(
            onTap: () {
              _showLearningHistory(notifier);
            },
            child: Container(
              width: double.infinity,
              padding: AppPad.v20,
              decoration: BoxDecoration(
                color: AppColors.lightOrange,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.history, color: AppColors.white, size: 20),
                  const SizedBox(width: 8),
                  const Text(
                    'Xem lịch sử học tập',
                    style: TextStyle(
                      color: AppColors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _resetLearningProgress(CourseResultNotifier notifier) {
    LocalStorageHelper.deleteValue('learned_cards_${notifier.courseData?.id}');

    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('Đã đặt lại tiến độ học tập')));

    Navigator.pop(context);
  }

  void _showLearningHistory(CourseResultNotifier notifier) {
    showModalBottomSheet(
      context: context,
      backgroundColor: context.colors.primary,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => _buildHistoryBottomSheet(notifier),
    );
  }

  Widget _buildHistoryBottomSheet(CourseResultNotifier notifier) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),

          Text(
            'Lịch sử học tập',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            notifier.course?.title ?? 'Khóa học',
            style: TextStyle(
              color: AppColors.white.withOpacity(0.8),
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),

          _buildHistoryItems(notifier),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.lightOrange,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text(
                'Đóng',
                style: TextStyle(
                  color: AppColors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryItems(CourseResultNotifier notifier) {
    final allResults =
        LocalStorageHelper.getValue('all_learning_results') as List<dynamic>? ??
        [];
    final courseResults = <Map<String, dynamic>>[];

    for (final resultKey in allResults) {
      if (resultKey.toString().contains(
        'learning_result_${notifier.courseData?.id}_',
      )) {
        final resultData = LocalStorageHelper.getValue(resultKey.toString());
        if (resultData != null) {
          final Map<String, dynamic> result = Map<String, dynamic>.from(
            resultData as Map<dynamic, dynamic>,
          );
          courseResults.add(result);
        }
      }
    }

    courseResults.sort((a, b) {
      final dateA = DateTime.parse(a['completedAt'] as String);
      final dateB = DateTime.parse(b['completedAt'] as String);
      return dateB.compareTo(dateA);
    });

    if (courseResults.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.history,
              color: AppColors.white.withOpacity(0.5),
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'Chưa có lịch sử học tập',
              style: TextStyle(
                color: AppColors.white.withOpacity(0.7),
                fontSize: 16,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      constraints: const BoxConstraints(maxHeight: 300),
      child: ListView.builder(
        shrinkWrap: true,
        itemCount: courseResults.length,
        itemBuilder: (context, index) {
          final result = courseResults[index];
          final completedAt = DateTime.parse(result['completedAt'] as String);
          final learnedCount = result['learnedCount'] as int;
          final totalCards = result['totalCards'] as int;
          final progressPercentage =
              (result['progressPercentage'] as double) * 100;

          return Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: Colors.white.withOpacity(0.2),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: AppColors.lightOrange.withOpacity(0.2),
                    border: Border.all(color: AppColors.lightOrange, width: 2),
                  ),
                  child: Center(
                    child: Text(
                      '${progressPercentage.toInt()}%',
                      style: const TextStyle(
                        color: AppColors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '${learnedCount}/${totalCards} thẻ đã học',
                        style: const TextStyle(
                          color: AppColors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTime(completedAt),
                        style: TextStyle(
                          color: AppColors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),

                Icon(
                  progressPercentage >= 100
                      ? Icons.check_circle
                      : Icons.schedule,
                  color:
                      progressPercentage >= 100
                          ? AppColors.tealGreen
                          : AppColors.lightOrange,
                  size: 24,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 0) {
      return '${difference.inDays} ngày trước';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} giờ trước';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} phút trước';
    } else {
      return 'Vừa xong';
    }
  }
}

class ProgressPainter extends CustomPainter {
  final double progress;
  final Color progressColor;
  final Color backgroundColor;
  final double strokeWidth;

  ProgressPainter({
    required this.progress,
    required this.progressColor,
    required this.backgroundColor,
    required this.strokeWidth,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = (size.width - strokeWidth) / 2;

    if (backgroundColor != Colors.transparent) {
      final backgroundPaint =
          Paint()
            ..color = backgroundColor
            ..strokeWidth = strokeWidth
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;

      canvas.drawCircle(center, radius, backgroundPaint);
    }

    final progressPaint =
        Paint()
          ..color = progressColor
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final startAngle = -1.5708;
    final sweepAngle = 2 * 3.14159 * progress;

    canvas.drawArc(
      Rect.fromCircle(center: center, radius: radius),
      startAngle,
      sweepAngle,
      false,
      progressPaint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) {
    return oldDelegate != this;
  }
}
