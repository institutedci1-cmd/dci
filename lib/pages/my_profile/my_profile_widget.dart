import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/profile_header/profile_header_widget.dart';
import 'package:d_c_i_teacher_app/components/profile_info_tile/profile_info_tile_widget.dart';
import 'package:d_c_i_teacher_app/components/shared/app_primary_button.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class MyProfileWidget extends ConsumerStatefulWidget {
  const MyProfileWidget({super.key});

  static String routeName = 'MyProfile';
  static String routePath = '/myProfile';

  @override
  ConsumerState<MyProfileWidget> createState() => _MyProfileWidgetState();
}

class _MyProfileWidgetState extends ConsumerState<MyProfileWidget> {
  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    final studentAsync = ref.watch(currentStudentStreamProvider);

    return Scaffold(
      backgroundColor: theme.primaryBackground,
      body: studentAsync.when(
        data: (student) {
          if (student == null) return const Center(child: Text('Student profile not found.'));
          return _buildProfile(context, student);
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) => Center(child: Text('Error: $err')),
      ),
    );
  }

  Widget _buildProfile(BuildContext context, dynamic student) {
    final theme = FlutterFlowTheme.of(context);

    return SingleChildScrollView(
      child: Column(
        children: [
          ProfileHeaderWidget(
            name: student.name,
            designation: '${student.className} • Roll: ${student.rollNo}',
            photoUrl: student.photoUrl,
          ),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildAcademicSummary(context),
                const SizedBox(height: 24),
                _buildSectionHeader('Personal Information'),
                const SizedBox(height: 12),
                _buildInfoCard(context, [
                  ProfileInfoTileWidget(
                    icon: Icon(Icons.badge_rounded, color: theme.primary),
                    label: 'Student ID',
                    value: student.studentId,
                  ),
                  ProfileInfoTileWidget(
                    icon: Icon(Icons.person_outline_rounded, color: theme.primary),
                    label: 'Parent Name',
                    value: student.parentName ?? 'N/A',
                  ),
                  ProfileInfoTileWidget(
                    icon: Icon(Icons.phone_rounded, color: theme.primary),
                    label: 'Parent Contact',
                    value: student.parentPhone ?? 'N/A',
                  ),
                  ProfileInfoTileWidget(
                    icon: Icon(Icons.email_outlined, color: theme.primary),
                    label: 'Email Address',
                    value: student.email ?? 'N/A',
                  ),
                ]),
                const SizedBox(height: 32),
                AppPrimaryButton(
                  text: 'Request Profile Edit',
                  variant: 'outline',
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Request sent to the admin department.'))
                    );
                  },
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAcademicSummary(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: theme.alternate),
        boxShadow: AppShadows.low,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildSummaryItem('GPA', '3.8', AppColors.primary),
          _buildDivider(),
          _buildSummaryItem('Rank', '#04', AppColors.secondary),
          _buildDivider(),
          _buildSummaryItem('Credits', '24', AppColors.success),
        ],
      ),
    );
  }

  Widget _buildSummaryItem(String label, String value, Color color) {
    return Column(
      children: [
        Text(value, style: AppTypography.title.copyWith(color: color, fontSize: 22)),
        Text(label, style: AppTypography.caption.copyWith(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildDivider() {
    return Container(height: 30, width: 1, color: FlutterFlowTheme.of(context).alternate);
  }

  Widget _buildSectionHeader(String title) {
    return Text(title, style: AppTypography.section.copyWith(fontWeight: FontWeight.bold));
  }

  Widget _buildInfoCard(BuildContext context, List<Widget> children) {
    final theme = FlutterFlowTheme.of(context);
    return Container(
      decoration: BoxDecoration(
        color: theme.secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.alternate),
      ),
      child: Column(children: children),
    );
  }
}
