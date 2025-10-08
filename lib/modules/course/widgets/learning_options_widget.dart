import 'package:flutter/material.dart';

enum LearningMode { flashcards, learn, test, match, blast, gravity }

class LearningOptionsWidget extends StatelessWidget {
  final Function(LearningMode)? onOptionTap;

  const LearningOptionsWidget({super.key, this.onOptionTap});

  @override
  Widget build(BuildContext context) {
    final options = [
      LearningOption(
        mode: LearningMode.flashcards,
        title: 'Thẻ ghi nhớ',
        icon: Icons.style,
        description: 'Học từ vựng với thẻ flashcard',
      ),
      LearningOption(
        mode: LearningMode.learn,
        title: 'Học',
        icon: Icons.autorenew,
        description: 'Học từ vựng theo phương pháp thích ứng',
      ),
      LearningOption(
        mode: LearningMode.test,
        title: 'Kiểm tra',
        icon: Icons.quiz,
        description: 'Kiểm tra kiến thức với các câu hỏi',
      ),
      LearningOption(
        mode: LearningMode.match,
        title: 'Ghép thẻ',
        icon: Icons.compare_arrows,
        description: 'Ghép cặp từ vựng với nghĩa',
      ),
      LearningOption(
        mode: LearningMode.blast,
        title: 'Blast',
        icon: Icons.rocket_launch,
        description: 'Trò chơi tốc độ với từ vựng',
      ),
      LearningOption(
        mode: LearningMode.gravity,
        title: 'Khối hộp',
        icon: Icons.grid_view,
        description: 'Trò chơi xếp khối với từ vựng',
      ),
    ];

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Chế độ học tập',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          ...options.map((option) => _buildOptionItem(option)).toList(),
        ],
      ),
    );
  }

  Widget _buildOptionItem(LearningOption option) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: const Color(0xFF0E2B5C),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => onOptionTap?.call(option.mode),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(option.icon, color: Colors.white, size: 24),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        option.title,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        option.description,
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Icon(
                  Icons.arrow_forward_ios,
                  color: Colors.white.withOpacity(0.5),
                  size: 16,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class LearningOption {
  final LearningMode mode;
  final String title;
  final IconData icon;
  final String description;

  const LearningOption({
    required this.mode,
    required this.title,
    required this.icon,
    required this.description,
  });
}
