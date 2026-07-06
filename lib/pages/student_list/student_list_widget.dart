import '/components/header_section/header_section_widget.dart';
import '/components/text_field/text_field_widget.dart';
import '/flutter_flow/flutter_flow_drop_down.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/form_field_controller.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'student_list_model.dart';
export 'student_list_model.dart';

class StudentListWidget extends StatefulWidget {
  const StudentListWidget({super.key});

  static String routeName = 'StudentList';
  static String routePath = '/studentList';

  @override
  State<StudentListWidget> createState() => _StudentListWidgetState();
}

class _StudentListWidgetState extends State<StudentListWidget> {
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
      onTap: () {
        FocusScope.of(context).unfocus();
        FocusManager.instance.primaryFocus?.unfocus();
      },
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
            Padding(
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
                    options: const [
                      'All Classes',
                      'Class 4',
                      'Class 5',
                      'Class 6',
                      'Class 7',
                      'Class 8',
                      'Class 9',
                      'Class 10'
                    ],
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
                    margin: const EdgeInsetsDirectional.fromSTEB(
                        16.0, 0.0, 16.0, 0.0),
                    hidesUnderline: true,
                    isOverButton: false,
                    isSearchable: false,
                    isMultiSelect: false,
                  ),
                ],
              ),
            ),
            Expanded(
              child: StreamBuilder<QuerySnapshot>(
                stream: FirebaseFirestore.instance
                    .collection('students')
                    .snapshots(),
                builder: (context, snapshot) {
                  if (!snapshot.hasData) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  var students = snapshot.data!.docs
                      .map((doc) => doc.data() as Map<String, dynamic>)
                      .toList();

                  if (_model.dropdownValue != null &&
                      _model.dropdownValue != 'All Classes') {
                    students = students
                        .where((s) => s['class'] == _model.dropdownValue)
                        .toList();
                  }

                  if (_searchQuery.isNotEmpty) {
                    students = students.where((s) {
                      final name = (s['name'] ?? '').toString().toLowerCase();
                      final id =
                          (s['student_id'] ?? '').toString().toLowerCase();
                      return name.contains(_searchQuery.toLowerCase()) ||
                          id.contains(_searchQuery.toLowerCase());
                    }).toList();
                  }

                  if (students.isEmpty && _searchQuery.isEmpty && (_model.dropdownValue == null || _model.dropdownValue == 'All Classes')) {
                    // Fallback to sample data if database is empty for demo purposes
                    students = [
                      {'name': 'Aditya Kulkarni', 'student_id': 'S1001', 'class': 'Class 10'},
                      {'name': 'Bhakti Deshmukh', 'student_id': 'S0902', 'class': 'Class 9'},
                      {'name': 'Chaitanya Patil', 'student_id': 'S0803', 'class': 'Class 8'},
                      {'name': 'Deepali Shinde', 'student_id': 'S0704', 'class': 'Class 7'},
                      {'name': 'Eknath Pawar', 'student_id': 'S0605', 'class': 'Class 6'},
                    ];
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
                          color:
                              FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(12.0),
                          border: Border.all(
                              color: FlutterFlowTheme.of(context).alternate),
                        ),
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                FlutterFlowTheme.of(context).primary10,
                            child: Text(
                              (student['name'] ?? 'S')[0],
                              style: TextStyle(
                                  color: FlutterFlowTheme.of(context).primary),
                            ),
                          ),
                          title: Text(
                            student['name'] ?? 'Unknown Student',
                            style: FlutterFlowTheme.of(context)
                                .bodyLarge
                                .override(
                                  font: GoogleFonts.plusJakartaSans(
                                      fontWeight: FontWeight.bold),
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          subtitle: Text(
                              'ID: ${student['student_id'] ?? 'N/A'} • Class: ${student['class'] ?? 'N/A'}'),
                          trailing: const Icon(Icons.chevron_right_rounded),
                          onTap: () {
                            // Navigation to student detail could go here
                          },
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
