import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:flutter/material.dart';
import 'package:card_mind/init.dart';
import 'package:provider/provider.dart';
import '../provider/test_notifier.dart';
import '../provider/course_info_notifier.dart';
import '../model/test_question.dart';
import 'test_result_screen.dart';

class TestScreen extends StatefulWidget {
  const TestScreen({super.key});

  static const String routeName = '/TestScreen';

  @override
  State<TestScreen> createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeTest();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();

    final notifier = Provider.of<TestNotifier>(context, listen: false);
    if (notifier.questions.isEmpty &&
        !notifier.isLoading &&
        notifier.courseId != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _initializeTest();
      });
    }
  }

  Future<void> _initializeTest() async {
    final notifier = Provider.of<TestNotifier>(context, listen: false);
    final courseId = ModalRoute.of(context)?.settings.arguments as String?;

    if (courseId != null) {
      final courseNotifier = Provider.of<CourseInfoNotifier>(
        context,
        listen: false,
      );

      notifier.resetTestCompletely();

      await notifier.initializeTest(
        courseId: courseId,
        flashcards: courseNotifier.flashcards,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<TestNotifier>(
      builder: (context, notifier, child) {
        if (notifier.isLoading) {
          return FunctionScreenTemplate(
            screen: Scaffold(
              backgroundColor: context.colors.primary,
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(
                      color: context.brandColors.textPrimary,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Đang tạo bài kiểm tra...',
                      style: TextStyle(
                        color: context.brandColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (notifier.hasError) {
          return FunctionScreenTemplate(
            screen: Scaffold(
              backgroundColor: context.colors.primary,
              body: Center(
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
                      notifier.errorMessage ?? 'Có lỗi xảy ra',
                      style: TextStyle(
                        color: context.brandColors.textSecondary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () => _initializeTest(),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: context.brandColors.buttonPrimary,
                        foregroundColor: Colors.white,
                      ),
                      child: const Text('Thử lại'),
                    ),
                  ],
                ),
              ),
            ),
          );
        }

        if (notifier.questions.isEmpty) {
          return FunctionScreenTemplate(
            screen: Scaffold(
              backgroundColor: context.colors.primary,
              body: Center(
                child: Text(
                  'Không có câu hỏi để kiểm tra',
                  style: TextStyle(color: context.brandColors.textSecondary),
                ),
              ),
            ),
          );
        }

        if (notifier.isTestCompleted) {
          return _buildTestCompleted();
        }

        return _buildTestInterface(notifier);
      },
    );
  }

  Widget _buildTestInterface(TestNotifier notifier) {
    final currentQuestion = notifier.currentQuestion!;
    final progress =
        (notifier.currentQuestionIndex + 1) / notifier.totalQuestions;

    return FunctionScreenTemplate(
      title:
          'Kiểm tra - Câu ${notifier.currentQuestionIndex + 1}/${notifier.totalQuestions}',
      backgroundColor: context.colors.primary,
      screen: Column(
        children: [
          Container(
            width: double.infinity,
            height: 4,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: context.brandColors.progressBackground,
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: context.brandColors.progressValue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
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
                    child: Text(
                      currentQuestion.question,
                      style: TextStyle(
                        color: context.brandColors.textPrimary,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),

                  Text(
                    'Chọn đáp án đúng:',
                    style: TextStyle(
                      color: context.brandColors.textSecondary,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: _buildAnswerOptions(currentQuestion, notifier),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAnswerOptions(TestQuestion question, TestNotifier notifier) {
    return GridView.builder(
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.5,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: question.options.length,
      itemBuilder: (context, index) {
        final option = question.options[index];
        return _buildAnswerOption(option, notifier);
      },
    );
  }

  Widget _buildAnswerOption(String option, TestNotifier notifier) {
    return Container(
      decoration: BoxDecoration(
        color: context.brandColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: context.brandColors.borderColor.withOpacity(0.2),
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _selectAnswer(option, notifier),
          child: Container(
            padding: const EdgeInsets.all(16),
            child: Center(
              child: Text(
                option,
                style: TextStyle(
                  color: context.brandColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTestCompleted() {
    return FunctionScreenTemplate(
      screen: Scaffold(
        backgroundColor: context.colors.primary,
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.check_circle,
                color: context.brandColors.progressValue,
                size: 64,
              ),
              const SizedBox(height: 16),
              Text(
                'Hoàn thành bài kiểm tra!',
                style: TextStyle(
                  color: context.brandColors.textPrimary,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Consumer<TestNotifier>(
                builder: (context, notifier, child) {
                  return Text(
                    'Điểm: ${notifier.correctAnswers}/${notifier.totalQuestions} (${notifier.score.toStringAsFixed(1)}%)',
                    style: TextStyle(
                      color: context.brandColors.textSecondary,
                      fontSize: 18,
                    ),
                  );
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _showResults(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.brandColors.buttonPrimary,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 32,
                    vertical: 12,
                  ),
                ),
                child: const Text(
                  'Xem kết quả chi tiết',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _selectAnswer(String selectedAnswer, TestNotifier notifier) {
    notifier.answerQuestion(selectedAnswer);

    if (notifier.isTestCompleted) {
      final result = notifier.completeTest();
      if (result != null) {}
    }
  }

  void _showResults() {
    final notifier = Provider.of<TestNotifier>(context, listen: false);
    Navigator.pushNamed(
      context,
      TestResultScreen.routeName,
      arguments: notifier.answers,
    );
  }
}
