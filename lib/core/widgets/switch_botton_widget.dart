import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../theme/theme_cubit.dart';

class SwitchBottomWidget extends StatelessWidget {
  final ValueChanged<bool>? onChanged;
  const SwitchBottomWidget({Key? key, this.onChanged}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<ThemeCubit, ThemeMode>(
      builder: (context, themeMode) {
        // Chỉ có 2 chế độ: Dark = true, Light = false
        // Nếu đang ở System mode, coi như Light mode
        bool isDarkMode = themeMode == ThemeMode.dark;

        return Switch(
          value: isDarkMode,
          onChanged: (value) {
            // Chỉ chuyển đổi giữa Dark và Light mode
            final newMode = value ? ThemeMode.dark : ThemeMode.light;
            context.read<ThemeCubit>().setThemeMode(newMode);

            // Gọi callback nếu có
            if (onChanged != null) onChanged!(value);
          },
          activeColor: Colors.white,
          activeTrackColor: Colors.green,
          inactiveThumbColor: Colors.white,
          inactiveTrackColor: Colors.grey[300],
        );
      },
    );
  }
}
