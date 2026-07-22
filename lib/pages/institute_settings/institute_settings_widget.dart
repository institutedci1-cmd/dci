import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/components/shared/app_primary_button.dart';
import 'package:d_c_i_teacher_app/components/text_field/text_field_widget.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/shared/app_colors.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'institute_settings_model.dart';

class InstituteSettingsWidget extends ConsumerStatefulWidget {
  const InstituteSettingsWidget({super.key});

  static String routeName = 'InstituteSettings';
  static String routePath = '/instituteSettings';

  @override
  ConsumerState<InstituteSettingsWidget> createState() => _InstituteSettingsWidgetState();
}

class _InstituteSettingsWidgetState extends ConsumerState<InstituteSettingsWidget> {
  late InstituteSettingsModel _model;
  final _nameController = TextEditingController();
  final _missionController = TextEditingController();
  final _visionController = TextEditingController();
  final _newSubjectController = TextEditingController();
  bool _isSaving = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => InstituteSettingsModel());
    _loadInitialData();
  }

  void _loadInitialData() async {
    final info = await ref.read(configRepositoryProvider).getInstituteInfo();
    if (info != null) {
      _nameController.text = info['name'] ?? '';
      _missionController.text = info['mission'] ?? '';
      _visionController.text = info['vision'] ?? '';
    }
  }

  @override
  void dispose() {
    _model.dispose();
    _nameController.dispose();
    _missionController.dispose();
    _visionController.dispose();
    _newSubjectController.dispose();
    super.dispose();
  }

  Future<void> _saveInfo() async {
    setState(() => _isSaving = true);
    try {
      await ref.read(configRepositoryProvider).updateInstituteInfo({
        'name': _nameController.text.trim(),
        'mission': _missionController.text.trim(),
        'vision': _visionController.text.trim(),
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Institutional info updated.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  Future<void> _addSubject() async {
    final name = _newSubjectController.text.trim();
    if (name.isEmpty) return;
    
    try {
      await ref.read(configRepositoryProvider).addSubject(name);
      _newSubjectController.clear();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Subject added.')));
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final subjectsAsync = ref.watch(subjectsStreamProvider);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: Column(
        children: [
          HeaderSectionWidget(
            title: 'Institute Setup',
            subtitle: 'Global configurations',
            onBackPressed: () async => context.safePop(),
            showActionIcon: false,
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: AppSpacing.pagePadding,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionHeader('General Information'),
                  const SizedBox(height: 12),
                  _buildGeneralForm(context),
                  const SizedBox(height: 24),
                  _buildSectionHeader('Academic Configuration'),
                  const SizedBox(height: 12),
                  _buildSubjectsList(context, subjectsAsync),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: AppTypography.section.copyWith(fontWeight: FontWeight.bold));
  }

  Widget _buildGeneralForm(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        children: [
          TextFieldWidget(
            controller: _nameController,
            label: 'Institute Name',
            hint: 'e.g. Deshmukh Coaching Institute',
            variant: 'outlined',
          ),
          const SizedBox(height: 16),
          TextFieldWidget(
            controller: _missionController,
            label: 'Our Mission',
            hint: 'Describe institutional goals...',
            maxLines: 3,
            variant: 'outlined',
          ),
          const SizedBox(height: 16),
          TextFieldWidget(
            controller: _visionController,
            label: 'Our Vision',
            hint: 'Describe future aspirations...',
            maxLines: 3,
            variant: 'outlined',
          ),
          const SizedBox(height: 24),
          AppPrimaryButton(
            text: 'Save Institutional Info',
            isLoading: _isSaving,
            onPressed: _saveInfo,
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectsList(BuildContext context, AsyncValue<List<String>> subjectsAsync) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Manage Subjects', style: AppTypography.body.copyWith(fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: TextFieldWidget(
                  controller: _newSubjectController,
                  label: '',
                  labelPresent: false,
                  hint: 'Enter subject name...',
                  variant: 'outlined',
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                onPressed: _addSubject,
                icon: const Icon(Icons.add_circle_rounded, color: AppColors.primary, size: 32),
              ),
            ],
          ),
          const SizedBox(height: 16),
          subjectsAsync.when(
            data: (subjects) {
              return Wrap(
                spacing: 8,
                runSpacing: 8,
                children: subjects.map((s) => Chip(
                  label: Text(s, style: const TextStyle(fontSize: 12)),
                  deleteIcon: const Icon(Icons.close_rounded, size: 14),
                  onDeleted: () async {
                    await ref.read(configRepositoryProvider).deleteSubject(s);
                  },
                )).toList(),
              );
            },
            loading: () => const LinearProgressIndicator(),
            error: (err, _) => Text('Error: $err'),
          ),
        ],
      ),
    );
  }
}
