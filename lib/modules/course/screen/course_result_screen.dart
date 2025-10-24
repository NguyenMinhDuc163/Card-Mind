import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/core/widgets/app_gap.dart';
import 'package:card_mind/init.dart';
import 'package:card_mind/modules/dashboard/screen/dashboard_screen.dart';
import 'package:flutter/material.dart';
import 'package:card_mind/core/theme/app_colors.dart';
import 'package:card_mind/core/theme/app_pad.dart';
import 'package:flutter_svg/flutter_svg.dart';

class CourseResultScreen extends StatefulWidget {
  static const String routeName = '/course-result';

  const CourseResultScreen({super.key});

  @override
  State<CourseResultScreen> createState() => _CourseResultScreenState();
}

class _CourseResultScreenState extends State<CourseResultScreen> {
  @override
  Widget build(BuildContext context) {
    return FunctionScreenTemplate(
      isShowAppBar: false,
      backgroundColor: context.colors.primary,
      screen: SingleChildScrollView(
        child: Column(
          children: [
            _buildHeader(),
            _buildCongratulationSection(),
            _buildProgressSection(),
            AppGap.h80,
            _buildActionButtons(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
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
          const Text(
            '9/9',
            style: TextStyle(
              color: AppColors.white,
              fontSize: 16,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCongratulationSection() {
    return Padding(
      padding: AppPad.h16v20,
      child: Row(
        children: [
          Expanded(
            flex: 2,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Bạn đang làm rất tuyệt!',
                  style: TextStyle(
                    color: AppColors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  'Hãy tiếp tục tập trung vào các thuật ngữ khó.',
                  style: TextStyle(
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

  Widget _buildProgressSection() {
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
              _buildProgressCircle(),
              const SizedBox(width: 20),
              Expanded(child: _buildProgressLegend()),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildProgressCircle() {
    return SizedBox(
      width: 100,
      height: 100,
      child: Stack(
        children: [
          // Background circle (hollow ring)
          Container(
            width: 100,
            height: 100,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.lightOrange, width: 12),
            ),
          ),
          // Progress arc (33%)
          SizedBox(
            width: 100,
            height: 100,
            child: CustomPaint(
              painter: ProgressPainter(
                progress: 0.33,
                progressColor: AppColors.tealGreen,
                backgroundColor: Colors.transparent,
                strokeWidth: 12,
              ),
            ),
          ),
          // Center text
          const Center(
            child: Text(
              '33%',
              style: TextStyle(
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

  Widget _buildProgressLegend() {
    return Column(
      children: [
        _buildLegendItem('Biết', AppColors.tealGreen, 3),
        const SizedBox(height: 8),
        _buildLegendItem('Đang học', AppColors.lightOrange, 6),
        const SizedBox(height: 8),
        _buildLegendItem('Còn lại', AppColors.gray, 0),
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

  Widget _buildActionButtons() {
    return Padding(
      padding: AppPad.h16v20,
      child: Column(
        children: [
          GestureDetector(
            onTap: () {
              Navigator.pushNamed(context, DashboardScreen.routeName);
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
              // TODO: Implement practice in learning mode
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
        ],
      ),
    );
  }
}

// Custom painter for progress circle
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

    // Only draw background circle if backgroundColor is not transparent
    if (backgroundColor != Colors.transparent) {
      final backgroundPaint =
          Paint()
            ..color = backgroundColor
            ..strokeWidth = strokeWidth
            ..style = PaintingStyle.stroke
            ..strokeCap = StrokeCap.round;

      canvas.drawCircle(center, radius, backgroundPaint);
    }

    // Progress arc
    final progressPaint =
        Paint()
          ..color = progressColor
          ..strokeWidth = strokeWidth
          ..style = PaintingStyle.stroke
          ..strokeCap = StrokeCap.round;

    final startAngle = -1.5708; // -90 degrees in radians
    final sweepAngle = 2 * 3.14159 * progress; // Convert progress to radians

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
