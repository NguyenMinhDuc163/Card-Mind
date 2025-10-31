import 'package:flutter/material.dart';
import 'package:card_mind/core/theme/app_text_styles.dart';

/// Widget chuyển đổi ngôn ngữ với giao diện đẹp
/// isEnglish = true: Hiển thị "EN" với indicator
/// isEnglish = false: Hiển thị "VI" với indicator
class SwitchLang extends StatelessWidget {
  const SwitchLang({
    super.key,
    required this.onTap,
    required this.isEnglish,
    this.colorText,
    this.colorBackground,
  });

  final VoidCallback onTap;
  final bool isEnglish;
  final Color? colorText;
  final Color? colorBackground;

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: 12,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: colorBackground ?? Colors.white.withOpacity(0.9),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: (colorText ?? Colors.black).withOpacity(0.1),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Tiếng Việt
            Text(
              'VI',
              style: AppTextStyles.text.copyWith(
                color: !isEnglish
                    ? (colorText ?? Colors.blue)
                    : (colorText ?? Colors.black).withOpacity(0.4),
                fontWeight: !isEnglish ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 4),
            // Separator
            Container(
              width: 1,
              height: 14,
              color: (colorText ?? Colors.black).withOpacity(0.2),
            ),
            const SizedBox(width: 4),
            // Tiếng Anh
            Text(
              'EN',
              style: AppTextStyles.text.copyWith(
                color: isEnglish
                    ? (colorText ?? Colors.blue)
                    : (colorText ?? Colors.black).withOpacity(0.4),
                fontWeight: isEnglish ? FontWeight.bold : FontWeight.normal,
              ),
            ),
            const SizedBox(width: 6),
            // Indicator
            Icon(
              Icons.language,
              size: 16,
              color: (colorText ?? Colors.blue).withOpacity(0.7),
            ),
          ],
        ),
      ),
    );
  }
}
