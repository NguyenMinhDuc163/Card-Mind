import 'package:card_mind/init.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/core/theme/app_pad.dart';
import 'package:card_mind/core/theme/app_text_styles.dart';
import 'package:card_mind/modules/create_course/provider/create_course_notifier.dart';
import 'package:card_mind/modules/create_course/model/create_course_data.dart';
import 'package:card_mind/modules/create_course/model/import_data_config.dart';
import 'package:card_mind/modules/create_course/screen/import_data_screen.dart';
import 'package:card_mind/providers/auth_provider.dart';
import 'package:easy_localization/easy_localization.dart';
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
                    notifier.errorMessage ??
                        'create_course.error_occurred'.tr(),
                    style: AppTextStyles.textContent2.copyWith(
                      color: context.brandColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _initializeData(),
                    child: Text('create_course.retry'.tr()),
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
                                    'create_course.import_button'.tr(),
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
                                  'create_course.add_description'.tr(),
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

    // Lấy tên người dùng nếu đã đăng nhập
    final authProvider = Provider.of<AuthProvider>(context, listen: false);
    final author =
        authProvider.isSignedIn
            ? (authProvider.displayName ??
                authProvider.email ??
                'create_course.author_default'.tr())
            : 'create_course.author_default'.tr();

    print('📝 [CreateCourseScreen] Completing course...');
    await notifier.completeCourse(author: author);
    print('✅ [CreateCourseScreen] Course completed, sync triggered');

    _topicController.clear();
    _titleController.clear();
    _descriptionController.clear();
    setState(() {
      _showDescription = false;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('create_course.snackbar_saved'.tr()),
        backgroundColor: context.brandColors.progressValue,
      ),
    );
  }

  bool _validateCourseData(CreateCourseNotifier notifier) {
    if (notifier.courseData.topic.trim().isEmpty) {
      _showValidationError('create_course.validation_topic'.tr());
      return false;
    }

    if (notifier.courseData.title.trim().isEmpty) {
      _showValidationError('create_course.validation_title'.tr());
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
      _showValidationError('create_course.validation_no_terms'.tr());
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
        _showValidationError(
          'create_course.validation_missing_definition'.tr(
            args: [(i + 1).toString()],
          ),
        );
        return false;
      }

      if (!hasTerm && hasDefinition) {
        _showValidationError(
          'create_course.validation_missing_term'.tr(
            args: [(i + 1).toString()],
          ),
        );
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Row(
            children: [
              Icon(
                Icons.error_outline,
                color: context.brandColors.buttonDestructive,
                size: 28,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'create_course.validation_dialog_title'.tr(),
                  style: AppTextStyles.textContent1.copyWith(
                    color: context.brandColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          content: Text(
            message,
            style: AppTextStyles.textContent2.copyWith(
              color: context.brandColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
              child: Text(
                'common.close'.tr(),
                style: AppTextStyles.textContent2.copyWith(
                  color: context.brandColors.buttonPrimary,
                  fontWeight: FontWeight.w600,
                ),
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
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          title: Text(
            'create_course.clear_data_title'.tr(),
            style: AppTextStyles.textContent1.copyWith(
              color: context.brandColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
          content: Text(
            'create_course.clear_data_message'.tr(),
            style: AppTextStyles.textContent2.copyWith(
              color: context.brandColors.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text(
                'common.cancel'.tr(),
                style: AppTextStyles.textContent2.copyWith(
                  color: context.brandColors.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _clearAllData(notifier);
              },
              style: TextButton.styleFrom(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              ),
              child: Text(
                'common.delete'.tr(),
                style: AppTextStyles.textContent2.copyWith(
                  color: context.brandColors.buttonDestructive,
                  fontWeight: FontWeight.w600,
                ),
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
            hintText: 'create_course.field_topic_hint'.tr(),
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
          'create_course.field_title_label'.tr(),
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
            'create_course.field_description_label'.tr(),
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
              hintText: 'create_course.field_description_hint'.tr(),
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
    return Dismissible(
      key: Key('term_${term.id}_$index'),
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
              'create_course.term_label'.tr(),
              style: AppTextStyles.textContent3.copyWith(
                color: context.brandColors.textPrimary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: Key('term_input_${term.id}'),
              initialValue: term.term,
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
              'create_course.definition_label'.tr(),
              style: AppTextStyles.textContent3.copyWith(
                color: context.brandColors.textPrimary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            TextFormField(
              key: Key('definition_input_${term.id}'),
              initialValue: term.definition,
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

            Row(
              children: [
                Text(
                  'create_course.language_label'.tr(),
                  style: AppTextStyles.textContent3.copyWith(
                    color: context.brandColors.textPrimary,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 1.2,
                  ),
                ),
                const SizedBox(width: 4),
                Icon(
                  Icons.arrow_drop_down,
                  color: context.brandColors.textPrimary,
                  size: 16,
                ),
              ],
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
                      color: context.brandColors.borderColor,
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
                        color: context.brandColors.textPrimary,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Icon(
                      Icons.keyboard_arrow_down,
                      color: context.brandColors.textPrimary,
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
    final languages = [
      'language.vietnamese'.tr(),
      'language.english'.tr(),
    ];

    showModalBottomSheet(
      context: context,
      backgroundColor: context.brandColors.cardBackground,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder:
          (context) => Container(
            padding: const EdgeInsets.all(16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: context.brandColors.borderColor,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                Text(
                  'create_course.language_label'.tr(),
                  style: AppTextStyles.textContent1.copyWith(
                    color: context.brandColors.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 16),
                ...languages.map((language) {
                  final isSelected = term.language == language;
                  return ListTile(
                    title: Text(
                      language,
                      style: AppTextStyles.textContent2.copyWith(
                        color: context.brandColors.textPrimary,
                        fontWeight:
                            isSelected ? FontWeight.w600 : FontWeight.w400,
                      ),
                    ),
                    onTap: () {
                      final updatedTerm = term.copyWith(language: language);
                      notifier.updateTerm(index, updatedTerm);
                      notifier.saveData();
                      Navigator.pop(context);
                    },
                    trailing: isSelected
                        ? Icon(
                            Icons.check,
                            color: context.brandColors.buttonPrimary,
                          )
                        : null,
                  );
                }),
                const SizedBox(height: 16),
              ],
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
          content: Text('create_course_import.snackbar_empty'.tr()),
          backgroundColor: context.brandColors.warning,
        ),
      );
      return;
    }

    for (int i = 0; i < parsedTerms.length; i++) {
      final parsedTerm = parsedTerms[i];
      final newTerm = TermData(
        id: '${DateTime.now().millisecondsSinceEpoch}_$i',
        term: parsedTerm.term,
        definition: parsedTerm.definition,
        language: parsedTerm.language,
      );

      notifier.addTermDirectly(newTerm);
    }

    notifier.saveData();

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'create_course_import.snackbar_success'.tr(
            args: [parsedTerms.length.toString()],
          ),
        ),
        backgroundColor: context.brandColors.progressValue,
      ),
    );
  }
}
