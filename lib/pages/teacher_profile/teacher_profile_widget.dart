import 'package:d_c_i_teacher_app/backend/providers/repository_providers.dart';
import 'package:d_c_i_teacher_app/components/shared/app_primary_button.dart';
import 'package:d_c_i_teacher_app/shared/app_style.dart';
import 'package:d_c_i_teacher_app/shared/app_colors.dart';
import 'package:d_c_i_teacher_app/components/profile_header/profile_header_widget.dart';
import 'package:d_c_i_teacher_app/components/profile_info_tile/profile_info_tile_widget.dart';
import 'package:d_c_i_teacher_app/components/shared/app_bottom_nav_bar.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_theme.dart';
import 'package:d_c_i_teacher_app/flutter_flow/flutter_flow_util.dart';
import 'package:d_c_i_teacher_app/index.dart';
import 'package:d_c_i_teacher_app/backend/services/pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:d_c_i_teacher_app/pages/teacher_profile/teacher_profile_model.dart';

class TeacherProfileWidget extends ConsumerStatefulWidget {
  const TeacherProfileWidget({
    super.key,
    this.initialUserData,
  });

  final Teacher? initialUserData;

  static String routeName = 'TeacherProfile';
  static String routePath = '/teacherProfile';

  @override
  ConsumerState<TeacherProfileWidget> createState() => _TeacherProfileWidgetState();
}

