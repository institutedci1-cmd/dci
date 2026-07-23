import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/index.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class UniversalSearchDelegate extends SearchDelegate {
  final WidgetRef ref;

  UniversalSearchDelegate(this.ref);

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: const Icon(Icons.clear),
        onPressed: () => query = '',
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: const Icon(Icons.arrow_back),
      onPressed: () => close(context, null),
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return _buildSearchResults(context);
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return _buildSearchResults(context);
  }

  Widget _buildSearchResults(BuildContext context) {
    if (query.isEmpty) {
      return const Center(child: Text('Search for students, modules or reports...'));
    }

    final studentsAsync = ref.watch(studentsStreamProvider);
    final theme = FlutterFlowTheme.of(context);

    return studentsAsync.when(
      data: (students) {
        final filteredStudents = students.where((s) => s.name.toLowerCase().contains(query.toLowerCase())).toList();
        
        final modules = [
          {'title': 'Attendance', 'route': AttendanceDashboardWidget.routeName, 'icon': Icons.fact_check_rounded},
          {'title': 'Daily Report', 'route': ReportsDashboardWidget.routeName, 'icon': Icons.description_rounded},
          {'title': 'Exams', 'route': ExamsDashboardWidget.routeName, 'icon': Icons.assignment_rounded},
          {'title': 'Homework', 'route': HomeworkDashboardWidget.routeName, 'icon': Icons.edit_note_rounded},
        ].where((m) => (m['title'] as String).toLowerCase().contains(query.toLowerCase())).toList();

        if (filteredStudents.isEmpty && modules.isEmpty) {
          return const Center(child: Text('No results found.'));
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            if (modules.isNotEmpty) ...[
              _buildSectionTitle('Modules'),
              ...modules.map((m) => ListTile(
                leading: Icon(m['icon'] as IconData, color: theme.primary),
                title: Text(m['title'] as String),
                onTap: () {
                  close(context, null);
                  context.pushNamed(m['route'] as String);
                },
              )),
              const Divider(),
            ],
            if (filteredStudents.isNotEmpty) ...[
              _buildSectionTitle('Students'),
              ...filteredStudents.map((s) => ListTile(
                leading: const Icon(Icons.person),
                title: Text(s.name),
                subtitle: Text('Class: ${s.className} • Roll: ${s.rollNo}'),
                onTap: () {
                  close(context, null);
                  context.pushNamed(StudentProfileWidget.routeName, extra: {'student': s});
                },
              )),
            ],
          ],
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(child: Text('Error: $err')),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold, letterSpacing: 1),
      ),
    );
  }
}
