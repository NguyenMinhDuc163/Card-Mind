import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/data/models/flashcard.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flip_card/flip_card.dart';

class FlipFlashcardWidget extends StatefulWidget {
  final Flashcard flashcard;
  final VoidCallback? onTap;
  final double? height;
  final double? width;

  const FlipFlashcardWidget({
    super.key,
    required this.flashcard,
    this.onTap,
    this.height,
    this.width,
  });

  @override
  State<FlipFlashcardWidget> createState() => _FlipFlashcardWidgetState();
}

class _FlipFlashcardWidgetState extends State<FlipFlashcardWidget> {
  final GlobalKey<FlipCardState> _cardKey = GlobalKey<FlipCardState>();
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) {
        setState(() {
          _isPressed = true;
        });
      },
      onTapUp: (_) {
        setState(() {
          _isPressed = false;
        });
      },
      onTapCancel: () {
        setState(() {
          _isPressed = false;
        });
      },
      onTap: () {
        HapticFeedback.lightImpact();
        _cardKey.currentState?.toggleCard();
        widget.onTap?.call();
      },

      behavior: HitTestBehavior.opaque,
      child: FlipCard(
        key: _cardKey,
        direction: FlipDirection.HORIZONTAL,
        speed: 400,
        flipOnTouch: false,
        front: _buildCardSide(
          context,
          text: widget.flashcard.frontText,
          imageUrl: widget.flashcard.frontImage,
          isFront: true,
        ),
        back: _buildCardSide(
          context,
          text: widget.flashcard.backText,
          imageUrl: widget.flashcard.backImage,
          isFront: false,
        ),
      ),
    );
  }

  Widget _buildCardSide(
    BuildContext context, {
    required String text,
    String? imageUrl,
    required bool isFront,
  }) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 150),
      curve: Curves.easeInOut,
      height: widget.height ?? 280,
      width: widget.width ?? double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: _isPressed ? context.colors.secondary.withOpacity(0.8) : context.colors.secondary,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color:
                _isPressed
                    ? context.colors.primary.withOpacity(0.3)
                    : context.colors.primary.withOpacity(0.2),
            blurRadius: _isPressed ? 12 : 8,
            offset: Offset(0, _isPressed ? 6 : 4),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (imageUrl != null) ...[
              Container(
                height: 120,
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
                      return const Icon(Icons.image_not_supported, color: Colors.white70, size: 48);
                    },
                  ),
                ),
              ),
              const SizedBox(height: 16),
            ],
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w600,
                height: 1.4,
              ),
              textAlign: TextAlign.center,
              maxLines: 4,
              overflow: TextOverflow.ellipsis,
            ),
            const SizedBox(height: 8),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  isFront ? 'Mặt trước' : 'Mặt sau',
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      isFront ? 'Chạm để lật' : 'Chạm để lật lại',
                      style: const TextStyle(
                        color: Colors.white70,
                        fontSize: 10,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                    const SizedBox(width: 4),
                    Icon(isFront ? Icons.touch_app : Icons.flip, color: Colors.white70, size: 16),
                  ],
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
