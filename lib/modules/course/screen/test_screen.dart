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
    // Kiểm tra nếu test đã được reset và cần khởi tạo lại
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
      // Lấy dữ liệu flashcards từ CourseInfoNotifier
      final courseNotifier = Provider.of<CourseInfoNotifier>(
        context,
        listen: false,
      );

      // Reset test hoàn toàn trước khi khởi tạo lần đầu
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
            screen: const Scaffold(
              backgroundColor: Color(0xFF0B1D3B),
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(color: Colors.white),
                    SizedBox(height: 16),
                    Text(
                      'Đang tạo bài kiểm tra...',
                      style: TextStyle(color: Colors.white70),
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
              backgroundColor: const Color(0xFF0B1D3B),
              body: Center(
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
                      onPressed: () => _initializeTest(),
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
            screen: const Scaffold(
              backgroundColor: Color(0xFF0B1D3B),
              body: Center(
                child: Text(
                  'Không có câu hỏi để kiểm tra',
                  style: TextStyle(color: Colors.white70),
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
      title: 'Kiểm tra - Câu ${notifier.currentQuestionIndex + 1}/${notifier.totalQuestions}',
      backgroundColor: context.colors.primary,
      screen: Column(
        children: [
          // Progress bar
          Container(
            width: double.infinity,
            height: 4,
            margin: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.2),
              borderRadius: BorderRadius.circular(2),
            ),
            child: FractionallySizedBox(
              alignment: Alignment.centerLeft,
              widthFactor: progress,
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.blue,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
          ),

          // Question
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                children: [
                  // Question text
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(0xFF0E2B5C),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: Colors.white.withOpacity(0.2),
                      ),
                    ),
                    child: Text(
                      currentQuestion.question,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Instructions
                  const Text(
                    'Chọn đáp án đúng:',
                    style: TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      fontWeight: FontWeight.w500,
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Answer options
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
        color: const Color(0xFF0E2B5C),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white.withOpacity(0.2)),
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
                style: const TextStyle(
                  color: Colors.white,
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
        backgroundColor: const Color(0xFF0B1D3B),
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.check_circle, color: Colors.green, size: 64),
              const SizedBox(height: 16),
              const Text(
                'Hoàn thành bài kiểm tra!',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              Consumer<TestNotifier>(
                builder: (context, notifier, child) {
                  return Text(
                    'Điểm: ${notifier.correctAnswers}/${notifier.totalQuestions} (${notifier.score.toStringAsFixed(1)}%)',
                    style: const TextStyle(color: Colors.white70, fontSize: 18),
                  );
                },
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () => _showResults(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue,
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
      if (result != null) {
        // Không hiển thị SnackBar để tránh che mất nút
        // Thông báo sẽ hiển thị trong màn hình hoàn thành
      }
    }
  }

  void _showExitConfirmation() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: const Color(0xFF0E2B5C),
          title: const Text(
            'Thoát bài kiểm tra',
            style: TextStyle(color: Colors.white),
          ),
          content: const Text(
            'Bạn có chắc chắn muốn thoát bài kiểm tra? Tiến độ hiện tại sẽ bị mất.',
            style: TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('Hủy', style: TextStyle(color: Colors.white70)),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
              child: const Text('Thoát', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
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
