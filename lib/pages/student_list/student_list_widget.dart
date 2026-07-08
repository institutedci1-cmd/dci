import '/components/shared/app_search_bar.dart';
import '/components/shared/student_card.dart';
import '/components/shared/app_primary_button.dart';
import '/components/shared/app_empty_state.dart';
import '/shared/app_style.dart';
import '/shared/app_colors.dart';
import '/backend/models/student.dart';
import '/backend/providers/repository_providers.dart';
import '/backend/services/excel_service/excel_service.dart';
import '/components/button/button_widget.dart';
import '/components/header_section/header_section_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
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
  int _refreshKey = 0;

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
               s.rollNo.contains(query) ||
               (s.parentPhone?.contains(query) ?? false) ||
               (s.parentName?.toLowerCase().contains(query) ?? false) ||
               s.className.toLowerCase().contains(query);
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
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: StreamBuilder<List<Student>>(
          stream: ref.watch(studentRepositoryProvider).getAllStudentsStream(),
          builder: (context, snapshot) {
            final allStudents = snapshot.data ?? [];
            final filteredStudents = _applyFilters(allStudents);
            
            // Get unique classes for dropdown
            final dynamicClassOptions = allStudents
                .map((s) => s.className)
                .where((c) => c.isNotEmpty)
                .toSet()
                .toList()
              ..sort();
            
            // Safety check: if selected class no longer exists, reset to All Classes
            if (_model.dropdownValue != 'All Classes' && !dynamicClassOptions.contains(_model.dropdownValue)) {
              _model.dropdownValue = 'All Classes';
            }

            return Column(
              children: [
                wrapWithModel(
                  model: _model.headerSectionModel,
                  updateCallback: () => safeSetState(() {}),
                  child: HeaderSectionWidget(
                    title: 'Students',
                    subtitle: allStudents.isEmpty 
                        ? 'No students found' 
                        : 'Total: ${allStudents.length} students',
                    description: 'View and search for student details and progress.',
                    onBackPressed: () async => context.safePop(),
                    actionIcon: const Icon(Icons.person_add_rounded),
                    onActionPressed: () async {
                      context.pushNamed(EditStudentWidget.routeName);
                    },
                  ),
                ),
                _buildSearchAndFilter(context, dynamicClassOptions),
                _buildImportExportRow(context, filteredStudents),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      // Stream will refresh automatically, but this gives visual feedback
                      safeSetState(() {});
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
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

  Widget _buildImportExportRow(BuildContext context, List<Student> filteredStudents) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: AppSpacing.sm),
      child: Row(
        children: [
          Expanded(
            child: AppPrimaryButton(
              text: 'Export Excel',
              color: AppColors.secondary,
              icon: Icons.file_download_outlined,
              onPressed: () async {
                if (filteredStudents.isEmpty) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('No students to export.')),
                  );
                  return;
                }

                await ExcelService.exportStudents(filteredStudents);
              },
            ),
          ),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: AppPrimaryButton(
              text: 'Bulk Import',
              isLoading: _isImporting,
              icon: Icons.file_upload_outlined,
              onPressed: () async {
                safeSetState(() => _isImporting = true);
                try {
                  final data = await ExcelService.importStudents();
                  if (data.isNotEmpty) {
                    final repository = ref.read(studentRepositoryProvider);
                    await repository.bulkAddStudents(data);
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                            content: Text(
                                'Imported ${data.length} students successfully!')),
                      );
                    }
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(content: Text('Import failed: $e')),
                    );
                  }
                } finally {
                  safeSetState(() => _isImporting = false);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context, List<String> classOptions) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, AppSpacing.md, AppSpacing.md, AppSpacing.sm),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSearchBar(
            controller: _model.searchController,
            hintText: 'Search student name, ID or Roll...',
            onChanged: (val) => safeSetState(() => _searchQuery = val),
            onClear: () => safeSetState(() {
              _model.searchController?.clear();
              _searchQuery = '';
            }),
          ),
          const SizedBox(height: AppSpacing.md),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All Classes', ...classOptions].map((className) {
                final isSelected = (_model.dropdownValue ?? 'All Classes') == className;
                return Padding(
                  padding: const EdgeInsets.only(right: AppSpacing.sm),
                  child: FilterChip(
                    label: Text(className),
                    selected: isSelected,
                    onSelected: (selected) {
                      safeSetState(() {
                        _model.dropdownValue = className;
                        _model.dropdownValueController?.value = className;
                      });
                    },
                    backgroundColor: FlutterFlowTheme.of(context).secondaryBackground,
                    selectedColor: AppColors.primary,
                    labelStyle: AppTypography.caption.copyWith(
                      color: isSelected
                          ? Colors.white
                          : AppColors.textPrimary,
                      fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                    ),
                    checkmarkColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.xl),
                      side: BorderSide(
                        color: isSelected
                            ? AppColors.primary
                            : AppColors.outline,
                      ),
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

  Widget _buildStudentList(BuildContext context, AsyncSnapshot<List<Student>> snapshot, List<Student> students, bool isDatabaseEmpty) {
    if (snapshot.hasError) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline_rounded, color: Colors.red, size: 64),
            const SizedBox(height: 16),
            Text('Data Error', style: FlutterFlowTheme.of(context).titleMedium),
            const SizedBox(height: 8),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                'Something went wrong: ${snapshot.error}',
                style: FlutterFlowTheme.of(context).bodySmall,
                textAlign: TextAlign.center,
              ),
            ),
            const SizedBox(height: 24),
            ButtonWidget(
              content: 'Try Refreshing',
              variant: 'outline',
              onPressed: () => safeSetState(() {}),
            ),
          ],
        ),
      );
    }
    
    if (snapshot.connectionState == ConnectionState.waiting && !snapshot.hasData) {
      return const Center(child: CircularProgressIndicator());
    }

    if (isDatabaseEmpty) {
      return AppEmptyState(
        icon: Icons.people_outline_rounded,
        title: 'No students in database',
        description: 'Add students or use Bulk Import to get started.',
        actionLabel: 'Add First Student',
        onActionPressed: () => context.pushNamed(EditStudentWidget.routeName),
      );
    }

    if (students.isEmpty) {
      return AppEmptyState(
        icon: Icons.search_off_rounded,
        title: 'No results found',
        description: 'Try changing filters or search terms.',
        actionLabel: 'Clear All Filters',
        onActionPressed: () => safeSetState(() {
          _searchQuery = '';
          _model.dropdownValue = 'All Classes';
          _model.dropdownValueController?.value = 'All Classes';
        }),
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
      itemCount: students.length,
      separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.sm),
      itemBuilder: (context, index) {
        final student = students[index];
        return StudentCard(
          student: student,
          onTap: () async {
            context.pushNamed(
              EditStudentWidget.routeName,
              extra: {'student': student},
            );
          },
        );
      },
    );
  }

}
