import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/init.dart';
import 'package:card_mind/modules/library/provider/content_notifier.dart';
import 'package:card_mind/modules/library/widgets/content_item_widget.dart';
import 'package:card_mind/modules/library/widgets/data_group_widget.dart';
import 'package:provider/provider.dart';
import 'package:flutter/material.dart';

class ContentScreen extends StatefulWidget {
  const ContentScreen({super.key, required this.tabType});
  final String tabType;

  @override
  State<ContentScreen> createState() => _ContentScreenState();
}

class _ContentScreenState extends State<ContentScreen> {
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final notifier = Provider.of<ContentNotifier>(context, listen: false);
    await notifier.initializeData();

    if (mounted) {
      setState(() {
        _isInitialized = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<ContentNotifier>(
      builder: (context, notifier, child) {
        if (!_isInitialized || notifier.isLoading) {
          return FunctionScreenTemplate(
            backgroundColor: context.colors.primary,
            screen: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        if (notifier.hasError) {
          return FunctionScreenTemplate(
            backgroundColor: context.colors.primary,
            screen: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: context.colors.onPrimary, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    notifier.errorMessage ?? 'Có lỗi xảy ra',
                    style: AppTextStyles.textContent2.copyWith(
                      color: context.colors.onPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _initializeData(),
                    child: const Text('Thử lại'),
                  ),
                ],
              ),
            ),
          );
        }

        return FunctionScreenTemplate(
          backgroundColor: context.colors.primary,
          screen: SingleChildScrollView(
            padding: AppPad.h16v8,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (notifier.contents.isEmpty)
                  Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.library_books,
                          color: context.colors.onPrimary.withOpacity(0.5),
                          size: 64,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Chưa có nội dung nào',
                          style: AppTextStyles.textContent2.copyWith(
                            color: context.colors.onPrimary.withOpacity(0.7),
                          ),
                        ),
                      ],
                    ),
                  )
                else
                  DataGroupWidget(
                    date: 'Tất cả nội dung',
                    items:
                        notifier.contents.map((content) {
                          return ContentItemWidget(
                            title: content.title,
                            details:
                                '${content.totalTerms} thuật ngữ • Tác giả: ${content.author}',
                            tabType: widget.tabType,
                            contentData: content,
                          );
                        }).toList(),
                  ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        );
      },
    );
  }
}
