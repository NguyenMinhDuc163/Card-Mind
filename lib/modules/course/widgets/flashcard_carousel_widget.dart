import 'package:flutter/material.dart';
import 'package:flip_card/flip_card.dart';
import '../../../data/models/flashcard.dart';
import '../../../core/theme/theme_extensions.dart';

class FlashcardCarouselWidget extends StatefulWidget {
  final List<Flashcard> flashcards;
  final Function(int)? onPageChanged;
  final Function(Flashcard)? onCardTap;

  const FlashcardCarouselWidget({
    super.key,
    required this.flashcards,
    this.onPageChanged,
    this.onCardTap,
  });

  @override
  State<FlashcardCarouselWidget> createState() =>
      _FlashcardCarouselWidgetState();
}

class _FlashcardCarouselWidgetState extends State<FlashcardCarouselWidget> {
  late PageController _pageController;
  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: 0);
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.flashcards.isEmpty) {
      return _buildEmptyState();
    }

    return Column(
      children: [
        SizedBox(
          height: 320,
          child: PageView.builder(
            controller: _pageController,
            physics: const BouncingScrollPhysics(),
            onPageChanged: (index) {
              setState(() {
                _currentIndex = index;
              });
              widget.onPageChanged?.call(index);
            },
            itemCount: widget.flashcards.length,
            itemBuilder: (context, index) {
              final flashcard = widget.flashcards[index];
              return _buildFlashcard(context, flashcard);
            },
          ),
        ),
        const SizedBox(height: 16),
        _buildPageIndicators(),
      ],
    );
  }

  Widget _buildFlashcard(BuildContext context, Flashcard flashcard) {
    return FlipCard(
      direction: FlipDirection.HORIZONTAL,
      speed: 400,
      flipOnTouch: true,
      front: _buildCardSide(
        context,
        text: flashcard.frontText,
        imageUrl: flashcard.frontImage,
        isFront: true,
      ),
      back: _buildCardSide(
        context,
        text: flashcard.backText,
        imageUrl: flashcard.backImage,
        isFront: false,
      ),
    );
  }

  Widget _buildCardSide(
    BuildContext context, {
    required String text,
    String? imageUrl,
    required bool isFront,
  }) {
    return Container(
      height: 280,
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: context.colors.secondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: context.colors.primary.withOpacity(0.2),
            blurRadius: 8,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageUrl != null && imageUrl.isNotEmpty) ...[
              Container(
                height: 80,
                width: double.infinity,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white.withOpacity(0.1),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.network(
                    imageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(
                        Icons.image_not_supported,
                        color: Colors.white70,
                        size: 32,
                      );
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Expanded(
              child: Center(
                child: Text(
                  text,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                    height: 1.4,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 6,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Container(
      height: 320,
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: const Color(0xFF0E2B5C),
        borderRadius: BorderRadius.circular(16),
      ),
      child: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.style, color: Colors.white70, size: 48),
            SizedBox(height: 16),
            Text(
              'Chưa có thẻ học nào',
              style: TextStyle(
                color: Colors.white70,
                fontSize: 16,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPageIndicators() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(
        widget.flashcards.length,
        (index) => Container(
          width: 8,
          height: 8,
          margin: const EdgeInsets.symmetric(horizontal: 4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color:
                index == _currentIndex
                    ? const Color(0xFF0E2B5C)
                    : Colors.white.withOpacity(0.5),
          ),
        ),
      ),
    );
  }
}
