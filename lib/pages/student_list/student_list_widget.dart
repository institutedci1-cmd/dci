import 'package:d_c_i_teacher_app/backend/providers/service_providers.dart';
import 'package:d_c_i_teacher_app/features/student/application/student_list_notifier.dart';
import 'package:d_c_i_teacher_app/core/services/navigation_service.dart';
import 'package:d_c_i_teacher_app/components/shared/app_search_bar.dart';
import 'package:d_c_i_teacher_app/components/shared/compact_student_card.dart';
import 'package:d_c_i_teacher_app/components/shared/app_primary_button.dart';
import 'package:d_c_i_teacher_app/components/shared/app_empty_state.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/backend/services/excel_service/excel_service.dart';
import 'package:d_c_i_teacher_app/backend/services/error_handler.dart';
import 'package:d_c_i_teacher_app/components/header_section/header_section_widget.dart';
import 'package:d_c_i_teacher_app/core/services/access_control.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/backend/models/student.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:d_c_i_teacher_app/pages/student_list/student_list_model.dart';

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

  @override
  Widget build(BuildContext context) {
    final studentsAsync = ref.watch(studentsStreamProvider);
    final filteredStudentsAsync = ref.watch(filteredStudentsProvider);
    final selectedClass = ref.watch(studentClassFilterProvider);
    final notifier = ref.read(studentListNotifierProvider.notifier);

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: studentsAsync.when(
          data: (allStudents) {
            final Map<String, int> classCounts = {};
            for (final s in allStudents) {
              classCounts[s.className] = (classCounts[s.className] ?? 0) + 1;
            }

            final dynamicClassOptions = allStudents
                .map((s) => s.className)
                .where((c) => c.isNotEmpty)
                .toSet()
                .toList()
              ..sort();

            final access = ref.watch(accessControlProvider);

            return Column(
              children: [
                HeaderSectionWidget(
                  title: 'Students List',
                  subtitle: allStudents.isEmpty 
                      ? 'No students' 
                      : '${allStudents.length} Students Total',
                  onBackPressed: () async => NavigationService.navigateToHome(context),
                  showActionIcon: access.canManageStudents,
                  actionIcon: const Icon(
                    Icons.person_add_rounded,
                    size: 20,
                    color: Colors.white,
                  ),
                  onActionPressed: () async {
                    NavigationService.navigateToEditStudent(context);
                  },
                ),
                _buildSearchAndFilter(context, dynamicClassOptions, classCounts, allStudents.length, selectedClass, notifier),
                if (access.canManageStudents)
                  filteredStudentsAsync.when(
                    data: (filteredStudents) => _buildImportExportRow(context, filteredStudents),
                    loading: () => const SizedBox.shrink(),
                    error: (_, __) => const SizedBox.shrink(),
                  ),
                Expanded(
                  child: RefreshIndicator(
                    onRefresh: () async {
                      ref.invalidate(studentsStreamProvider);
                      await Future.delayed(const Duration(milliseconds: 500));
                    },
                    child: filteredStudentsAsync.when(
                      data: (filteredStudents) => _buildStudentList(context, filteredStudents, allStudents.isEmpty, notifier),
                      loading: () => const Center(child: CircularProgressIndicator()),
                      error: (error, stack) => _buildErrorState(context, error),
                    ),
                  ),
                ),
              ],
            );
          },
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (error, stack) => _buildErrorState(context, error),
        ),
      ),
    );
  }

  Widget _buildErrorState(BuildContext context, dynamic error) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.error_outline_rounded, color: AppColors.error, size: AppSize.iconXl),
          const SizedBox(height: 16),
          Text('Data Error', style: AppTypography.section),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32),
            child: Text(
              'Something went wrong: $error',
              style: AppTypography.caption,
              textAlign: TextAlign.center,
            ),
          ),
          const SizedBox(height: 24),
          AppPrimaryButton(
            text: 'Try Refreshing',
            width: 160,
            onPressed: () => safeSetState(() {}),
          ),
        ],
      ),
    );
  }

  Widget _buildImportExportRow(BuildContext context, List<Student> filteredStudents) {
    final access = ref.read(accessControlProvider);
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.md, vertical: 4),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isNarrow = constraints.maxWidth < 360;
          return Flex(
            direction: isNarrow ? Axis.vertical : Axis.horizontal,
            children: [
              Flexible(
                flex: isNarrow ? 0 : 1,
                child: AppPrimaryButton(
                  text: 'Export Excel',
                  color: AppColors.secondary,
                  icon: Icons.file_download_outlined,
                  height: 44,
                  width: isNarrow ? double.infinity : null,
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
              if (access.canManageStudents) ...[
                SizedBox(
                  width: isNarrow ? 0 : AppSpacing.md,
                  height: isNarrow ? AppSpacing.sm : 0,
                ),
                Flexible(
                  flex: isNarrow ? 0 : 1,
                  child: AppPrimaryButton(
                    text: 'Bulk Import',
                    isLoading: _isImporting,
                    icon: Icons.file_upload_outlined,
                    height: 44,
                    width: isNarrow ? double.infinity : null,
                    onPressed: () async {
                      safeSetState(() => _isImporting = true);
                      try {
                        final data = await ExcelService.importStudents();
                        if (data.isNotEmpty) {
                          await ref.read(studentServiceProvider).bulkImport(data);
                          if (context.mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Imported ${data.length} students successfully!')),
                            );
                          }
                        }
                      } catch (e) {
                        if (context.mounted) ErrorHandler.show(context, e);
                      } finally {
                        safeSetState(() => _isImporting = false);
                      }
                    },
                  ),
                ),
              ],
            ],
          );
        },
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context, List<String> classOptions, Map<String, int> classCounts, int totalCount, String? selectedClass, StudentListNotifier notifier) {
    final theme = FlutterFlowTheme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppSearchBar(
            controller: _model.searchController,
            hintText: 'Search student name, ID or Roll...',
            onChanged: notifier.updateSearchQuery,
            onClear: () {
              _model.searchController?.clear();
              notifier.updateSearchQuery('');
            },
          ),
          const SizedBox(height: 8),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['All Classes', ...classOptions].map((className) {
                final isSelected = (selectedClass ?? 'All Classes') == className;
                final count = className == 'All Classes' ? totalCount : (classCounts[className] ?? 0);
                
                return Padding(
                  padding: const EdgeInsets.only(right: 6),
                  child: FilterChip(
                    label: Text('$className ($count)', 
                      style: TextStyle(
                        fontSize: 11, 
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                        color: isSelected ? Colors.white : theme.primaryText
                      )
                    ),
                    selected: isSelected,
                    onSelected: (selected) {
                      notifier.updateClassFilter(className);
                    },
                    backgroundColor: theme.secondaryBackground,
                    selectedColor: AppColors.primary,
                    checkmarkColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 0),
                    materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                      side: BorderSide(
                        color: isSelected ? AppColors.primary : theme.alternate,
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

  Widget _buildStudentList(BuildContext context, List<Student> students, bool isDatabaseEmpty, StudentListNotifier notifier) {
    if (isDatabaseEmpty) {
      return AppEmptyState(
        icon: Icons.people_outline_rounded,
        title: 'No students in database',
        description: 'Add students or use Bulk Import to get started.',
        actionLabel: 'Add First Student',
        onActionPressed: () => NavigationService.navigateToEditStudent(context),
      );
    }

    if (students.isEmpty) {
      return AppEmptyState(
        icon: Icons.search_off_rounded,
        title: 'No results found',
        description: 'Try changing filters or search terms.',
        actionLabel: 'Clear All Filters',
        onActionPressed: () {
          notifier.clearFilters();
          _model.searchController?.clear();
          _model.dropdownValue = 'All Classes';
          _model.dropdownValueController?.value = 'All Classes';
        },
      );
    }

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(AppSpacing.md, 0, AppSpacing.md, AppSpacing.xl),
      itemCount: students.length,
      separatorBuilder: (context, index) => const SizedBox(height: 6),
      itemBuilder: (context, index) {
        final student = students[index];
        return CompactStudentCard(
          student: student,
          onTap: () async {
            NavigationService.navigateToStudentProfile(context, student: student);
          },
        );
      },
    );
  }
}
