import 'package:d_c_i_teacher_app/backend/models/student_attendance.dart';
import 'package:d_c_i_teacher_app/backend/models/student.dart';
import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/profile_header/profile_header_widget.dart';
import 'package:d_c_i_teacher_app/components/profile_info_tile/profile_info_tile_widget.dart';
import 'package:d_c_i_teacher_app/core/services/access_control.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/pages/edit_student/edit_student_widget.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/pages/student_profile/student_profile_model.dart';

class StudentProfileWidget extends ConsumerStatefulWidget {
  const StudentProfileWidget({
    super.key,
    required this.student,
  });

  final Student student;

  static String routeName = 'StudentProfile';
  static String routePath = '/studentProfile';

  @override
  ConsumerState<StudentProfileWidget> createState() => _StudentProfileWidgetState();
}

class _StudentProfileWidgetState extends ConsumerState<StudentProfileWidget> {
  late StudentProfileModel _model;
  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => StudentProfileModel());
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
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ProfileHeaderWidget(
                name: widget.student.name,
                designation: 'Roll No: ${widget.student.rollNo} • ${widget.student.className}',
                photoUrl: widget.student.photoUrl,
                onBackPressed: () async => context.safePop(),
              ),
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildQuickStats(context),
                    const SizedBox(height: 24),
                    _buildSectionHeader(context, 'Student Information'),
                    ProfileInfoTileWidget(
                      icon: Icon(Icons.badge_rounded, color: FlutterFlowTheme.of(context).primary, size: 20),
                      label: 'Student ID',
                      value: widget.student.studentId,
                    ),
                    ProfileInfoTileWidget(
                      icon: Icon(Icons.class_rounded, color: FlutterFlowTheme.of(context).primary, size: 20),
                      label: 'Class',
                      value: widget.student.className,
                    ),
                    if (widget.student.section != null && widget.student.section!.isNotEmpty)
                      ProfileInfoTileWidget(
                        icon: Icon(Icons.grid_view_rounded, color: FlutterFlowTheme.of(context).primary, size: 20),
                        label: 'Section',
                        value: widget.student.section!,
                      ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(context, 'Parent / Contact Details'),
                    ProfileInfoTileWidget(
                      icon: Icon(Icons.person_outline_rounded, color: FlutterFlowTheme.of(context).primary, size: 20),
                      label: 'Parent Name',
                      value: widget.student.parentName ?? 'Not Provided',
                    ),
                    ProfileInfoTileWidget(
                      icon: Icon(Icons.phone_rounded, color: FlutterFlowTheme.of(context).primary, size: 20),
                      label: 'Parent Phone',
                      value: widget.student.parentPhone ?? 'Not Provided',
                    ),
                    const SizedBox(height: 24),
                    _buildSectionHeader(context, 'Attendance Summary'),
                    _buildAttendanceList(context),
                    const SizedBox(height: 32),
                    _buildActionButtons(context),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuickStats(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Row(
      children: [
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.alternate),
            ),
            child: Column(
              children: [
                Text(
                  '94%',
                  style: theme.titleLarge.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                    color: AppColors.success,
                    fontSize: 20,
                  ),
                ),
                Text('Attendance', style: theme.labelSmall.copyWith(fontSize: 10)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            decoration: BoxDecoration(
              color: theme.secondaryBackground,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.alternate),
            ),
            child: Column(
              children: [
                Text(
                  'A+',
                  style: theme.titleLarge.override(
                    font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                    color: theme.primary,
                    fontSize: 20,
                  ),
                ),
                Text('Last Grade', style: theme.labelSmall.copyWith(fontSize: 10)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: Text(
        title,
        style: FlutterFlowTheme.of(context).titleMedium.override(
          font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildAttendanceList(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final attendanceAsync = ref.watch(studentAttendanceHistoryProvider(widget.student.studentId));

    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Recent Logs',
                  style: theme.bodyMedium.override(
                        font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
                        fontWeight: FontWeight.bold,
                      ),
                ),
                Text(
                  'View All',
                  style: TextStyle(color: theme.primary, fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),
          const Divider(height: 1),
          attendanceAsync.when(
            data: (List<StudentAttendance> logs) {
              if (logs.isEmpty) {
                return const Padding(
                  padding: EdgeInsets.all(16.0),
                  child: Center(child: Text('No records.', style: TextStyle(fontSize: 11))),
                );
              }
              return ListView.separated(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 4),
                itemCount: logs.length > 3 ? 3 : logs.length,
                separatorBuilder: (_, __) => const Divider(height: 1, indent: 8, endIndent: 8),
                itemBuilder: (context, index) {
                  final log = logs[index];
                  return ListTile(
                    dense: true,
                    visualDensity: VisualDensity.compact,
                    title: Text(
                      '${log.subject} • ${DateFormat('yMMMd').format(log.date)}',
                      style: theme.bodySmall.copyWith(fontSize: 12),
                    ),
                    trailing: _buildStatusBadge(context, log.status),
                  );
                },
              );
            },
            loading: () => const Padding(
              padding: EdgeInsets.all(16.0),
              child: Center(child: CircularProgressIndicator(strokeWidth: 2)),
            ),
            error: (err, stack) => Text('Error: $err', style: const TextStyle(fontSize: 10)),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBadge(BuildContext context, String status) {
    final theme = FlutterFlowTheme.of(context);
    Color color;
    switch (status) {
      case 'Present':
        color = theme.success;
        break;
      case 'Absent':
        color = theme.error;
        break;
      case 'Leave':
        color = theme.warning;
        break;
      default:
        color = theme.secondaryText;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withAlpha((0.1 * 255).toInt()),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withAlpha((0.5 * 255).toInt())),
      ),
      child: Text(
        status,
        style: TextStyle(
          color: color,
          fontWeight: FontWeight.bold,
          fontSize: 10,
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    final access = ref.watch(accessControlProvider);
    return Row(
      children: [
        if (access.canManageStudents)
          Expanded(
            child: ElevatedButton.icon(
              onPressed: () {
                context.pushNamed(
                  EditStudentWidget.routeName,
                  extra: {'student': widget.student},
                );
              },
              icon: const Icon(Icons.edit_rounded, size: 18),
              label: const Text('Edit Profile'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                minimumSize: const Size(0, 48),
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
              ),
            ),
          ),
        if (access.canManageStudents) const SizedBox(width: 12),
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () {
              // Share functionality
            },
            icon: const Icon(Icons.share_rounded, size: 18),
            label: const Text('Share PDF'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppColors.primary,
              minimumSize: const Size(0, 48),
              side: const BorderSide(color: AppColors.primary),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppRadius.md)),
            ),
          ),
        ),
      ],
    );
  }
}
