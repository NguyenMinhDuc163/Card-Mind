import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:card_mind/init.dart';
import 'package:provider/provider.dart';
import '../model/test_question.dart';
import '../provider/test_notifier.dart';
import '../provider/course_info_notifier.dart';

class TestResultScreen extends StatelessWidget {
  const TestResultScreen({super.key});

  static const String routeName = '/TestResultScreen';

  @override
  Widget build(BuildContext context) {
    return Consumer<TestNotifier>(
      builder: (context, notifier, child) {
        final answers = notifier.answers;

        if (answers.isEmpty) {
          return FunctionScreenTemplate(
            screen: Scaffold(
              backgroundColor: context.colors.primary,
              body: Center(
                child: Text(
                  'Không có kết quả để hiển thị',
                  style: TextStyle(color: context.brandColors.textSecondary),
                ),
              ),
            ),
          );
        }

        final correctAnswers =
            answers.where((answer) => answer.isCorrect).length;
        final totalQuestions = answers.length;
        final score =
            totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0.0;

        return FunctionScreenTemplate(
          title: "Kết quả kiểm tra",
          backgroundColor: context.colors.primary,
          screen: SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: context.brandColors.cardBackground,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: context.brandColors.borderColor.withOpacity(0.2),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(
                        Icons.quiz,
                        color: context.brandColors.buttonPrimary,
                        size: 48,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Điểm số của bạn',
                        style: TextStyle(
                          color: context.brandColors.textSecondary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${correctAnswers}/${totalQuestions}',
                        style: TextStyle(
                          color: context.brandColors.textPrimary,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${score.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: _getScoreColor(context, score),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildScoreMessage(context, score),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                Text(
                  'Chi tiết câu trả lời',
                  style: TextStyle(
                    color: context.brandColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 16),

                ...answers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final answer = entry.value;
                  final question =
                      notifier.questions.isNotEmpty &&
                              index < notifier.questions.length
                          ? notifier.questions[index]
                          : null;
                  return _buildAnswerDetail(
                    context,
                    index + 1,
                    answer,
                    question,
                  );
                }).toList(),

                const SizedBox(height: 24),

                Row(
                  children: [
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () async {
                          notifier.resetTest();

                          final courseId = notifier.courseId;
                          if (courseId != null) {
                            final courseNotifier =
                                Provider.of<CourseInfoNotifier>(
                                  context,
                                  listen: false,
                                );

                            if (courseNotifier.flashcards.isNotEmpty) {
                              await notifier.initializeTest(
                                courseId: courseId,
                                flashcards: courseNotifier.flashcards,
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: const Text(
                                    'Không có dữ liệu để tạo bài kiểm tra',
                                  ),
                                  backgroundColor:
                                      context.brandColors.buttonDestructive,
                                ),
                              );
                              return;
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: const Text(
                                  'Không tìm thấy thông tin khóa học',
                                ),
                                backgroundColor:
                                    context.brandColors.buttonDestructive,
                              ),
                            );
                            return;
                          }

                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.brandColors.buttonPrimary,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Làm lại',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: ElevatedButton(
                        onPressed: () {
                          Navigator.of(context).pop();
                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: context.brandColors.progressValue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text(
                          'Hoàn thành',
                          style: TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAnswerDetail(
    BuildContext context,
    int questionNumber,
    TestAnswer answer,
    TestQuestion? question,
  ) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color:
            answer.isCorrect
                ? context.brandColors.progressValue.withOpacity(0.1)
                : context.brandColors.buttonDestructive.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color:
              answer.isCorrect
                  ? context.brandColors.progressValue.withOpacity(0.3)
                  : context.brandColors.buttonDestructive.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color:
                  answer.isCorrect
                      ? context.brandColors.progressValue
                      : context.brandColors.buttonDestructive,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Icon(
                answer.isCorrect ? Icons.check : Icons.close,
                color: Colors.white,
                size: 20,
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Câu $questionNumber',
                  style: TextStyle(
                    color: context.brandColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Đáp án của bạn: ${answer.selectedAnswer}',
                  style: TextStyle(
                    color: context.brandColors.textSecondary,
                    fontSize: 14,
                  ),
                ),
                if (!answer.isCorrect && question != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Đáp án đúng: ${question.correctAnswer}',
                    style: TextStyle(
                      color: context.brandColors.progressValue,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildScoreMessage(BuildContext context, double score) {
    String message;
    Color color;

    if (score >= 90) {
      message = 'Xuất sắc! Bạn đã nắm vững kiến thức.';
      color = context.brandColors.progressValue;
    } else if (score >= 70) {
      message = 'Tốt! Hãy tiếp tục cố gắng.';
      color = context.brandColors.buttonPrimary;
    } else if (score >= 50) {
      message = 'Khá tốt! Cần ôn tập thêm.';
      color = context.brandColors.warning;
    } else {
      message = 'Cần cố gắng hơn! Hãy ôn tập lại.';
      color = context.brandColors.buttonDestructive;
    }

    return Text(
      message,
      style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w500),
      textAlign: TextAlign.center,
    );
  }

  Color _getScoreColor(BuildContext context, double score) {
    if (score >= 90) return context.brandColors.progressValue;
    if (score >= 70) return context.brandColors.buttonPrimary;
    if (score >= 50) return context.brandColors.warning;
    return context.brandColors.buttonDestructive;
  }
}
