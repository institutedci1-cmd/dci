import '/backend/models/student.dart';
import '/backend/providers/repository_providers.dart';
import '/backend/services/app_constants.dart';
import '/components/header_section/header_section_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
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

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StudentListModel());
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: Column(
          children: [
            wrapWithModel(
              model: _model.headerSectionModel,
              updateCallback: () => safeSetState(() {}),
              child: HeaderSectionWidget(
                title: 'Students',
                subtitle: 'Manage your class students',
                description: 'View and search for student details and progress.',
                onBackPressed: () async => context.safePop(),
              ),
            ),
            _buildSearchAndFilter(context),
            Expanded(
              child: _buildStudentList(context),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSearchAndFilter(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          wrapWithModel(
            model: _model.searchFieldModel,
            updateCallback: () => safeSetState(() {}),
            child: TextFieldWidget(
              label: '',
              labelPresent: false,
              hint: 'Search by name or ID...',
              leadingIcon: const Icon(Icons.search_rounded),
              leadingIconPresent: true,
              variant: 'outlined',
              onChange: (val) =>
                  safeSetState(() => _searchQuery = val ?? ''),
            ),
          ),
          const SizedBox(height: 12),
          FlutterFlowDropDown<String>(
            controller: _model.dropdownValueController ??=
                FormFieldController<String>(
              _model.dropdownValue ??= 'All Classes',
            ),
            options: const ['All Classes', ...AppConstants.classOptions],
            onChanged: (val) =>
                safeSetState(() => _model.dropdownValue = val),
            width: double.infinity,
            height: 44.0,
            textStyle: FlutterFlowTheme.of(context).bodyMedium,
            hintText: 'Filter by Class',
            icon: Icon(
              Icons.filter_list_rounded,
              color: FlutterFlowTheme.of(context).secondaryText,
              size: 20.0,
            ),
            fillColor: FlutterFlowTheme.of(context).secondaryBackground,
            elevation: 2.0,
            borderColor: FlutterFlowTheme.of(context).alternate,
            borderWidth: 1.0,
            borderRadius: 12.0,
            margin: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
            hidesUnderline: true,
          ),
        ],
      ),
    );
  }

  Widget _buildStudentList(BuildContext context) {
    return StreamBuilder<List<Student>>(
      stream: ref.watch(studentRepositoryProvider).getAllStudentsStream(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        var students = snapshot.data!;

        if (_model.dropdownValue != null &&
            _model.dropdownValue != 'All Classes') {
          students = students
              .where((s) => s.className == _model.dropdownValue)
              .toList();
        }

        if (_searchQuery.isNotEmpty) {
          students = students.where((s) {
            final name = s.name.toLowerCase();
            final id = s.studentId.toLowerCase();
            return name.contains(_searchQuery.toLowerCase()) ||
                id.contains(_searchQuery.toLowerCase());
          }).toList();
        }

        if (students.isEmpty) {
          return Center(
            child: Text(
              'No students found.',
              style: FlutterFlowTheme.of(context).bodyMedium,
            ),
          );
        }

        return ListView.separated(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          itemCount: students.length,
          separatorBuilder: (context, index) =>
              const SizedBox(height: 12),
          itemBuilder: (context, index) {
            final student = students[index];
            return Container(
              decoration: BoxDecoration(
                color: FlutterFlowTheme.of(context).secondaryBackground,
                borderRadius: BorderRadius.circular(12.0),
                border: Border.all(
                    color: FlutterFlowTheme.of(context).alternate),
              ),
              child: ListTile(
                leading: CircleAvatar(
                  backgroundColor: FlutterFlowTheme.of(context).primary10,
                  child: Text(
                    student.name.isNotEmpty ? student.name[0] : 'S',
                    style: TextStyle(color: FlutterFlowTheme.of(context).primary),
                  ),
                ),
                title: Text(
                  student.name,
                  style: FlutterFlowTheme.of(context).bodyLarge.override(
                        font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                subtitle: Text('ID: ${student.studentId} • Class: ${student.className}'),
                trailing: const Icon(Icons.chevron_right_rounded),
                onTap: () {
                  // Detail view
                },
              ),
            );
          },
        );
      },
    );
  }

}
