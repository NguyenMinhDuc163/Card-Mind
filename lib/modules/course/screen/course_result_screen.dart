import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/core/widgets/app_gap.dart';
import 'package:card_mind/init.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/modules/dashboard/screen/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:card_mind/core/theme/app_pad.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
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
            screen: Center(
              child: CircularProgressIndicator(
                color: context.brandColors.textPrimary,
              ),
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
                  Icon(
                    Icons.error,
                    color: context.brandColors.textSecondary,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    notifier.errorMessage ?? 'course_info.error_occurred'.tr(),
                    style: TextStyle(color: context.brandColors.textSecondary),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _initializeData(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: context.brandColors.buttonPrimary,
                      foregroundColor: Colors.white,
                    ),
                    child: Text('course_info.retry'.tr()),
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
            onTap:
                () => Navigator.pushReplacementNamed(
                  context,
                  DashboardScreen.routeName,
                ),
            child: Container(
              padding: AppPad.a8,
              child: Icon(
                Icons.close,
                color: context.brandColors.textPrimary,
                size: 24,
              ),
            ),
          ),
          Text(
            '${notifier.learnedCount}/${notifier.totalCards}',
            style: TextStyle(
              color: context.brandColors.textPrimary,
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
                  style: TextStyle(
                    color: context.brandColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  notifier.descriptionMessage,
                  style: TextStyle(
                    color: context.brandColors.textSecondary,
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
          Text(
            'course_result.progress_title'.tr(),
            style: TextStyle(
              color: context.brandColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              _buildProgressCircle(context, notifier),
              const SizedBox(width: 20),
              Expanded(child: _buildProgressLegend(context, notifier)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle(
    BuildContext context,
    CourseResultNotifier notifier,
  ) {
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
              border: Border.all(
                color: context.brandColors.progressBackground,
                width: 12,
              ),
            ),
          ),

          SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: ProgressPainter(
                progress: notifier.progressPercentage,
                progressColor: context.brandColors.progressValue,
                backgroundColor: Colors.transparent,
                strokeWidth: 12,
              ),
            ),
          ),

          Center(
            child: Text(
              '${(notifier.progressPercentage * 100).toInt()}%',
              style: TextStyle(
                color: context.brandColors.textPrimary,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressLegend(
    BuildContext context,
    CourseResultNotifier notifier,
  ) {
    return Column(
      children: [
        _buildLegendItem(
          context,
          'course_result.legend_known'.tr(),
          context.brandColors.progressValue,
          notifier.knownCount,
        ),
        const SizedBox(height: 8),
        _buildLegendItem(
          context,
          'course_result.legend_learning'.tr(),
          context.brandColors.warning,
          notifier.learningCount,
        ),
        const SizedBox(height: 8),
        _buildLegendItem(
          context,
          'course_result.legend_remaining'.tr(),
          context.brandColors.textMuted,
          notifier.remainingCount,
        ),
      ],
    );
  }

  Widget _buildLegendItem(
    BuildContext context,
    String label,
    Color color,
    int count,
  ) {
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
            style: TextStyle(
              color: context.brandColors.textPrimary,
              fontSize: 14,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            count.toString(),
            style: TextStyle(
              color: context.brandColors.textPrimary,
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
                color: context.brandColors.buttonPrimary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.credit_card,
                    color: context.brandColors.textPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'course_result.action_review_terms'.tr(),
                    style: TextStyle(
                      color: context.brandColors.textPrimary,
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
                color: context.brandColors.buttonSecondary,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Center(
                child: Text(
                  'course_result.action_reset_cards'.tr(),
                  style: TextStyle(
                    color: context.brandColors.textPrimary,
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
                color: context.brandColors.warning,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.history,
                    color: context.brandColors.textPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'course_result.action_view_history'.tr(),
                    style: TextStyle(
                      color: context.brandColors.textPrimary,
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
              Navigator.pushReplacementNamed(
                context,
                DashboardScreen.routeName,
              );
            },
            child: Container(
              width: double.infinity,
              padding: AppPad.v20,
              decoration: BoxDecoration(
                color: context.brandColors.buttonSecondary,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(
                  color: context.brandColors.borderColor.withOpacity(0.3),
                  width: 1,
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.home,
                    color: context.brandColors.textPrimary,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'course_result.action_back_home'.tr(),
                    style: TextStyle(
                      color: context.brandColors.textPrimary,
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

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('course_result.reset_progress_success'.tr())),
    );

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
            'course_result.history_title'.tr(),
            style: TextStyle(
              color: context.brandColors.textPrimary,
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            notifier.course?.title ??
                'course_result.history_course_placeholder'.tr(),
            style: TextStyle(
              color: context.brandColors.textSecondary,
              fontSize: 14,
            ),
          ),
          const SizedBox(height: 20),

          _buildHistoryItems(context, notifier),

          const SizedBox(height: 20),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: () => Navigator.pop(context),
              style: ElevatedButton.styleFrom(
                backgroundColor: context.brandColors.warning,
                padding: const EdgeInsets.symmetric(vertical: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: Text(
                'common.close'.tr(),
                style: TextStyle(
                  color: context.brandColors.textPrimary,
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

  Widget _buildHistoryItems(
    BuildContext context,
    CourseResultNotifier notifier,
  ) {
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
          color: context.brandColors.cardBackground.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Icon(
              Icons.history,
              color: context.brandColors.textSecondary,
              size: 48,
            ),
            const SizedBox(height: 12),
            Text(
              'course_result.history_empty'.tr(),
              style: TextStyle(
                color: context.brandColors.textSecondary,
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
              color: context.brandColors.cardBackground.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: context.brandColors.borderColor.withOpacity(0.2),
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
                    color: context.brandColors.warning.withOpacity(0.2),
                    border: Border.all(
                      color: context.brandColors.warning,
                      width: 2,
                    ),
                  ),
                  child: Center(
                    child: Text(
                      '${progressPercentage.toInt()}%',
                      style: TextStyle(
                        color: context.brandColors.textPrimary,
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
                        'course_result.history_item_learned'.tr(
                          args: [
                            learnedCount.toString(),
                            totalCards.toString(),
                          ],
                        ),
                        style: TextStyle(
                          color: context.brandColors.textPrimary,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        _formatDateTime(completedAt),
                        style: TextStyle(
                          color: context.brandColors.textSecondary,
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
                          ? context.brandColors.progressValue
                          : context.brandColors.warning,
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
      return 'common.time_ago.days'.tr(args: [difference.inDays.toString()]);
    } else if (difference.inHours > 0) {
      return 'common.time_ago.hours'.tr(args: [difference.inHours.toString()]);
    } else if (difference.inMinutes > 0) {
      return 'common.time_ago.minutes'.tr(
        args: [difference.inMinutes.toString()],
      );
    } else {
      return 'common.time_ago.just_now'.tr();
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
