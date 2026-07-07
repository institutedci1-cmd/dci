import '/auth/firebase_auth/auth_util.dart';
import '/backend/providers/repository_providers.dart';
import '/components/button/button_widget.dart';
import '/components/profile_header/profile_header_widget.dart';
import '/components/profile_info_tile/profile_info_tile_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/index.dart';
import '/backend/services/pdf_service.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'teacher_profile_model.dart';

class TeacherProfileWidget extends ConsumerStatefulWidget {
  const TeacherProfileWidget({super.key});

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
    return GestureDetector(
      onTap: () => FocusScope.of(context).unfocus(),
      child: Scaffold(
        key: scaffoldKey,
        backgroundColor: FlutterFlowTheme.of(context).primaryBackground,
        body: StreamBuilder<Map<String, dynamic>?>(
          stream: ref.watch(userRepositoryProvider).getUserStream(),
          builder: (context, snapshot) {
            final userData = snapshot.data;

            return SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  wrapWithModel(
                    model: _model.profileHeaderModel,
                    updateCallback: () => safeSetState(() {}),
                    child: ProfileHeaderWidget(
                      designation: userData?['designation'] ??
                          'Senior Faculty • M.Sc., M.Ed.',
                      name: currentUserDisplayName != ''
                          ? currentUserDisplayName
                          : (userData?['display_name'] ??
                              'Prof. Rajesh Deshmukh'),
                      photoUrl: currentUserPhoto != ''
                          ? currentUserPhoto
                          : userData?['photo_url'],
                    ),
                  ),
                  _buildActionButtons(context),
                  Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildUserRoleBadge(context, userData),
                        const SizedBox(height: 16.0),
                        _buildPersonalInformation(context, userData),
                        const SizedBox(height: 24.0),
                        _buildEducationExpertise(context, userData),
                        const SizedBox(height: 24.0),
                        _buildAppLinksSection(context),
                        const SizedBox(height: 24.0),
                        _buildSettingsSection(context, userData),
                        const SizedBox(height: 24.0),
                        _buildAboutSection(context),
                        const SizedBox(height: 24.0),
                        _buildLogoutButton(context),
                      ],
                    ),
                  ),
                  const SizedBox(height: 40.0),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildActionButtons(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Row(
        children: [
          Expanded(
            child: wrapWithModel(
              model: _model.buttonModel1,
              updateCallback: () => safeSetState(() {}),
              child: ButtonWidget(
                icon: const Icon(Icons.edit_rounded, size: 24.0),
                iconPresent: true,
                content: 'Edit Profile',
                variant: 'outline',
                onPressed: () => context.pushNamed(EditProfileWidget.routeName),
              ),
            ),
          ),
          const SizedBox(width: 16.0),
          Expanded(
            child: wrapWithModel(
              model: _model.buttonModel2,
              updateCallback: () => safeSetState(() {}),
              child: ButtonWidget(
                icon: const Icon(Icons.share_rounded, size: 24.0),
                iconPresent: true,
                content: 'Share CV',
                variant: 'secondary',
                onPressed: () async {
                  final userData = await ref.read(userRepositoryProvider).getUserData();
                  if (userData != null) {
                    await PdfService.generateTeacherCV(userData);
                  }
                },
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPersonalInformation(BuildContext context, Map<String, dynamic>? userData) {
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
            value: currentUserEmail != '' ? currentUserEmail : (userData?['email'] ?? 'rajesh.d@deshmukhcoaching.com'),
          ),
        ),
        wrapWithModel(
          model: _model.profileInfoTileModel2,
          updateCallback: () => safeSetState(() {}),
          child: ProfileInfoTileWidget(
            icon: Icon(Icons.phone_rounded, color: FlutterFlowTheme.of(context).onPrimaryContainer, size: 20.0),
            label: 'Mobile Number',
            value: currentPhoneNumber != '' ? currentPhoneNumber : (userData?['phone_number'] ?? '+91 98765 43210'),
          ),
        ),
        wrapWithModel(
          model: _model.profileInfoTileModel3,
          updateCallback: () => safeSetState(() {}),
          child: ProfileInfoTileWidget(
            icon: Icon(Icons.badge_rounded, color: FlutterFlowTheme.of(context).onPrimaryContainer, size: 20.0),
            label: 'Employee ID',
            value: userData?['employee_id'] ?? 'Deshmukh-T-2024-089',
          ),
        ),
        wrapWithModel(
          model: _model.profileInfoTileModel4,
          updateCallback: () => safeSetState(() {}),
          child: ProfileInfoTileWidget(
            icon: Icon(Icons.event_available_rounded, color: FlutterFlowTheme.of(context).onPrimaryContainer, size: 20.0),
            label: 'Joined Date',
            value: userData?['joined_date'] ?? '15 May 2018',
          ),
        ),
      ],
    );
  }

  Widget _buildEducationExpertise(BuildContext context, Map<String, dynamic>? userData) {
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
            value: userData?['qualification'] ?? 'M.Sc. Physics, M.Ed. Education',
          ),
        ),
        wrapWithModel(
          model: _model.profileInfoTileModel6,
          updateCallback: () => safeSetState(() {}),
          child: ProfileInfoTileWidget(
            icon: Icon(Icons.psychology_rounded, color: FlutterFlowTheme.of(context).onPrimaryContainer, size: 20.0),
            label: 'Subject Expertise',
            value: userData?['subject_expertise'] ?? 'Advanced Physics & Mathematics',
          ),
        ),
        wrapWithModel(
          model: _model.profileInfoTileModel7,
          updateCallback: () => safeSetState(() {}),
          child: ProfileInfoTileWidget(
            icon: Icon(Icons.workspace_premium_rounded, color: FlutterFlowTheme.of(context).onPrimaryContainer, size: 20.0),
            label: 'Experience',
            value: userData?['experience'] ?? '12 Years in Competitive Coaching',
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection(BuildContext context, Map<String, dynamic>? userData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionHeader(context, 'Settings & Preferences'),
        Container(
          decoration: BoxDecoration(
            color: FlutterFlowTheme.of(context).secondaryBackground,
            borderRadius: BorderRadius.circular(16.0),
            border: Border.all(color: FlutterFlowTheme.of(context).alternate),
          ),
          child: SwitchListTile.adaptive(
            value: userData?['notifications_enabled'] ?? true,
            onChanged: (newValue) async {
              await ref
                  .read(userRepositoryProvider)
                  .updateNotificationSettings(newValue);
            },
            title: Text('Push Notifications', style: FlutterFlowTheme.of(context).bodyLarge),
            subtitle: Text('Receive alerts for new announcements.', style: FlutterFlowTheme.of(context).labelSmall),
            activeThumbColor: FlutterFlowTheme.of(context).primary,
            activeTrackColor: FlutterFlowTheme.of(context).primary10,
            controlAffinity: ListTileControlAffinity.trailing,
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
                  'About Deshmukh Teacher Portal',
                  style: FlutterFlowTheme.of(context).labelLarge.override(
                    font: GoogleFonts.inter(fontWeight: FontWeight.bold),
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4.0),
                Text(
                  'This profile is managed by the Deshmukh HR department.',
                  style: FlutterFlowTheme.of(context).bodySmall,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUserRoleBadge(BuildContext context, Map<String, dynamic>? userData) {
    final role = userData?['role'] ?? 'Teacher';
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
      decoration: BoxDecoration(
        color: FlutterFlowTheme.of(context).secondaryBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: FlutterFlowTheme.of(context).alternate),
      ),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: FlutterFlowTheme.of(context).secondaryText),
        title: Text(title, style: FlutterFlowTheme.of(context).bodyLarge),
        trailing: const Icon(Icons.chevron_right_rounded),
      ),
    );
  }

  Widget _buildLogoutButton(BuildContext context) {
    return wrapWithModel(
      model: createModel(context, () => ButtonModel()),
      updateCallback: () => safeSetState(() {}),
      child: ButtonWidget(
        icon: Icon(Icons.logout_rounded, color: FlutterFlowTheme.of(context).error, size: 24.0),
        iconPresent: true,
        content: 'Logout',
        variant: 'outline',
        onPressed: () async {
          final confirm = await showDialog<bool>(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Logout'),
              content: const Text('Are you sure you want to log out?'),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
                TextButton(onPressed: () => Navigator.pop(context, true), child: const Text('Logout')),
              ],
            ),
          ) ?? false;
          if (confirm) {
            await ref.read(authRepositoryProvider).signOut();
            if (!context.mounted) return;
            context.goNamed(LoginWidget.routeName);
          }
        },
      ),
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
