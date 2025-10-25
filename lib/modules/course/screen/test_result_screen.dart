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
            screen: const Scaffold(
              backgroundColor: Color(0xFF0B1D3B),
              body: Center(
                child: Text(
                  'Không có kết quả để hiển thị',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
          );
        }

        final correctAnswers = answers.where((answer) => answer.isCorrect).length;
        final totalQuestions = answers.length;
        final score = totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0.0;

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
                    color: const Color(0xFF0E2B5C),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.2)),
                  ),
                  child: Column(
                    children: [
                      const Icon(Icons.quiz, color: Colors.blue, size: 48),
                      const SizedBox(height: 16),
                      const Text(
                        'Điểm số của bạn',
                        style: TextStyle(color: Colors.white70, fontSize: 16),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${correctAnswers}/${totalQuestions}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '${score.toStringAsFixed(1)}%',
                        style: TextStyle(
                          color: _getScoreColor(score),
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildScoreMessage(score),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'Chi tiết câu trả lời',
                  style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                ),

                const SizedBox(height: 16),

                ...answers.asMap().entries.map((entry) {
                  final index = entry.key;
                  final answer = entry.value;
                  final question =
                      notifier.questions.isNotEmpty && index < notifier.questions.length
                          ? notifier.questions[index]
                          : null;
                  return _buildAnswerDetail(index + 1, answer, question);
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
                            final courseNotifier = Provider.of<CourseInfoNotifier>(
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
                                const SnackBar(
                                  content: Text('Không có dữ liệu để tạo bài kiểm tra'),
                                  backgroundColor: Colors.red,
                                ),
                              );
                              return;
                            }
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Không tìm thấy thông tin khóa học'),
                                backgroundColor: Colors.red,
                              ),
                            );
                            return;
                          }

                          Navigator.of(context).pop();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Làm lại', style: TextStyle(color: Colors.white)),
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
                          backgroundColor: Colors.green,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                        ),
                        child: const Text('Hoàn thành', style: TextStyle(color: Colors.white)),
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

  Widget _buildAnswerDetail(int questionNumber, TestAnswer answer, TestQuestion? question) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: answer.isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: answer.isCorrect ? Colors.green.withOpacity(0.3) : Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: answer.isCorrect ? Colors.green : Colors.red,
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
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Đáp án của bạn: ${answer.selectedAnswer}',
                  style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 14),
                ),
                if (!answer.isCorrect && question != null) ...[
                  const SizedBox(height: 4),
                  Text(
                    'Đáp án đúng: ${question.correctAnswer}',
                    style: const TextStyle(
                      color: Colors.green,
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

  Widget _buildScoreMessage(double score) {
    String message;
    Color color;

    if (score >= 90) {
      message = 'Xuất sắc! Bạn đã nắm vững kiến thức.';
      color = Colors.green;
    } else if (score >= 70) {
      message = 'Tốt! Hãy tiếp tục cố gắng.';
      color = Colors.blue;
    } else if (score >= 50) {
      message = 'Khá tốt! Cần ôn tập thêm.';
      color = Colors.orange;
    } else {
      message = 'Cần cố gắng hơn! Hãy ôn tập lại.';
      color = Colors.red;
    }

    return Text(
      message,
      style: TextStyle(color: color, fontSize: 16, fontWeight: FontWeight.w500),
      textAlign: TextAlign.center,
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 90) return Colors.green;
    if (score >= 70) return Colors.blue;
    if (score >= 50) return Colors.orange;
    return Colors.red;
  }
}
