import 'package:card_mind/init.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/core/theme/app_pad.dart';
import 'package:card_mind/core/theme/app_text_styles.dart';
import 'package:card_mind/modules/create_course/provider/create_course_notifier.dart';
import 'package:card_mind/modules/create_course/model/create_course_data.dart';
import 'package:card_mind/modules/create_course/model/import_data_config.dart';
import 'package:card_mind/modules/create_course/screen/import_data_screen.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CreateCourseScreen extends StatefulWidget {
  static const String routeName = '/create-course';

  const CreateCourseScreen({super.key});

  @override
  State<CreateCourseScreen> createState() => _CreateCourseScreenState();
}

class _CreateCourseScreenState extends State<CreateCourseScreen> {
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _showDescription = false;
  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    final notifier = Provider.of<CreateCourseNotifier>(context, listen: false);
    await notifier.initializeData();

    if (mounted) {
      setState(() {
        _isInitialized = true;
        _loadDataToControllers(notifier.courseData);
      });
    }
  }

  void _loadDataToControllers(CreateCourseData courseData) {
    _topicController.text = courseData.topic;
    _titleController.text = courseData.title;
    _descriptionController.text = courseData.description ?? '';
    _showDescription =
        courseData.description != null && courseData.description!.isNotEmpty;
  }

  @override
  void dispose() {
    _topicController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<CreateCourseNotifier>(
      builder: (context, notifier, child) {
        if (!_isInitialized || notifier.isLoading) {
          return FunctionScreenTemplate(
            isShowAppBar: false,
            backgroundColor: context.colors.primary,
            screen: Center(
              child: CircularProgressIndicator(
                color: context.brandColors.textPrimary,
              ),
            ),
          );
        }

        if (notifier.hasError) {
          return FunctionScreenTemplate(
            isShowAppBar: false,
            backgroundColor: context.colors.primary,
            screen: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.error,
                    color: context.brandColors.textSecondary,
                    size: 48,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    notifier.errorMessage ?? 'Có lỗi xảy ra',
                    style: AppTextStyles.textContent2.copyWith(
                      color: context.brandColors.textSecondary,
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
          isShowDrawer: true,
          titleWidget: Text(
            '${notifier.completedTerms.length}/${notifier.termsCount}',
            style: AppTextStyles.textContent1.copyWith(
              color: context.brandColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          actionsWidget: [
            GestureDetector(
              onTap: () => _showClearDataDialog(notifier),
              child: Icon(
                Icons.delete,
                color: context.brandColors.textPrimary,
                size: 24,
              ),
            ),
            GestureDetector(
              onTap: () => _completeCourse(notifier),
              child: Icon(
                Icons.check,
                color:
                    notifier.isDataValid
                        ? context.brandColors.textPrimary
                        : context.brandColors.textPrimary.withOpacity(0.5),
                size: 24,
              ),
            ),
          ],
          backgroundColor: context.colors.primary,
          screen: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: AppPad.h16v20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildCourseInfo(notifier),
                      const SizedBox(height: 24),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          GestureDetector(
                            onTap: () => _showImportDataDialog(notifier),
                            child: Container(
                              padding: AppPad.h12v8,
                              decoration: BoxDecoration(
                                color: context.brandColors.searchBarBackground,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(
                                  color: context.brandColors.borderColor
                                      .withOpacity(0.3),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.upload_file,
                                    color: context.brandColors.searchBarIcon,
                                    size: 16,
                                  ),
                                  const SizedBox(width: 6),
                                  Text(
                                    'Nhập',
                                    style: AppTextStyles.textContent2.copyWith(
                                      color: context.brandColors.searchBarText,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          if (!_showDescription)
                            GestureDetector(
                              onTap: () {
                                setState(() {
                                  _showDescription = true;
                                });
                              },
                              child: Container(
                                padding: AppPad.h12v8,
                                decoration: BoxDecoration(
                                  color:
                                      context.brandColors.searchBarBackground,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(
                                    color: context.brandColors.borderColor
                                        .withOpacity(0.3),
                                    width: 1,
                                  ),
                                ),
                                child: Text(
                                  '+ Mô tả',
                                  style: AppTextStyles.textContent2.copyWith(
                                    color: context.brandColors.searchBarText,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 24),
                      _buildTermsList(notifier),
                      const SizedBox(height: 80),
                    ],
                  ),
                ),
              ),
              Container(
                padding: AppPad.h16v12,
                child: Align(
                  alignment: Alignment.centerRight,
                  child: FloatingActionButton(
                    heroTag: "create_course_fab",
                    onPressed: () => _addNewTerm(notifier),
                    backgroundColor: context.brandColors.buttonPrimary,
                    shape: const CircleBorder(),
                    child: Icon(
                      Icons.add,
                      color: context.brandColors.textPrimary,
                      size: 28,
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  void _addNewTerm(CreateCourseNotifier notifier) {
    notifier.addTerm();
  }

  void _updateCourseInfo(CreateCourseNotifier notifier) {
    notifier.updateCourseInfo(
      topic: _topicController.text,
      title: _titleController.text,
      description:
          _descriptionController.text.isNotEmpty
              ? _descriptionController.text
              : null,
    );
    notifier.saveData();
  }

  void _completeCourse(CreateCourseNotifier notifier) async {
    _updateCourseInfo(notifier);

    if (!_validateCourseData(notifier)) {
      return;
    }

    await notifier.completeCourse();

    _topicController.clear();
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _showDescription = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Đã lưu khóa học!'),
        backgroundColor: context.brandColors.progressValue,
      ),
    );
  }

  bool _validateCourseData(CreateCourseNotifier notifier) {
    if (notifier.courseData.topic.trim().isEmpty) {
      _showValidationError('Vui lòng nhập chủ đề khóa học');
      return false;
    }

    if (notifier.courseData.title.trim().isEmpty) {
      _showValidationError('Vui lòng nhập tiêu đề khóa học');
      return false;
    }

    final validTerms =
        notifier.courseData.terms
            .where(
              (term) =>
                  term.term.trim().isNotEmpty ||
                  term.definition.trim().isNotEmpty,
            )
            .toList();

    if (validTerms.isEmpty) {
      _showValidationError('Vui lòng thêm ít nhất một thuật ngữ');
      return false;
    }

    for (int i = 0; i < notifier.courseData.terms.length; i++) {
      final term = notifier.courseData.terms[i];
      final hasTerm = term.term.trim().isNotEmpty;
      final hasDefinition = term.definition.trim().isNotEmpty;

      if (!hasTerm && !hasDefinition) {
        continue;
      }

      if (hasTerm && !hasDefinition) {
        _showValidationError('Thuật ngữ ${i + 1}: Vui lòng nhập định nghĩa');
        return false;
      }

      if (!hasTerm && hasDefinition) {
        _showValidationError('Thuật ngữ ${i + 1}: Vui lòng nhập thuật ngữ');
        return false;
      }
    }

    return true;
  }

  void _showValidationError(String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.brandColors.cardBackground,
          title: Row(
            children: [
              Icon(
                Icons.error,
                color: context.brandColors.buttonDestructive,
                size: 24,
              ),
              const SizedBox(width: 8),
              Text(
                'Lỗi xác thực',
                style: TextStyle(color: context.brandColors.textPrimary),
              ),
            ],
          ),
          content: Text(
            message,
            style: TextStyle(color: context.brandColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Đóng',
                style: TextStyle(color: context.brandColors.buttonPrimary),
              ),
            ),
          ],
        );
      },
    );
  }

  void _showClearDataDialog(CreateCourseNotifier notifier) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: context.brandColors.cardBackground,
          title: Text(
            'Xóa dữ liệu',
            style: TextStyle(color: context.brandColors.textPrimary),
          ),
          content: Text(
            'Bạn có chắc chắn muốn xóa tất cả dữ liệu đã nhập?',
            style: TextStyle(color: context.brandColors.textSecondary),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Hủy',
                style: TextStyle(color: context.brandColors.buttonPrimary),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearAllData(notifier);
              },
              child: Text(
                'Xóa',
                style: TextStyle(color: context.brandColors.buttonDestructive),
              ),
            ),
          ],
        );
      },
    );
  }

  void _clearAllData(CreateCourseNotifier notifier) {
    _topicController.clear();
    _titleController.clear();
    _descriptionController.clear();

    notifier.clearData();

    setState(() {
      _showDescription = false;
    });
  }

  Widget _buildCourseInfo(CreateCourseNotifier notifier) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _topicController,
          onChanged: (value) => _updateCourseInfo(notifier),
          style: AppTextStyles.textContent2.copyWith(
            color: context.brandColors.searchBarText,
          ),
          decoration: InputDecoration(
            hintText: 'Chủ đề, chương, đơn vị',
            hintStyle: AppTextStyles.textContent2.copyWith(
              color: context.brandColors.searchBarText.withOpacity(0.6),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: context.brandColors.borderColor,
                width: 1,
              ),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: context.brandColors.borderColor,
                width: 1,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: context.brandColors.buttonPrimary,
                width: 2,
              ),
            ),
          ),
        ),
        const SizedBox(height: 24),

        Text(
          'TIÊU ĐỀ',
          style: AppTextStyles.textContent3.copyWith(
            color: context.brandColors.textPrimary,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          onChanged: (value) => _updateCourseInfo(notifier),
          style: AppTextStyles.textContent1.copyWith(
            color: context.brandColors.searchBarText,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            border: UnderlineInputBorder(
              borderSide: BorderSide(
                color: context.brandColors.borderColor,
                width: 1,
              ),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: context.brandColors.borderColor,
                width: 1,
              ),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(
                color: context.brandColors.buttonPrimary,
                width: 2,
              ),
            ),
          ),
        ),
        if (_showDescription) ...[
          const SizedBox(height: 24),
          Text(
            'MÔ TẢ',
            style: AppTextStyles.textContent3.copyWith(
              color: context.brandColors.textPrimary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            onChanged: (value) => _updateCourseInfo(notifier),
            style: AppTextStyles.textContent2.copyWith(
              color: context.brandColors.searchBarText,
            ),
            decoration: InputDecoration(
              hintText: 'Nhập mô tả cho khóa học...',
              hintStyle: AppTextStyles.textContent2.copyWith(
                color: context.brandColors.searchBarText.withOpacity(0.6),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: context.brandColors.borderColor,
                  width: 1,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: context.brandColors.borderColor,
                  width: 1,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: context.brandColors.buttonPrimary,
                  width: 2,
                ),
              ),
            ),
            maxLines: 3,
          ),
        ],
      ],
    );
  }

  Widget _buildTermsList(CreateCourseNotifier notifier) {
    return Column(
      children:
          notifier.courseData.terms.asMap().entries.map((entry) {
            int index = entry.key;
            TermData term = entry.value;
            return _buildTermItem(term, index, notifier);
          }).toList(),
    );
  }

  Widget _buildTermItem(
    TermData term,
    int index,
    CreateCourseNotifier notifier,
  ) {
    final termController = TextEditingController(text: term.term);
    final definitionController = TextEditingController(text: term.definition);

    return Dismissible(
      key: Key('term_${term.id}'),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: AppPad.h16,
        decoration: BoxDecoration(
          color: context.brandColors.buttonDestructive,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete,
          color: context.brandColors.textPrimary,
          size: 24,
        ),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: AppPad.h16,
        decoration: BoxDecoration(
          color: context.brandColors.buttonDestructive,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          Icons.delete,
          color: context.brandColors.textPrimary,
          size: 24,
        ),
      ),
      onDismissed: (direction) {
        notifier.removeTerm(index);
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: AppPad.h16v20,
        decoration: BoxDecoration(
          color: context.brandColors.cardBackground,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.brandColors.borderColor.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'THUẬT NGỮ',
              style: AppTextStyles.textContent3.copyWith(
                color: context.brandColors.textPrimary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: termController,
              onChanged: (value) {
                final updatedTerm = term.copyWith(term: value);
                notifier.updateTerm(index, updatedTerm);
                notifier.saveData();
              },
              style: AppTextStyles.textContent2.copyWith(
                color: context.brandColors.searchBarText,
              ),
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: context.brandColors.borderColor,
                    width: 1,
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: context.brandColors.borderColor,
                    width: 1,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: context.brandColors.buttonPrimary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'ĐỊNH NGHĨA',
              style: AppTextStyles.textContent3.copyWith(
                color: context.brandColors.textPrimary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: definitionController,
              onChanged: (value) {
                final updatedTerm = term.copyWith(definition: value);
                notifier.updateTerm(index, updatedTerm);
                notifier.saveData();
              },
              style: AppTextStyles.textContent2.copyWith(
                color: context.brandColors.searchBarText,
              ),
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: context.brandColors.borderColor,
                    width: 1,
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: context.brandColors.borderColor,
                    width: 1,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: context.brandColors.buttonPrimary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'CHỌN NGÔN NGỮ',
              style: AppTextStyles.textContent3.copyWith(
                color: context.brandColors.textPrimary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                _showLanguagePicker(term, index, notifier);
              },
              child: Container(
                padding: AppPad.v12,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(
                      color: context.brandColors.buttonPrimary,
                      width: 1,
                    ),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      term.language,
                      style: AppTextStyles.textContent2.copyWith(
                        color: context.brandColors.buttonPrimary,
                      ),
                    ),
                    Icon(
                      Icons.arrow_drop_down,
                      color: context.brandColors.buttonPrimary,
                      size: 20,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(
    TermData term,
    int index,
    CreateCourseNotifier notifier,
  ) {
    final languages = ['Tiếng Việt', 'English', '日本語', '한국어', '中文'];

    showModalBottomSheet(
      context: context,
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:
                  languages.map((language) {
                    return ListTile(
                      title: Text(language),
                      onTap: () {
                        final updatedTerm = term.copyWith(language: language);
                        notifier.updateTerm(index, updatedTerm);
                        notifier.saveData();
                        Navigator.pop(context);
                      },
                      trailing:
                          term.language == language
                              ? const Icon(Icons.check)
                              : null,
                    );
                  }).toList(),
            ),
          ),
    );
  }

  void _showImportDataDialog(CreateCourseNotifier notifier) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder:
            (context) => ImportDataScreen(
              onImportData: (parsedTerms) {
                _handleImportedData(parsedTerms, notifier);
              },
            ),
        fullscreenDialog: true,
      ),
    );
  }

  void _handleImportedData(
    List<ParsedTerm> parsedTerms,
    CreateCourseNotifier notifier,
  ) {
    if (parsedTerms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Không có dữ liệu để import'),
          backgroundColor: context.brandColors.warning,
        ),
      );
      return;
    }

    for (final parsedTerm in parsedTerms) {
      final newTerm = TermData(
        id:
            DateTime.now().millisecondsSinceEpoch.toString() +
            parsedTerm.term.hashCode.toString(),
        term: parsedTerm.term,
        definition: parsedTerm.definition,
        language: parsedTerm.language,
      );

      notifier.addTermDirectly(newTerm);
    }

    notifier.saveData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Đã import ${parsedTerms.length} thuật ngữ thành công!'),
        backgroundColor: context.brandColors.progressValue,
      ),
    );
  }
}
