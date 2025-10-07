import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/brand_colors.dart';
import '../theme/theme_extensions.dart';
import '../theme/theme_cubit.dart';

class ThemeDemoWidget extends StatelessWidget {
  const ThemeDemoWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Theme Demo'),
        backgroundColor: context.brandColors.accent,
        foregroundColor: Colors.white,
        actions: [
          IconButton(onPressed: () => _toggleTheme(context), icon: const Icon(Icons.brightness_6)),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: context.brandColors.cardBackground,
                border: Border.all(color: context.brandColors.borderColor),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    'Demo Màu Theme',
                    style: TextStyle(
                      color: context.brandColors.accent,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ColorBox(color: context.brandColors.success, label: 'Success'),
                      _ColorBox(color: context.brandColors.warning, label: 'Warning'),
                      _ColorBox(color: context.brandColors.info, label: 'Info'),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () => _toggleTheme(context),
                icon: const Icon(Icons.brightness_6),
                label: const Text('Đổi Theme'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: context.brandColors.accent,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
                ),
              ),
            ),

            const SizedBox(height: 16),

            BlocBuilder<ThemeCubit, ThemeMode>(
              builder: (context, themeMode) {
                String themeName = switch (themeMode) {
                  ThemeMode.light => 'Light Mode',
                  ThemeMode.dark => 'Dark Mode',
                  ThemeMode.system => 'System Mode',
                };

                return Text(
                  'Theme hiện tại: $themeName',
                  style: TextStyle(
                    color: context.brandColors.info,
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  void _toggleTheme(BuildContext context) {
    final currentMode = context.read<ThemeCubit>().state;
    final newMode = switch (currentMode) {
      ThemeMode.light => ThemeMode.dark,
      ThemeMode.dark => ThemeMode.system,
      ThemeMode.system => ThemeMode.light,
    };
    context.read<ThemeCubit>().setThemeMode(newMode);
  }
}

class _ColorBox extends StatelessWidget {
  final Color color;
  final String label;

  const _ColorBox({required this.color, required this.label});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: context.brandColors.borderColor, width: 1),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          label,
          style: TextStyle(
            color: Theme.of(context).textTheme.bodyMedium?.color,
            fontSize: 12,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
