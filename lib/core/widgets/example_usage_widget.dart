import 'package:flutter/material.dart';
import '../theme/brand_colors.dart';

class ExampleUsageWidget extends StatelessWidget {
  const ExampleUsageWidget({super.key});

  @override
  Widget build(BuildContext context) {
    final brandColors = Theme.of(context).extension<BrandColors>()!;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Ví dụ sử dụng BrandColors'),
        backgroundColor: brandColors.accent,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: brandColors.cardBackground,
                border: Border.all(color: brandColors.borderColor),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Thông báo thành công',
                    style: TextStyle(
                      color: brandColors.success,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text('Đây là ví dụ về cách sử dụng màu success từ BrandColors.'),
                ],
              ),
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandColors.success,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Thành công'),
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: brandColors.warning,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Cảnh báo'),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Row(
              children: [
                Icon(Icons.info, color: brandColors.info),
                const SizedBox(width: 8),
                Text(
                  'Thông tin quan trọng',
                  style: TextStyle(color: brandColors.info, fontWeight: FontWeight.w500),
                ),
              ],
            ),

            const SizedBox(height: 16),

            Container(
              width: double.infinity,
              height: 100,
              decoration: BoxDecoration(
                color: brandColors.accent.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: brandColors.accent),
              ),
              child: Center(
                child: Text(
                  'Màu accent từ BrandColors',
                  style: TextStyle(
                    color: brandColors.accent,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