class _TeacherProfileWidgetState extends ConsumerState<TeacherProfileWidget> {
  late TeacherProfileModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => TeacherProfileModel());

    WidgetsBinding.instance.addPostFrameCallback((_) => safeSetState(() {}));
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final body = (widget.initialUserData != null)
        ? ref.watch(userDataStreamProvider(widget.initialUserData!.uid)).when(
              data: (Teacher? userData) =>
                  _buildProfileContent(context, userData),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            )
        : ref.watch(currentUserDataStreamProvider).when(
              data: (Teacher? userData) =>
                  _buildProfileContent(context, userData),
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, stack) => Center(child: Text('Error: $err')),
            );

    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: body,
        bottomNavigationBar: AppBottomNavBar(
          currentIndex: 3,
          onTap: (index) {
            final routes = [
              HomeDashboardWidget.routeName,
              ReportsDashboardWidget.routeName,
              AttendanceDashboardWidget.routeName,
              TeacherProfileWidget.routeName,
            ];
            if (index != 3) {
              context.goNamed(routes[index]);
            }
          },
        ),
      ),
    );
  }

  Widget _buildProfileContent(BuildContext context, Teacher? userData) {
    final isAdmin = userData?.role == 'Admin';
    final isDirector = userData?.role == 'Director';

    return SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          wrapWithModel(
            model: _model.profileHeaderModel,
            updateCallback: () => safeSetState(() {}),
            child: ProfileHeaderWidget(
              designation: userData?.designation ??
                  'Senior Faculty • M.Sc., M.Ed.',
              name: (userData?.displayName.isNotEmpty ?? false)
                  ? userData!.displayName
                  : 'DCI Faculty',
              photoUrl: userData?.photoUrl,
            ),
          ),
          if ((isAdmin || isDirector) && widget.initialUserData == null) ...[
            const SizedBox(height: 12),
            _buildInstituteStats(context),
          ],
          _buildActionButtons(context, userData),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildUserRoleBadge(context, userData),
                const SizedBox(height: 12.0),
                _buildPersonalInformation(context, userData),
                const SizedBox(height: 20.0),
                _buildEducationExpertise(context, userData),
                const SizedBox(height: 20.0),
                if ((isAdmin || isDirector) && widget.initialUserData == null) ...[
                  _buildAdminToolsSection(context),
                  const SizedBox(height: 20.0),
                ],
                _buildAppLinksSection(context),
                const SizedBox(height: 20.0),
                if (widget.initialUserData == null) ...[
                  _buildSettingsSection(context, userData),
                  const SizedBox(height: 20.0),
                ],
                _buildAboutSection(context),
                const SizedBox(height: 20.0),
                if (widget.initialUserData == null)
                  _buildLogoutButton(context),
              ],
            ),
          ),
          const SizedBox(height: 32.0),
        ],
      ),
    );
  }

  Widget _buildInstituteStats(BuildContext context) {
    final facultyCount = ref.watch(allUsersStreamProvider).maybeWhen(data: (u) => u.length, orElse: () => 0);
    final studentCount = ref.watch(studentsStreamProvider).maybeWhen(data: (s) => s.length, orElse: () => 0);

    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Row(
        children: [
          _buildStatCard(context, 'Total Faculty', facultyCount.toString(), Icons.school_rounded, FlutterFlowTheme.of(context).primary),
          const SizedBox(width: 12),
          _buildStatCard(context, 'Total Students', studentCount.toString(), Icons.people_rounded, FlutterFlowTheme.of(context).tertiary),
        ],
      ),
    );
  }

  Widget _buildStatCard(BuildContext context, String title, String value, IconData icon, Color color) {
    final theme = FlutterFlowTheme.of(context);
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: theme.secondaryBackground,
          borderRadius: AppRadius.standard,
          border: Border.all(color: theme.alternate),
          boxShadow: AppShadows.low,
        ),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withAlpha(25),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(height: AppSpacing.sm),
            Text(value, style: AppTypography.title.copyWith(fontSize: 20)),
            Text(title, style: AppTypography.caption.copyWith(fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context, Teacher? userData) {
    final currentUser = ref.watch(currentUserDataStreamProvider).value;
    final bool canEdit = currentUser?.role == 'Admin' || currentUser?.role == 'Director';

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
      child: Row(
        children: [
          if (canEdit)
            Expanded(
              child: AppPrimaryButton(
                icon: Icons.edit_rounded,
                text: 'Edit Profile',
                variant: 'outline',
                height: 44,
                onPressed: () => context.pushNamed(
                  EditProfileWidget.routeName,
                  extra: {'userToEdit': userData},
                ),
              ),
            ),
          if (canEdit) const SizedBox(width: 12.0),
          Expanded(
            child: AppPrimaryButton(
              icon: Icons.share_rounded,
              text: 'Share CV',
              color: AppColors.secondary,
              height: 44,
              onPressed: () async {
                if (userData != null) {
                  await PdfService.generateTeacherCV(userData);
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInformation(BuildContext context, Teacher? userData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Personal Information'),
        wrapWithModel(
          model: _model.profileInfoTileModel1,
          updateCallback: () => safeSetState(() {}),
          child: ProfileInfoTileWidget(
            icon: Icon(Icons.email_rounded, color: FlutterFlowTheme.of(context).onPrimaryContainer, size: 20.0),
            label: 'Email Address',
            value: userData?.email ?? 'admin@dciteachers.com',
          ),
        ),
        wrapWithModel(
          model: _model.profileInfoTileModel2,
          updateCallback: () => safeSetState(() {}),
          child: ProfileInfoTileWidget(
            icon: Icon(Icons.phone_rounded, color: FlutterFlowTheme.of(context).onPrimaryContainer, size: 20.0),
            label: 'Mobile Number',
            value: userData?.phoneNumber ?? '+91 98765 43210',
          ),
        ),
        wrapWithModel(
          model: _model.profileInfoTileModel3,
          updateCallback: () => safeSetState(() {}),
          child: ProfileInfoTileWidget(
            icon: Icon(Icons.badge_rounded, color: FlutterFlowTheme.of(context).onPrimaryContainer, size: 20.0),
            label: 'Employee ID',
            value: userData?.employeeId ?? 'DCI-T-2024-001',
          ),
        ),
        wrapWithModel(
          model: _model.profileInfoTileModel4,
          updateCallback: () => safeSetState(() {}),
          child: ProfileInfoTileWidget(
            icon: Icon(Icons.event_available_rounded, color: FlutterFlowTheme.of(context).onPrimaryContainer, size: 20.0),
            label: 'Joined Date',
            value: userData?.createdTime != null ? DateFormat('yMMMd').format(userData!.createdTime!) : 'N/A',
          ),
        ),
      ],
    );
  }

  Widget _buildEducationExpertise(BuildContext context, Teacher? userData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Education & Expertise'),
        wrapWithModel(
          model: _model.profileInfoTileModel5,
          updateCallback: () => safeSetState(() {}),
          child: ProfileInfoTileWidget(
            icon: Icon(Icons.school_rounded, color: FlutterFlowTheme.of(context).onPrimaryContainer, size: 20.0),
            label: 'Qualification',
            value: userData?.qualification ?? 'M.Sc. Physics, M.Ed. Education',
          ),
        ),
        wrapWithModel(
          model: _model.profileInfoTileModel6,
          updateCallback: () => safeSetState(() {}),
          child: ProfileInfoTileWidget(
            icon: Icon(Icons.psychology_rounded, color: FlutterFlowTheme.of(context).onPrimaryContainer, size: 20.0),
            label: 'Subject Expertise',
            value: userData?.subjectExpertise ?? 'Advanced Physics & Mathematics',
          ),
        ),
        wrapWithModel(
          model: _model.profileInfoTileModel7,
          updateCallback: () => safeSetState(() {}),
          child: ProfileInfoTileWidget(
            icon: Icon(Icons.workspace_premium_rounded, color: FlutterFlowTheme.of(context).onPrimaryContainer, size: 20.0),
            label: 'Experience',
            value: userData?.experience ?? '12 Years in Competitive Coaching',
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, Teacher? userData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Settings & Preferences'),
        Material(
          color: FlutterFlowTheme.of(context).secondaryBackground,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16.0),
            side: BorderSide(color: FlutterFlowTheme.of(context).alternate),
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(16.0),
            child: SwitchListTile.adaptive(
              value: userData?.notificationsEnabled ?? true,
              onChanged: (newValue) async {
                await ref
                    .read(userRepositoryProvider)
                    .toggleNotifications(newValue);
              },
              title: Text('Push Notifications', style: FlutterFlowTheme.of(context).bodyLarge),
              subtitle: Text('Receive alerts for new announcements.', style: FlutterFlowTheme.of(context).labelSmall),
              activeThumbColor: FlutterFlowTheme.of(context).primary,
              activeTrackColor: FlutterFlowTheme.of(context).primary10,
              controlAffinity: ListTileControlAffinity.trailing,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildAboutSection(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(16.0),
        border: Border.all(color: FlutterFlowTheme.of(context).info),
      ),
      padding: const EdgeInsets.all(24.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.info_rounded, size: 24.0),
          const SizedBox(width: 16.0),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'About DCI Teacher Portal',
                  style: FlutterFlowTheme.of(context).labelLarge.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'This profile is managed by the DCI HR department.',
                  style: FlutterFlowTheme.of(context).bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRoleBadge(BuildContext context, Teacher? userData) {
    final role = userData?.role ?? 'Teacher';
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
        decoration: BoxDecoration(
          color: FlutterFlowTheme.of(context).primary10,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: FlutterFlowTheme.of(context).primary),
        ),
        child: Text(
          role.toUpperCase(),
          style: FlutterFlowTheme.of(context).labelSmall.override(
            font: GoogleFonts.inter(fontWeight: FontWeight.bold),
            color: FlutterFlowTheme.of(context).primary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  Widget _buildAdminToolsSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Administrative Tools'),
        _buildListTile(
          context,
          icon: Icons.people_outline_rounded,
          title: 'Manage Faculty',
          onTap: () => context.pushNamed(FacultyListWidget.routeName),
        ),
        _buildListTile(
          context,
          icon: Icons.admin_panel_settings_outlined,
          title: 'Institute Settings',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Institute Settings coming soon!')),
            );
          },
        ),
        _buildListTile(
          context,
          icon: Icons.history_rounded,
          title: 'Audit Logs',
          onTap: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Audit Logs coming soon!')),
            );
          },
        ),
        _buildListTile(
          context,
          icon: Icons.person_add_rounded,
          title: 'Add New User',
          onTap: () => context.pushNamed(AddUserWidget.routeName),
        ),
      ],
    );
  }

  Widget _buildAppLinksSection(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'App & Preferences'),
        _buildListTile(
          context,
          icon: Icons.notifications_none_rounded,
          title: 'Notification Center',
          onTap: () => context.pushNamed(NotificationsWidget.routeName),
        ),
        _buildListTile(
          context,
          icon: Icons.settings_outlined,
          title: 'Settings',
          onTap: () => context.pushNamed(SettingsWidget.routeName),
        ),
      ],
    );
  }

  Widget _buildListTile(BuildContext context, {required IconData icon, required String title, required VoidCallback onTap}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      child: Material(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
          side: BorderSide(color: FlutterFlowTheme.of(context).alternate),
        ),
        child: ListTile(
          onTap: onTap,
          leading: Icon(icon, color: FlutterFlowTheme.of(context).secondaryText),
          title: Text(title, style: FlutterFlowTheme.of(context).bodyLarge),
          trailing: const Icon(Icons.chevron_right_rounded),
        ),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    final theme = FlutterFlowTheme.of(context);
    return AppPrimaryButton(
      icon: Icons.logout_rounded,
      text: 'Logout',
      color: theme.error,
      onPressed: () async {
        final confirm = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text('Logout', style: AppTypography.section),
            content: const Text('Are you sure you want to log out?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context, false),
                child: Text('Cancel', style: TextStyle(color: theme.secondaryText)),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context, true),
                child: Text('Logout', style: TextStyle(color: theme.error, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ) ?? false;
        if (confirm) {
          await ref.read(authRepositoryProvider).signOut();
          if (!context.mounted) return;
          context.goNamed(LoginWidget.routeName);
        }
      },
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: Text(
        title,
        style: FlutterFlowTheme.of(context).titleMedium.override(
          font: GoogleFonts.plusJakartaSans(fontWeight: FontWeight.bold),
          color: FlutterFlowTheme.of(context).primaryText,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}
