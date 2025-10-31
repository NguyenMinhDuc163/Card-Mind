import 'package:card_mind/init.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/core/theme/app_pad.dart';
import 'package:card_mind/core/theme/app_text_styles.dart';
import 'package:card_mind/modules/course/provider/course_info_notifier.dart';
import 'package:card_mind/modules/course/model/course_data.dart';
import 'package:card_mind/core/helpers/local_storage_helper.dart';
import 'package:card_mind/core/event_service.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';

class EditCourseScreen extends StatefulWidget {
  const EditCourseScreen({super.key});

  static const String routeName = '/EditCourseScreen';

  @override
  State<EditCourseScreen> createState() => _EditCourseScreenState();
}

class _EditCourseScreenState extends State<EditCourseScreen> {
  final TextEditingController _topicController = TextEditingController();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  bool _showDescription = false;
  bool _isInitialized = false;
  String? _courseId;
  CourseData? _originalCourseData;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeData();
    });
  }

  Future<void> _initializeData() async {
    _courseId = ModalRoute.of(context)?.settings.arguments as String?;

    if (_courseId != null) {
      final notifier = Provider.of<CourseInfoNotifier>(context, listen: false);
      await notifier.initializeData(courseId: _courseId);

      if (notifier.courseData != null) {
        _originalCourseData = notifier.courseData;
        _loadDataToControllers(notifier.courseData!);

        if (mounted) {
          setState(() {
            _isInitialized = true;
          });
        }
      }
    }
  }

  void _loadDataToControllers(CourseData courseData) {
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
    return Consumer<CourseInfoNotifier>(
      builder: (context, notifier, child) {
        if (!_isInitialized || notifier.isLoading) {
          return FunctionScreenTemplate(
            isShowAppBar: false,
            backgroundColor: context.colors.primary,
            screen: const Center(
              child: CircularProgressIndicator(color: Colors.white),
            ),
          );
        }

        if (notifier.hasError || _originalCourseData == null) {
          return FunctionScreenTemplate(
            isShowAppBar: false,
            backgroundColor: context.colors.primary,
            screen: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error, color: context.colors.onPrimary, size: 48),
                  const SizedBox(height: 16),
                  Text(
                    notifier.errorMessage ??
                        'course_edit.error_loading_course'.tr(),
                    style: AppTextStyles.textContent2.copyWith(
                      color: context.colors.onPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => _initializeData(),
                    child: Text('course_info.retry'.tr()),
                  ),
                ],
              ),
            ),
          );
        }

        return FunctionScreenTemplate(
          isShowAppBar: false,
          backgroundColor: context.colors.primary,
          screen: Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  padding: AppPad.h16v20,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildHeader(),
                      const SizedBox(height: 24),
                      _buildCourseInfo(),
                      const SizedBox(height: 24),
                      _buildAdditionalFeatures(),
                      const SizedBox(height: 24),
                      _buildTermsList(),
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
                    heroTag: "edit_course_fab",
                    onPressed: () => _addNewTerm(),
                    backgroundColor: Colors.blue,
                    shape: const CircleBorder(),
                    child: Icon(
                      Icons.add,
                      color: context.colors.onPrimary,
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

  void _addNewTerm() {
    setState(() {
      _originalCourseData = _originalCourseData!.copyWith(
        terms: [..._originalCourseData!.terms, TermData.createNew()],
      );
    });
  }

  void _updateCourseInfo() {
    setState(() {
      _originalCourseData = _originalCourseData!.copyWith(
        topic: _topicController.text,
        title: _titleController.text,
        description:
            _descriptionController.text.isNotEmpty
                ? _descriptionController.text
                : null,
        updatedAt: DateTime.now(),
      );
    });
  }

  void _saveCourse() async {
    if (_originalCourseData == null) return;

    try {
      final courseKeys =
          LocalStorageHelper.getValue('course_keys') as List<dynamic>? ?? [];
      String? actualCourseKey;

      for (final key in courseKeys) {
        final courseData = LocalStorageHelper.getValue(key as String);
        if (courseData != null) {
          final Map<String, dynamic> jsonData = Map<String, dynamic>.from(
            courseData,
          );
          if (jsonData['id'] == _courseId) {
            actualCourseKey = key.toString();
            break;
          }
        }
      }

      if (actualCourseKey != null) {
        await LocalStorageHelper.setValue(
          actualCourseKey,
          _originalCourseData!.toJson(),
        );

        EventService().emitCourseEvent(
          CourseEvent(
            type: CourseEventType.courseUpdated,
            courseId: _courseId!,
          ),
        );

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('course_edit.update_success'.tr())),
          );

          Navigator.of(context).pop();
        }
      } else {
        throw Exception(tr('course_edit.update_not_found'));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('course_edit.error_generic'.tr(args: [e.toString()])),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        GestureDetector(
          onTap: () => Navigator.pop(context),
          child: Icon(
            Icons.arrow_back,
            color: context.colors.onPrimary,
            size: 24,
          ),
        ),
        Text(
          'course_edit.title'.tr(),
          style: AppTextStyles.textContent1.copyWith(
            color: context.colors.onPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        Row(
          children: [
            GestureDetector(
              onTap: () {},
              child: Icon(
                Icons.settings,
                color: context.colors.onPrimary,
                size: 24,
              ),
            ),
            const SizedBox(width: 16),
            GestureDetector(
              onTap: _isDataValid() ? _saveCourse : null,
              child: Icon(
                Icons.check,
                color:
                    _isDataValid()
                        ? context.colors.onPrimary
                        : context.colors.onPrimary.withOpacity(0.5),
                size: 24,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCourseInfo() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextField(
          controller: _topicController,
          onChanged: (value) => _updateCourseInfo(),
          style: AppTextStyles.textContent2.copyWith(
            color: context.colors.onPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'course_edit.topic_hint'.tr(),
            hintStyle: AppTextStyles.textContent2.copyWith(
              color: context.colors.onPrimary.withOpacity(0.6),
            ),
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: context.colors.onPrimary, width: 1),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: context.colors.onPrimary, width: 1),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: context.colors.onPrimary, width: 2),
            ),
          ),
        ),
        const SizedBox(height: 24),

        Text(
          'course_edit.title_label'.tr(),
          style: AppTextStyles.textContent3.copyWith(
            color: context.colors.onPrimary,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _titleController,
          onChanged: (value) => _updateCourseInfo(),
          style: AppTextStyles.textContent1.copyWith(
            color: context.colors.onPrimary,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            border: UnderlineInputBorder(
              borderSide: BorderSide(color: context.colors.onPrimary, width: 1),
            ),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: context.colors.onPrimary, width: 1),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: context.colors.onPrimary, width: 2),
            ),
          ),
        ),
        if (_showDescription) ...[
          const SizedBox(height: 24),
          Text(
            'course_edit.description_label'.tr(),
            style: AppTextStyles.textContent3.copyWith(
              color: context.colors.onPrimary,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _descriptionController,
            onChanged: (value) => _updateCourseInfo(),
            style: AppTextStyles.textContent2.copyWith(
              color: context.colors.onPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'course_edit.description_hint'.tr(),
              hintStyle: AppTextStyles.textContent2.copyWith(
                color: context.colors.onPrimary.withOpacity(0.6),
              ),
              border: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: context.colors.onPrimary,
                  width: 1,
                ),
              ),
              enabledBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: context.colors.onPrimary,
                  width: 1,
                ),
              ),
              focusedBorder: UnderlineInputBorder(
                borderSide: BorderSide(
                  color: context.colors.onPrimary,
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

  Widget _buildAdditionalFeatures() {
    return Row(
      children: [
        Expanded(
          child: GestureDetector(
            onTap: () {},
            child: Row(
              children: [
                Icon(
                  Icons.document_scanner,
                  color: context.colors.onPrimary,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  'course_edit.scan_document'.tr(),
                  style: AppTextStyles.textContent2.copyWith(
                    color: context.colors.onPrimary,
                  ),
                ),
              ],
            ),
          ),
        ),
        Container(
          padding: AppPad.h12v8,
          decoration: BoxDecoration(
            color: Colors.amber,
            borderRadius: BorderRadius.circular(6),
          ),
          child: Icon(Icons.lock, color: context.colors.onPrimary, size: 16),
        ),
        const SizedBox(width: 16),
        if (!_showDescription)
          GestureDetector(
            onTap: () {
              setState(() {
                _showDescription = true;
              });
            },
            child: Text(
              'course_edit.add_description'.tr(),
              style: AppTextStyles.textContent2.copyWith(
                color: context.colors.onPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildTermsList() {
    if (_originalCourseData == null) return const SizedBox.shrink();

    return Column(
      children:
          _originalCourseData!.terms.asMap().entries.map((entry) {
            int index = entry.key;
            TermData term = entry.value;
            return _buildTermItem(term, index);
          }).toList(),
    );
  }

  Widget _buildTermItem(TermData term, int index) {
    final termController = TextEditingController(text: term.term);
    final definitionController = TextEditingController(text: term.definition);

    return Dismissible(
      key: Key('term_${term.id}'),
      direction: DismissDirection.horizontal,
      background: Container(
        alignment: Alignment.centerLeft,
        padding: AppPad.h16,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete, color: context.colors.onPrimary, size: 24),
      ),
      secondaryBackground: Container(
        alignment: Alignment.centerRight,
        padding: AppPad.h16,
        decoration: BoxDecoration(
          color: Colors.red,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(Icons.delete, color: context.colors.onPrimary, size: 24),
      ),
      onDismissed: (direction) {
        setState(() {
          final updatedTerms = List<TermData>.from(_originalCourseData!.terms);
          updatedTerms.removeAt(index);
          _originalCourseData = _originalCourseData!.copyWith(
            terms: updatedTerms,
          );
        });
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 16),
        padding: AppPad.h16v20,
        decoration: BoxDecoration(
          color: context.colors.primary.withOpacity(0.8),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: context.colors.onPrimary.withOpacity(0.2),
            width: 1,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'course_edit.term_label'.tr(),
              style: AppTextStyles.textContent3.copyWith(
                color: context.colors.onPrimary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: termController,
              onChanged: (value) {
                final updatedTerm = term.copyWith(term: value);
                setState(() {
                  final updatedTerms = List<TermData>.from(
                    _originalCourseData!.terms,
                  );
                  updatedTerms[index] = updatedTerm;
                  _originalCourseData = _originalCourseData!.copyWith(
                    terms: updatedTerms,
                  );
                });
              },
              style: AppTextStyles.textContent2.copyWith(
                color: context.colors.onPrimary,
              ),
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: context.colors.onPrimary,
                    width: 1,
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: context.colors.onPrimary,
                    width: 1,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: context.colors.onPrimary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'course_edit.definition_label'.tr(),
              style: AppTextStyles.textContent3.copyWith(
                color: context.colors.onPrimary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: definitionController,
              onChanged: (value) {
                final updatedTerm = term.copyWith(definition: value);
                setState(() {
                  final updatedTerms = List<TermData>.from(
                    _originalCourseData!.terms,
                  );
                  updatedTerms[index] = updatedTerm;
                  _originalCourseData = _originalCourseData!.copyWith(
                    terms: updatedTerms,
                  );
                });
              },
              style: AppTextStyles.textContent2.copyWith(
                color: context.colors.onPrimary,
              ),
              decoration: InputDecoration(
                border: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: context.colors.onPrimary,
                    width: 1,
                  ),
                ),
                enabledBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: context.colors.onPrimary,
                    width: 1,
                  ),
                ),
                focusedBorder: UnderlineInputBorder(
                  borderSide: BorderSide(
                    color: context.colors.onPrimary,
                    width: 2,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            Text(
              'course_edit.language_label'.tr(),
              style: AppTextStyles.textContent3.copyWith(
                color: context.colors.onPrimary,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 8),
            GestureDetector(
              onTap: () {
                _showLanguagePicker(term, index);
              },
              child: Container(
                padding: AppPad.v12,
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide(color: Colors.blue, width: 1),
                  ),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      _languageDisplay(term.language),
                      style: AppTextStyles.textContent2.copyWith(
                        color: Colors.blue,
                      ),
                    ),
                    Icon(Icons.arrow_drop_down, color: Colors.blue, size: 20),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showLanguagePicker(TermData term, int index) {
    final languages = [
      'language.vietnamese'.tr(),
      'language.english'.tr(),
      'language.japanese'.tr(),
      'language.korean'.tr(),
      'language.chinese'.tr(),
    ];

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
                        setState(() {
                          final updatedTerms = List<TermData>.from(
                            _originalCourseData!.terms,
                          );
                          updatedTerms[index] = updatedTerm;
                          _originalCourseData = _originalCourseData!.copyWith(
                            terms: updatedTerms,
                          );
                        });
                        Navigator.pop(context);
                      },
                      trailing:
                          _normalizeLanguage(term.language) ==
                                  _normalizeLanguage(language)
                              ? const Icon(Icons.check)
                              : null,
                    );
                  }).toList(),
            ),
          ),
    );
  }

  String _languageDisplay(String language) {
    switch (language) {
      case 'Tiếng Việt':
      case 'vi':
      case 'Vietnamese':
      case 'language.vietnamese':
        return 'language.vietnamese'.tr();
      case 'English':
      case 'en':
      case 'Tiếng Anh':
        return 'language.english'.tr();
      case '日本語':
      case 'ja':
      case 'Tiếng Nhật':
        return 'language.japanese'.tr();
      case '한국어':
      case 'ko':
      case 'Tiếng Hàn':
        return 'language.korean'.tr();
      case '中文':
      case 'zh':
      case 'Tiếng Trung':
        return 'language.chinese'.tr();
      default:
        return language;
    }
  }

  String _normalizeLanguage(String language) {
    switch (language) {
      case 'Tiếng Việt':
      case 'Vietnamese':
      case 'language.vietnamese':
        return 'vi';
      case 'English':
      case 'Tiếng Anh':
        return 'en';
      case '日本語':
      case 'Tiếng Nhật':
        return 'ja';
      case '한국어':
      case 'Tiếng Hàn':
        return 'ko';
      case '中文':
      case 'Tiếng Trung':
        return 'zh';
      default:
        return language;
    }
  }

  bool _isDataValid() {
    if (_originalCourseData == null) return false;

    return _originalCourseData!.topic.isNotEmpty &&
        _originalCourseData!.title.isNotEmpty &&
        _originalCourseData!.terms.isNotEmpty &&
        _originalCourseData!.terms.every(
          (term) => term.term.isNotEmpty && term.definition.isNotEmpty,
        );
  }
}
