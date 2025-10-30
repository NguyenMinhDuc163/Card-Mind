import 'package:card_mind/core/services/spaced_repetition_service.dart';
import 'package:card_mind/core/theme/theme_extensions.dart';
import 'package:card_mind/init.dart';
import 'package:flutter/material.dart';

class SpacedRepetitionSettingsScreen extends StatefulWidget {
  const SpacedRepetitionSettingsScreen({super.key});

  static const String routeName = '/SpacedRepetitionSettingsScreen';

  @override
  State<SpacedRepetitionSettingsScreen> createState() =>
      _SpacedRepetitionSettingsScreenState();
}

class _SpacedRepetitionSettingsScreenState
    extends State<SpacedRepetitionSettingsScreen> {
  final _service = SpacedRepetitionService();

  late String _timeUnit;
  late int _interval1;
  late int _interval2;
  late int _maxInterval;
  late int _autoRefreshInterval;

  @override
  void initState() {
    super.initState();
    _loadConfig();
    // Đảm bảo các giá trị interval phù hợp với timeUnit hiện tại
    _adjustIntervalsForTimeUnit();
  }

  void _loadConfig() {
    _timeUnit = _service.timeUnit;
    _interval1 = _service.interval1;
    _interval2 = _service.interval2;
    _maxInterval = _service.maxInterval;
    _autoRefreshInterval = _service.autoRefreshInterval;
  }

  void _adjustIntervalsForTimeUnit() {
    if (_timeUnit == 'minutes') {
      // Điều chỉnh về giá trị phù hợp cho phút
      _interval1 = _interval1.clamp(1, 10);
      _interval2 = _interval2.clamp(1, 20);
      _maxInterval = _maxInterval.clamp(20, 60);
    } else {
      // Điều chỉnh về giá trị phù hợp cho ngày
      _interval1 = _interval1.clamp(1, 7);
      _interval2 = _interval2.clamp(1, 14);
      _maxInterval = _maxInterval.clamp(30, 365);
    }
  }

  Future<void> _saveConfig() async {
    await _service.updateConfig(
      timeUnit: _timeUnit,
      interval1: _interval1,
      interval2: _interval2,
      maxInterval: _maxInterval,
      autoRefreshInterval: _autoRefreshInterval,
    );

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã lưu cấu hình thành công!'),
          backgroundColor: context.brandColors.progressValue,
        ),
      );
    }
  }

  Future<void> _resetToDefault() async {
    await _service.resetToDefault();
    setState(() {
      _loadConfig();
    });

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Đã reset về mặc định!'),
          backgroundColor: context.brandColors.progressValue,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: context.colors.primary,
      appBar: AppBar(
        backgroundColor: context.colors.primary,
        title: Text(
          'Cài đặt Spaced Repetition',
          style: TextStyle(color: context.colors.onPrimary),
        ),
        iconTheme: IconThemeData(color: context.colors.onPrimary),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: _resetToDefault,
            tooltip: 'Reset về mặc định',
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: AppPad.a16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Info card
            Card(
              color: context.brandColors.cardBackground,
              child: Padding(
                padding: AppPad.a16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.info_outline,
                          color: context.brandColors.progressValue,
                        ),
                        SizedBox(width: 8),
                        Text(
                          'Thông tin',
                          style: AppTextStyles.textHeader3.copyWith(
                            color: context.brandColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                    SizedBox(height: 8),
                    Text(
                      'Cấu hình tham số cho thuật toán Spaced Repetition. '
                      'Thay đổi sẽ áp dụng cho tất cả flashcard mới.',
                      style: AppTextStyles.textContent3.copyWith(
                        color: context.brandColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 24),

            // Đơn vị thời gian
            _buildSectionTitle('Đơn vị thời gian'),
            Card(
              color: context.brandColors.cardBackground,
              child: Column(
                children: [
                  RadioListTile<String>(
                    title: Text(
                      'Ngày (Production)',
                      style: TextStyle(color: context.brandColors.textPrimary),
                    ),
                    subtitle: Text(
                      'Ôn tập theo ngày - Dành cho sử dụng thực tế',
                      style:
                          TextStyle(color: context.brandColors.textSecondary),
                    ),
                    value: 'days',
                    groupValue: _timeUnit,
                    onChanged: (value) {
                      setState(() {
                        _timeUnit = value!;
                        _adjustIntervalsForTimeUnit();
                      });
                    },
                    activeColor: context.brandColors.progressValue,
                  ),
                  Divider(height: 1),
                  RadioListTile<String>(
                    title: Text(
                      'Phút (Test)',
                      style: TextStyle(color: context.brandColors.textPrimary),
                    ),
                    subtitle: Text(
                      'Ôn tập theo phút - Dành cho kiểm thử nhanh',
                      style:
                          TextStyle(color: context.brandColors.textSecondary),
                    ),
                    value: 'minutes',
                    groupValue: _timeUnit,
                    onChanged: (value) {
                      setState(() {
                        _timeUnit = value!;
                        _adjustIntervalsForTimeUnit();
                      });
                    },
                    activeColor: context.brandColors.progressValue,
                  ),
                ],
              ),
            ),

            SizedBox(height: 24),

            // Intervals
            _buildSectionTitle('Khoảng thời gian ôn tập'),

            _buildSliderSetting(
              title: 'Interval lần 1',
              subtitle:
                  'Ôn lại sau $_interval1 ${_timeUnit == "days" ? "ngày" : "phút"}',
              value: _interval1.toDouble(),
              min: 1,
              max: _timeUnit == 'days' ? 7 : 10,
              divisions: (_timeUnit == 'days' ? 6 : 9),
              onChanged: (value) {
                setState(() => _interval1 = value.round());
              },
            ),

            _buildSliderSetting(
              title: 'Interval lần 2',
              subtitle:
                  'Ôn lại sau $_interval2 ${_timeUnit == "days" ? "ngày" : "phút"}',
              value: _interval2.toDouble(),
              min: 1,
              max: _timeUnit == 'days' ? 14 : 20,
              divisions: (_timeUnit == 'days' ? 13 : 19),
              onChanged: (value) {
                setState(() => _interval2 = value.round());
              },
            ),

            _buildSliderSetting(
              title: 'Interval tối đa',
              subtitle:
                  'Tối đa $_maxInterval ${_timeUnit == "days" ? "ngày" : "phút"}',
              value: _maxInterval.toDouble(),
              min: _timeUnit == 'days' ? 30 : 20,
              max: _timeUnit == 'days' ? 365 : 60,
              divisions: _timeUnit == 'days' ? 67 : 40,
              onChanged: (value) {
                setState(() => _maxInterval = value.round());
              },
            ),

            SizedBox(height: 24),

            // Auto Refresh Interval
            _buildSectionTitle('Tự động làm mới dữ liệu'),
            _buildSliderSetting(
              title: 'Khoảng thời gian tự động làm mới',
              subtitle: 'Làm mới mỗi $_autoRefreshInterval giây',
              value: _autoRefreshInterval.toDouble(),
              min: 10,
              max: 300,
              divisions: 29,
              onChanged: (value) {
                setState(() => _autoRefreshInterval = value.round());
              },
            ),

            SizedBox(height: 24),

            // Timeline preview
            _buildSectionTitle('Xem trước timeline'),
            Card(
              color: context.brandColors.cardBackground,
              child: Padding(
                padding: AppPad.a16,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildTimelineItem(
                      'Lần 1',
                      '$_interval1 ${_timeUnit == "days" ? "ngày" : "phút"}',
                    ),
                    _buildTimelineItem(
                      'Lần 2',
                      '$_interval2 ${_timeUnit == "days" ? "ngày" : "phút"}',
                    ),
                    _buildTimelineItem(
                      'Lần 3',
                      '~${(_interval2 * 2.5).round()} ${_timeUnit == "days" ? "ngày" : "phút"} (${_interval2} × 2.5)',
                    ),
                    _buildTimelineItem(
                      'Max',
                      '$_maxInterval ${_timeUnit == "days" ? "ngày" : "phút"}',
                    ),
                  ],
                ),
              ),
            ),

            SizedBox(height: 32),

            // Nút lưu
            ElevatedButton(
              onPressed: _saveConfig,
              style: ElevatedButton.styleFrom(
                backgroundColor: context.brandColors.buttonPrimary,
                padding: EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Lưu cấu hình',
                style: AppTextStyles.textHeader3.copyWith(
                  color: context.brandColors.textPrimary,
                ),
              ),
            ),

            SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, left: 4),
      child: Text(
        title,
        style: AppTextStyles.textHeader3.copyWith(
          color: context.brandColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSliderSetting({
    required String title,
    required String subtitle,
    required double value,
    required double min,
    required double max,
    required int divisions,
    required ValueChanged<double> onChanged,
  }) {
    return Card(
      color: context.brandColors.cardBackground,
      child: Padding(
        padding: AppPad.a16,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: AppTextStyles.textContent2.copyWith(
                color: context.brandColors.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
            SizedBox(height: 4),
            Text(
              subtitle,
              style: AppTextStyles.textContent3.copyWith(
                color: context.brandColors.textSecondary,
              ),
            ),
            Slider(
              value: value,
              min: min,
              max: max,
              divisions: divisions,
              label: value.round().toString(),
              activeColor: context.brandColors.progressValue,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTimelineItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.textContent3.copyWith(
              color: context.brandColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.textContent3.copyWith(
              color: context.brandColors.textPrimary,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}
