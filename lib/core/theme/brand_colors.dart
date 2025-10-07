import 'package:flutter/material.dart';

@immutable
class BrandColors extends ThemeExtension<BrandColors> {
  final Color accent;
  final Color success;
  final Color warning;
  final Color info;
  final Color cardBackground;
  final Color borderColor;

  const BrandColors({
    required this.accent,
    required this.success,
    required this.warning,
    required this.info,
    required this.cardBackground,
    required this.borderColor,
  });

  @override
  BrandColors copyWith({
    Color? accent,
    Color? success,
    Color? warning,
    Color? info,
    Color? cardBackground,
    Color? borderColor,
  }) {
    return BrandColors(
      accent: accent ?? this.accent,
      success: success ?? this.success,
      warning: warning ?? this.warning,
      info: info ?? this.info,
      cardBackground: cardBackground ?? this.cardBackground,
      borderColor: borderColor ?? this.borderColor,
    );
  }

  @override
  BrandColors lerp(ThemeExtension<BrandColors>? other, double t) {
    if (other is! BrandColors) return this;
    return BrandColors(
      accent: Color.lerp(accent, other.accent, t)!,
      success: Color.lerp(success, other.success, t)!,
      warning: Color.lerp(warning, other.warning, t)!,
      info: Color.lerp(info, other.info, t)!,
      cardBackground: Color.lerp(cardBackground, other.cardBackground, t)!,
      borderColor: Color.lerp(borderColor, other.borderColor, t)!,
    );
  }
}
