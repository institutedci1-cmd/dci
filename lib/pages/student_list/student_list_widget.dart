import '/components/shared/app_search_bar.dart';
import '/components/shared/student_card.dart';
import '/components/shared/app_button.dart';
import '/components/shared/app_empty_state.dart';
import '/shared/app_style.dart';
import '/shared/app_colors.dart';
import '/backend/models/student.dart';
import '/backend/providers/repository_providers.dart';
import '/backend/services/excel_service/excel_service.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../edit_student/edit_student_widget.dart';
import 'student_list_model.dart';

export 'student_list_model.dart';

class StudentListWidget extends ConsumerStatefulWidget {
  const StudentListWidget({super.key});

  static String routeName = 'StudentList';
  static String routePath = '/studentList';

  @override
  ConsumerState<StudentListWidget> createState() => _StudentListWidgetState();
}

class _StudentListWidgetState extends ConsumerState<StudentListWidget> {
  late StudentListModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();
  String _searchQuery = '';
  bool _isImporting = false;

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StudentListModel());
    _model.searchController ??= TextEditingController();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  List<Student> _applyFilters(List<Student> students) {
    var filtered = students;
    if (_model.dropdownValue != null && _model.dropdownValue != 'All Classes') {
      filtered = filtered.where((s) => s.className == _model.dropdownValue).toList();
    }
    if (_searchQuery.trim().isNotEmpty) {
      final query = _searchQuery.trim().toLowerCase();
      filtered = filtered.where((s) {
        return s.name.toLowerCase().contains(query) || 
               s.studentId.toLowerCase().contains(query) ||
               s.rollNo.contains(query);
      }).toList();
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: AppColors.background,
        appBar: AppBar(
          backgroundColor: AppColors.surface,
          elevation: 0,
          centerTitle: false,
          title: Text('Students', style: AppTypography.appBarTitle),
          actions: [
            IconButton(
              icon: const Icon(Icons.person_add_rounded, color: AppColors.primary),
              onPressed: () => context.pushNamed(EditStudentWidget.routeName),
            ),
          ],
        ),
        body: StreamBuilder<List<Student>>(
          stream: ref.watch(studentRepositoryProvider).getAllStudentsStream(),
          builder: (context, snapshot) {
            final allStudents = snapshot.data ?? [];
            final filteredStudents = _applyFilters(allStudents);
            
            final dynamicClassOptions = allStudents
                .map((s) => s.className)
                .where((c) => c.isNotEmpty)
                .toSet()
                .toList()
              ..sort();

            return Column(
              children: [
                _buildSearchAndFilter(context, dynamicClassOptions),
                _buildImportExportRow(context, filteredStudents),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async => safeSetState(() {}),
                    child: _buildStudentList(context, snapshot, filteredStudents, allStudents.isEmpty),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context, List<String> classOptions) {
    return Padding(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          AppSearchBar(
            controller: _model.searchController,
            hintText: 'Search student...',
            onChanged: (val) => safeSetState(() => _searchQuery = val),
          ),
          const SizedBox(height: AppSpacing.sm),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All Classes', ...classOptions].map((className) {
                final isSelected = (_model.dropdownValue ?? 'All Classes') == className;
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    visualDensity: VisualDensity.compact,
                    label: Text(className),
                    selected: isSelected,
                    onSelected: (selected) {
                      safeSetState(() => _model.dropdownValue = className);
                    },
                    backgroundColor: AppColors.surface,
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    labelStyle: TextStyle(
                      color: isSelected ? Colors.white : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
                      fontSize: 12,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(color: isSelected ? AppColors.primary : AppColors.outline),
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildImportExportRow(BuildContext context, List<Student> filteredStudents) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 2),
      child: Row(
        children: [
          Expanded(
            child: AppButton(
              text: 'Export',
              variant: AppButtonVariant.outline,
              icon: Icons.file_download_outlined,
              height: 36,
              onPressed: () => ExcelService.exportStudents(filteredStudents),
            ),
          ),
          const SizedBox(width: AppSpacing.sm),
          Expanded(
            child: AppButton(
              text: 'Import',
              isLoading: _isImporting,
              icon: Icons.file_upload_outlined,
              height: 36,
              onPressed: _handleImport,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(BuildContext context, AsyncSnapshot<List<Student>> snapshot, List<Student> students, bool isEmpty) {
    if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }
    if (isEmpty) return const AppEmptyState(icon: Icons.people_outline_rounded, title: 'No students found', description: 'Add your first student to get started.');
    
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.md),
      itemCount: students.length,
      separatorBuilder: (_, __) => const SizedBox(height: 8),
      itemBuilder: (context, index) {
        final student = students[index];
        return StudentCard(
          student: student,
          onTap: () => context.pushNamed(EditStudentWidget.routeName, extra: {'student': student}),
        );
      },
    );
  }

  Future<void> _handleImport() async {
    setState(() => _isImporting = true);
    try {
      final data = await ExcelService.importStudents();
      if (data.isNotEmpty) {
        await ref.read(studentRepositoryProvider).bulkAddStudents(data);
        if (mounted) {
          await showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Import Successful'),
              content: Text('Successfully imported ${data.length} students from the Excel file.'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('OK'),
                ),
              ],
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Import failed: $e')));
    } finally {
      if (mounted) setState(() => _isImporting = false);
    }
  }
}
