import 'package:card_mind/init.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/core/theme/app_pad.dart';
import 'package:card_mind/core/theme/app_text_styles.dart';
import 'package:card_mind/modules/create_course/model/import_data_config.dart';
import 'package:card_mind/modules/create_course/services/import_data_service.dart';
import 'package:flutter/material.dart';

class ImportDataScreen extends StatefulWidget {
  final Function(List<ParsedTerm>) onImportData;

  const ImportDataScreen({super.key, required this.onImportData});

  @override
  State<ImportDataScreen> createState() => _ImportDataScreenState();
}

class _ImportDataScreenState extends State<ImportDataScreen> {
  final TextEditingController _dataController = TextEditingController();
  final TextEditingController _customTermDelimiterController =
      TextEditingController();
  final TextEditingController _customCardDelimiterController =
      TextEditingController();

  ImportDataConfig _config = ImportDataConfig.defaultConfig();
  ParsedDataResult? _parseResult;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Parse empty data initially
    _parseData();
  }

  @override
  void dispose() {
    _dataController.dispose();
    _customTermDelimiterController.dispose();
    _customCardDelimiterController.dispose();
    super.dispose();
  }

  void _parseData() {
    setState(() {
      _isLoading = true;
    });

    // Simulate async operation
    Future.delayed(const Duration(milliseconds: 100), () {
      // If no data entered, show empty result without error
      if (_dataController.text.trim().isEmpty) {
        setState(() {
          _parseResult = ParsedDataResult.success([]);
          _isLoading = false;
        });
        return;
      }

      final result = ImportDataService.parseData(_dataController.text, _config);
      setState(() {
        _parseResult = result;
        _isLoading = false;
      });
    });
  }

  void _updateConfig(ImportDataConfig newConfig) {
    setState(() {
      _config = newConfig;
    });
    _parseData();
  }

  void _onImport() {
    // Check if user has entered any data
    if (_dataController.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vui lòng nhập dữ liệu trước khi import'),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    // Check if parsing was successful
    if (_parseResult == null ||
        _parseResult!.hasError ||
        _parseResult!.terms.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            _parseResult?.errorMessage ?? 'Không thể parse dữ liệu',
          ),
          backgroundColor: Colors.red,
        ),
      );
      return;
    }

    widget.onImportData(_parseResult!.terms);
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return FunctionScreenTemplate(
      titleWidget: const Text(
        'Nhập dữ liệu',
        style: TextStyle(
          color: Colors.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),
      leadingWidget: GestureDetector(
        onTap: () => Navigator.of(context).pop(),
        child: const Icon(Icons.close, color: Colors.white, size: 24),
      ),
      backgroundColor: context.colors.primary,
      screen: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: AppPad.h16v20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDataInputSection(),
                  const SizedBox(height: 24),
                  _buildDelimiterConfigSection(),
                  const SizedBox(height: 24),
                  _buildPreviewSection(),
                ],
              ),
            ),
          ),
          _buildBottomButtons(),
        ],
      ),
    );
  }

  Widget _buildDataInputSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Chép và dán dữ liệu ở đây (từ Word, Excel, Google Docs, v.v.)',
          style: AppTextStyles.textContent2.copyWith(
            color: context.colors.onPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          height: 200,
          decoration: BoxDecoration(
            color: context.colors.primary.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.colors.onPrimary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child: TextField(
            controller: _dataController,
            onChanged: (value) => _parseData(),
            style: AppTextStyles.textContent2.copyWith(
              color: context.colors.onPrimary,
            ),
            decoration: InputDecoration(
              hintText: 'Dán dữ liệu...',
              hintStyle: AppTextStyles.textContent2.copyWith(
                color: context.colors.onPrimary.withOpacity(0.6),
              ),
              border: InputBorder.none,
              contentPadding: AppPad.h16v12,
            ),
            maxLines: null,
            expands: true,
            textAlignVertical: TextAlignVertical.top,
          ),
        ),
      ],
    );
  }

  Widget _buildDelimiterConfigSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'ĐỊNH DẠNG DỮ LIỆU',
          style: AppTextStyles.textContent3.copyWith(
            color: context.colors.onPrimary,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 16),
        // Two column layout
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Left column - Term and Definition delimiter
            Expanded(child: _buildTermDefinitionDelimiterSection()),
            const SizedBox(width: 24),
            // Right column - Card delimiter
            Expanded(child: _buildCardDelimiterSection()),
          ],
        ),
      ],
    );
  }

  Widget _buildTermDefinitionDelimiterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Giữa thuật ngữ và định nghĩa',
          style: AppTextStyles.textContent2.copyWith(
            color: context.colors.onPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildDelimiterOptions(
          currentValue: _config.termDefinitionDelimiter,
          options: const [
            {'value': 'tab', 'label': 'Tab'},
            {'value': 'comma', 'label': 'Phẩy'},
            {'value': 'custom', 'label': 'Tùy chỉnh'},
          ],
          onChanged: (value) {
            _updateConfig(_config.copyWith(termDefinitionDelimiter: value));
          },
          customController: _customTermDelimiterController,
          customValue: _config.customTermDefinitionDelimiter,
          onCustomChanged: (value) {
            _updateConfig(
              _config.copyWith(customTermDefinitionDelimiter: value),
            );
          },
        ),
      ],
    );
  }

  Widget _buildCardDelimiterSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Giữa các thẻ',
          style: AppTextStyles.textContent2.copyWith(
            color: context.colors.onPrimary,
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(height: 8),
        _buildDelimiterOptions(
          currentValue: _config.cardDelimiter,
          options: const [
            {'value': 'newline', 'label': 'Dòng mới'},
            {'value': 'semicolon', 'label': 'Chấm phẩy'},
            {'value': 'custom', 'label': 'Tùy chỉnh'},
          ],
          onChanged: (value) {
            _updateConfig(_config.copyWith(cardDelimiter: value));
          },
          customController: _customCardDelimiterController,
          customValue: _config.customCardDelimiter,
          onCustomChanged: (value) {
            _updateConfig(_config.copyWith(customCardDelimiter: value));
          },
        ),
      ],
    );
  }

  Widget _buildDelimiterOptions({
    required String currentValue,
    required List<Map<String, String>> options,
    required Function(String) onChanged,
    required TextEditingController customController,
    required String customValue,
    required Function(String) onCustomChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Radio buttons arranged vertically
        ...options.map((option) {
          final value = option['value']!;
          final label = option['label']!;
          final isSelected = currentValue == value;

          return Column(
            children: [
              Row(
                children: [
                  Radio<String>(
                    value: value,
                    groupValue: currentValue,
                    onChanged: (newValue) {
                      if (newValue != null) {
                        onChanged(newValue);
                      }
                    },
                    activeColor: Colors.blue,
                  ),
                  Text(
                    label,
                    style: AppTextStyles.textContent2.copyWith(
                      color: context.colors.onPrimary,
                    ),
                  ),
                ],
              ),
              // Custom input field (if custom is selected)
              if (value == 'custom' && isSelected) ...[
                const SizedBox(height: 8),
                Container(
                  margin: const EdgeInsets.only(left: 40),
                  child: TextField(
                    controller: customController,
                    onChanged: onCustomChanged,
                    style: AppTextStyles.textContent2.copyWith(
                      color: context.colors.onPrimary,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Nhập delimiter tùy chỉnh...',
                      hintStyle: AppTextStyles.textContent2.copyWith(
                        color: context.colors.onPrimary.withOpacity(0.6),
                      ),
                      border: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: context.colors.onPrimary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      enabledBorder: UnderlineInputBorder(
                        borderSide: BorderSide(
                          color: context.colors.onPrimary.withOpacity(0.3),
                          width: 1,
                        ),
                      ),
                      focusedBorder: UnderlineInputBorder(
                        borderSide: BorderSide(color: Colors.blue, width: 2),
                      ),
                    ),
                  ),
                ),
              ],
            ],
          );
        }).toList(),
      ],
    );
  }

  Widget _buildPreviewSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'XEM TRƯỚC',
          style: AppTextStyles.textContent3.copyWith(
            color: context.colors.onPrimary,
            fontWeight: FontWeight.w600,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 12),
        Container(
          width: double.infinity,
          padding: AppPad.h16v12,
          decoration: BoxDecoration(
            color: context.colors.primary.withOpacity(0.8),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: context.colors.onPrimary.withOpacity(0.2),
              width: 1,
            ),
          ),
          child:
              _isLoading
                  ? const Center(
                    child: CircularProgressIndicator(
                      color: Colors.white,
                      strokeWidth: 2,
                    ),
                  )
                  : _parseResult == null
                  ? Text(
                    'Chưa có dữ liệu để xem trước',
                    style: AppTextStyles.textContent2.copyWith(
                      color: context.colors.onPrimary.withOpacity(0.6),
                    ),
                  )
                  : _parseResult!.hasError
                  ? Text(
                    'Lỗi: ${_parseResult!.errorMessage}',
                    style: AppTextStyles.textContent2.copyWith(
                      color: Colors.red,
                    ),
                  )
                  : _parseResult!.terms.isEmpty
                  ? Text(
                    'Không tìm thấy thuật ngữ nào',
                    style: AppTextStyles.textContent2.copyWith(
                      color: context.colors.onPrimary.withOpacity(0.6),
                    ),
                  )
                  : Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Tìm thấy ${_parseResult!.terms.length} thuật ngữ:',
                        style: AppTextStyles.textContent2.copyWith(
                          color: context.colors.onPrimary,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 12),
                      // Scrollable list of all terms
                      SizedBox(
                        height: 200, // Fixed height for scrolling
                        child: ListView.builder(
                          itemCount: _parseResult!.terms.length,
                          itemBuilder: (context, index) {
                            final term = _parseResult!.terms[index];
                            return Container(
                              margin: const EdgeInsets.only(bottom: 12),
                              padding: AppPad.h16v12,
                              decoration: BoxDecoration(
                                color: context.colors.primary.withOpacity(0.8),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: context.colors.onPrimary.withOpacity(
                                    0.2,
                                  ),
                                  width: 1,
                                ),
                              ),
                              child: Row(
                                children: [
                                  // Term number
                                  Container(
                                    width: 24,
                                    height: 24,
                                    decoration: BoxDecoration(
                                      color: Colors.blue,
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Center(
                                      child: Text(
                                        '${index + 1}',
                                        style: AppTextStyles.textContent3
                                            .copyWith(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                            ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Term and Definition side by side
                                  Expanded(
                                    child: Row(
                                      children: [
                                        // Term section
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'THUẬT NGỮ',
                                                style: AppTextStyles
                                                    .textContent3
                                                    .copyWith(
                                                      color: context
                                                          .colors
                                                          .onPrimary
                                                          .withOpacity(0.7),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                term.term,
                                                style: AppTextStyles
                                                    .textContent2
                                                    .copyWith(
                                                      color: Colors.blue,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        const SizedBox(width: 16),
                                        // Definition section
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Text(
                                                'ĐỊNH NGHĨA',
                                                style: AppTextStyles
                                                    .textContent3
                                                    .copyWith(
                                                      color: context
                                                          .colors
                                                          .onPrimary
                                                          .withOpacity(0.7),
                                                      fontWeight:
                                                          FontWeight.w500,
                                                    ),
                                              ),
                                              const SizedBox(height: 2),
                                              Text(
                                                term.definition,
                                                style: AppTextStyles
                                                    .textContent2
                                                    .copyWith(
                                                      color:
                                                          context
                                                              .colors
                                                              .onPrimary,
                                                    ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
        ),
      ],
    );
  }

  Widget _buildBottomButtons() {
    return Container(
      padding: AppPad.h16v12,
      decoration: BoxDecoration(
        color: context.colors.primary,
        border: Border(
          top: BorderSide(
            color: context.colors.onPrimary.withOpacity(0.2),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[700],
                foregroundColor: Colors.white,
                padding: AppPad.v12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Hủy nhập'),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _onImport,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
                padding: AppPad.v12,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Nhập'),
            ),
          ),
        ],
      ),
    );
  }
}
